From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Mon, 03 Aug 2015 16:30:54 -0500
Message-ID: <8738009i0h.fsf_-___42905.7960435331$1438637887$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tfkawu9.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 03 Aug 2015 16:25:18 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


Add a new field mnt_escape_count in nameidata, initialize it to 0 and
cache the value of read_mnt_escape_count in nd->mnt_escape_count.

This allows a single check in path_connected in the common case where
either the mount has had no escapes (mnt_escape_count == 0) or there
has been an escape and it has been validated that the current path
does not escape.

To keep the cache valid nd->mnt_escape_count must be set to 0 whenever
the nd->path.mnt changes or when nd->path.dentry changes such that
the connectedness of the previous value of nd->path.dentry does
not imply the connected of the new value of nd->path.dentry.

Various locations in fs/namei.c are updated to set
nd->mnt_escape_count to 0 as necessary.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namei.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index bccd3810ff60..79a5dca073f5 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -514,6 +514,7 @@ struct nameidata {
 	struct nameidata *saved;
 	unsigned	root_seq;
 	int		dfd;
+	unsigned	mnt_escape_count;
 };
 
 static void set_nameidata(struct nameidata *p, int dfd, struct filename *name)
@@ -572,12 +573,13 @@ static bool path_connected(struct nameidata *nd)
 	struct vfsmount *mnt = nd->path.mnt;
 	unsigned escape_count = read_mnt_escape_count(mnt);
 
-	if (likely(escape_count == 0))
+	if (likely(escape_count == nd->mnt_escape_count))
 		return true;
 
 	if (!is_subdir(nd->path.dentry, mnt->mnt_root))
 		return false;
 
+	cache_mnt_escape_count(&nd->mnt_escape_count, escape_count);
 	return true;
 }
 
@@ -840,6 +842,9 @@ static inline void path_to_nameidata(const struct path *path,
 		if (nd->path.mnt != path->mnt)
 			mntput(nd->path.mnt);
 	}
+	if (unlikely((nd->path.mnt != path->mnt) ||
+		     (nd->path.dentry != path->dentry->d_parent)))
+		nd->mnt_escape_count = 0;
 	nd->path.mnt = path->mnt;
 	nd->path.dentry = path->dentry;
 }
@@ -856,6 +861,7 @@ void nd_jump_link(struct path *path)
 	nd->path = *path;
 	nd->inode = nd->path.dentry->d_inode;
 	nd->flags |= LOOKUP_JUMPED;
+	nd->mnt_escape_count = 0;
 }
 
 static inline void put_link(struct nameidata *nd)
@@ -1040,6 +1046,7 @@ const char *get_link(struct nameidata *nd)
 			nd->inode = nd->path.dentry->d_inode;
 		}
 		nd->flags |= LOOKUP_JUMPED;
+		nd->mnt_escape_count = 0;
 		while (unlikely(*++res == '/'))
 			;
 	}
@@ -1335,6 +1342,7 @@ static int follow_dotdot_rcu(struct nameidata *nd)
 			nd->path.mnt = &mparent->mnt;
 			inode = inode2;
 			nd->seq = seq;
+			nd->mnt_escape_count = 0;
 		}
 	}
 	while (unlikely(d_mountpoint(nd->path.dentry))) {
@@ -1348,6 +1356,7 @@ static int follow_dotdot_rcu(struct nameidata *nd)
 		nd->path.dentry = mounted->mnt.mnt_root;
 		inode = nd->path.dentry->d_inode;
 		nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
+		nd->mnt_escape_count = 0;
 	}
 	nd->inode = inode;
 	return 0;
@@ -1406,8 +1415,9 @@ EXPORT_SYMBOL(follow_down);
 /*
  * Skip to top of mountpoint pile in refwalk mode for follow_dotdot()
  */
-static void follow_mount(struct path *path)
+static bool follow_mount(struct path *path)
 {
+	bool followed = false;
 	while (d_mountpoint(path->dentry)) {
 		struct vfsmount *mounted = lookup_mnt(path);
 		if (!mounted)
@@ -1416,7 +1426,9 @@ static void follow_mount(struct path *path)
 		mntput(path->mnt);
 		path->mnt = mounted;
 		path->dentry = dget(mounted->mnt_root);
+		followed = true;
 	}
+	return followed;
 }
 
 static int follow_dotdot(struct nameidata *nd)
@@ -1444,8 +1456,10 @@ static int follow_dotdot(struct nameidata *nd)
 		}
 		if (!follow_up(&nd->path))
 			break;
+		nd->mnt_escape_count = 0;
 	}
-	follow_mount(&nd->path);
+	if (follow_mount(&nd->path))
+		nd->mnt_escape_count = 0;
 	nd->inode = nd->path.dentry->d_inode;
 	return 0;
 }
@@ -1997,6 +2011,7 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 	nd->flags = flags | LOOKUP_JUMPED | LOOKUP_PARENT;
 	nd->depth = 0;
 	nd->total_link_count = 0;
+	nd->mnt_escape_count = 0;
 	if (flags & LOOKUP_ROOT) {
 		struct dentry *root = nd->root.dentry;
 		struct inode *inode = root->d_inode;
@@ -3026,6 +3041,7 @@ static int do_last(struct nameidata *nd,
 	unsigned seq;
 	struct inode *inode;
 	struct path save_parent = { .dentry = NULL, .mnt = NULL };
+	unsigned save_parent_escape_count = 0;
 	struct path path;
 	bool retried = false;
 	int error;
@@ -3155,6 +3171,9 @@ finish_lookup:
 	} else {
 		save_parent.dentry = nd->path.dentry;
 		save_parent.mnt = mntget(path.mnt);
+		save_parent_escape_count = nd->mnt_escape_count;
+		if (nd->path.dentry != path.dentry->d_parent)
+			nd->mnt_escape_count = 0;
 		nd->path.dentry = path.dentry;
 
 	}
@@ -3227,6 +3246,7 @@ stale_open:
 
 	BUG_ON(save_parent.dentry != dir);
 	path_put(&nd->path);
+	nd->mnt_escape_count = save_parent_escape_count;
 	nd->path = save_parent;
 	nd->inode = dir->d_inode;
 	save_parent.mnt = NULL;
-- 
2.2.1
