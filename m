From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] vfs: Test for and handle paths that are unreachable from
	their mnt_root
Date: Sat, 15 Aug 2015 20:27:13 -0500
Message-ID: <87tws010r2.fsf_-_@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
	<87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
	<87fv3mjxsc.fsf_-_@x220.int.ebiederm.org>
	<20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
	<CA+55aFzMuCn33yK71HoKnj1hr8=ac_Y-vfE5mM8h4f3YJeGKvg@mail.gmail.com>
	<CA+55aFyeu-p_3eJQCLM0TDuLYvo10mx379FaCFq7Z103RgKvVA@mail.gmail.com>
	<E2AECA7F-ED57-4FCD-A4C0-8C7C4B860FB6@xmission.com>
	<CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w@mail.gmail.com>
	<87bne82glg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bne82glg.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Sat, 15 Aug 2015 19:59:39 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


In rare cases a directory can be renamed out from under a bind mount.
In those cases without special handling it becomes possible to walk up
the directory tree to the root dentry of the filesystem and down
from the root dentry to every other file or directory on the filesystem.

Like division by zero .. from an unconnected path can not be given
a useful semantic as there is no predicting at which path component
the code will realize it is unconnected.  We certainly can not match
the current behavior as the current behavior is a security hole.

Therefore when encounting .. when following an unconnected path
return -ENOENT.

- Add a function path_connected to verify path->dentry is reachable
  from path->mnt.mnt_root.  AKA to validate that rename did not do
  something nasty to the bind mount.

  To avoid races path_connected must be called after following a path
  component to it's next path component.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

This is the simple version that needs no extra vfs support.

My availability is likely to be a bit spotty for the next while
as I am travelling to and then attending Linux Plumbers Conference.

 fs/namei.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index ae4e4c18b2ac..5303e994f8d6 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -560,6 +560,24 @@ static int __nd_alloc_stack(struct nameidata *nd)
 	return 0;
 }
 
+/**
+ * path_connected - Verify that a path->dentry is below path->mnt.mnt_root
+ * @path: nameidate to verify
+ *
+ * Rename can sometimes move a file or directory outside of a bind
+ * mount, path_connected allows those cases to be detected.
+ */
+static bool path_connected(const struct path *path)
+{
+	struct vfsmount *mnt = path->mnt;
+
+	/* Only bind mounts can have disconnected paths */
+	if (mnt->mnt_root == mnt->mnt_sb->s_root)
+		return true;
+
+	return is_subdir(path->dentry, mnt->mnt_root);
+}
+
 static inline int nd_alloc_stack(struct nameidata *nd)
 {
 	if (likely(nd->depth != EMBEDDED_LEVELS))
@@ -1296,6 +1314,8 @@ static int follow_dotdot_rcu(struct nameidata *nd)
 				return -ECHILD;
 			nd->path.dentry = parent;
 			nd->seq = seq;
+			if (unlikely(!path_connected(&nd->path)))
+				return -ENOENT;
 			break;
 		} else {
 			struct mount *mnt = real_mount(nd->path.mnt);
@@ -1396,7 +1416,7 @@ static void follow_mount(struct path *path)
 	}
 }
 
-static void follow_dotdot(struct nameidata *nd)
+static int follow_dotdot(struct nameidata *nd)
 {
 	if (!nd->root.mnt)
 		set_root(nd);
@@ -1412,6 +1432,8 @@ static void follow_dotdot(struct nameidata *nd)
 			/* rare case of legitimate dget_parent()... */
 			nd->path.dentry = dget_parent(nd->path.dentry);
 			dput(old);
+			if (unlikely(!path_connected(&nd->path)))
+				return -ENOENT;
 			break;
 		}
 		if (!follow_up(&nd->path))
@@ -1419,6 +1441,7 @@ static void follow_dotdot(struct nameidata *nd)
 	}
 	follow_mount(&nd->path);
 	nd->inode = nd->path.dentry->d_inode;
+	return 0;
 }
 
 /*
@@ -1634,7 +1657,7 @@ static inline int handle_dots(struct nameidata *nd, int type)
 		if (nd->flags & LOOKUP_RCU) {
 			return follow_dotdot_rcu(nd);
 		} else
-			follow_dotdot(nd);
+			return follow_dotdot(nd);
 	}
 	return 0;
 }
-- 
2.2.1
