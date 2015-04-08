From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 3/4] vfs: Handle mounts whose parents are unreachable
	from their mountpoint
Date: Wed, 08 Apr 2015 18:33:34 -0500
Message-ID: <87mw2i8ab5.fsf_-___13504.3993629099$1428536276$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874moq9oyb.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Wed, 08 Apr 2015 18:31:56 -0500")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


- In follup_up and follow_up_rcu don't follow up if the current
  mount's mountpoint can not reach the parent mount's root.

- In prepend_path and it's callers in the d_path family don't follow
  to the parent mount if the current mount's mountpoint can not reach
  the parent mount's root.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c | 14 ++++++++++----
 fs/namei.c  | 27 +++++++++++++++++----------
 2 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index e07eb03f6de6..6e68312494ed 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2894,10 +2894,16 @@ restart:
 			struct mount *parent = ACCESS_ONCE(mnt->mnt_parent);
 			/* Global root? */
 			if (mnt != parent) {
-				dentry = ACCESS_ONCE(mnt->mnt_mountpoint);
-				mnt = parent;
-				vfsmnt = &mnt->mnt;
-				continue;
+				struct path new = {
+					.dentry = ACCESS_ONCE(mnt->mnt_mountpoint),
+					.mnt = &parent->mnt,
+				};
+				if (path_connected(&new)) {
+					mnt = parent;
+					dentry = new.dentry;
+					vfsmnt = new.mnt;
+					continue;
+				}
 			}
 			/*
 			 * Filesystems needing to implement special "root names"
diff --git a/fs/namei.c b/fs/namei.c
index 83cdcdf36eed..40e56d76df34 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -935,14 +935,16 @@ static int follow_up_rcu(struct path *path)
 {
 	struct mount *mnt = real_mount(path->mnt);
 	struct mount *parent;
-	struct dentry *mountpoint;
+	struct path new;
 
 	parent = mnt->mnt_parent;
-	if (&parent->mnt == path->mnt)
+	if (parent == mnt)
 		return 0;
-	mountpoint = mnt->mnt_mountpoint;
-	path->dentry = mountpoint;
-	path->mnt = &parent->mnt;
+	new.dentry = mnt->mnt_mountpoint;
+	new.mnt = &parent->mnt;
+	if (!path_connected(&new))
+		return 0;
+	*path = new;
 	return 1;
 }
 
@@ -960,7 +962,7 @@ int follow_up(struct path *path)
 {
 	struct mount *mnt = real_mount(path->mnt);
 	struct mount *parent;
-	struct dentry *mountpoint;
+	struct path new;
 
 	read_seqlock_excl(&mount_lock);
 	parent = mnt->mnt_parent;
@@ -968,13 +970,18 @@ int follow_up(struct path *path)
 		read_sequnlock_excl(&mount_lock);
 		return 0;
 	}
-	mntget(&parent->mnt);
-	mountpoint = dget(mnt->mnt_mountpoint);
+	new.dentry = mnt->mnt_mountpoint;
+	new.mnt = &parent->mnt;
+	if (!path_connected(&new)) {
+		read_sequnlock_excl(&mount_lock);
+		return 0;
+	}
+	mntget(new.mnt);
+	dget(new.dentry);
 	read_sequnlock_excl(&mount_lock);
 	dput(path->dentry);
-	path->dentry = mountpoint;
 	mntput(path->mnt);
-	path->mnt = &parent->mnt;
+	*path = new;
 	return 1;
 }
 EXPORT_SYMBOL(follow_up);
-- 
2.2.1
