From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 03/10] Introduce has_locks_with_owner() helper
Date: Mon, 28 Feb 2011 17:40:25 -0600
Message-ID: <1298936432-29607-4-git-send-email-ntl__10226.6243812212$1298937029$gmane$org@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Support for file locks is in the works, but until that is done
checkpoint needs to fail when an open file has locks.

Based on original "find_locks_with_owner" patch by Dave Hansen.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
[ntl: changed name and return type to clearly express semantics]
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 fs/locks.c         |   35 +++++++++++++++++++++++++++++++++++
 include/linux/fs.h |    6 ++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 8729347..961e17f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2037,6 +2037,41 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 
 EXPORT_SYMBOL(locks_remove_posix);
 
+bool has_locks_with_owner(struct file *filp, fl_owner_t owner)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct file_lock **inode_fl;
+	bool ret = false;
+
+	lock_flocks();
+	for_each_lock(inode, inode_fl) {
+		struct file_lock *fl = *inode_fl;
+		/*
+		 * We could use posix_same_owner() along with a 'fake'
+		 * file_lock.  But, the fake file will never have the
+		 * same fl_lmops as the fl that we are looking for and
+		 * posix_same_owner() would just fall back to this
+		 * check anyway.
+		 */
+		if (IS_POSIX(fl)) {
+			if (fl->fl_owner == owner) {
+				ret = true;
+				break;
+			}
+		} else if (IS_FLOCK(fl) || IS_LEASE(fl)) {
+			if (fl->fl_file == filp) {
+				ret = true;
+				break;
+			}
+		} else {
+			WARN(1, "unknown file lock type, fl_flags: %x",
+				fl->fl_flags);
+		}
+	}
+	unlock_flocks();
+	return ret;
+}
+
 /*
  * This function is called on the last close of an open file.
  */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 090f0ea..315ded4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1138,6 +1138,7 @@ extern void locks_remove_posix(struct file *, fl_owner_t);
 extern void locks_remove_flock(struct file *);
 extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
+extern bool has_locks_with_owner(struct file *filp, fl_owner_t owner);
 extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
 extern int posix_lock_file_wait(struct file *, struct file_lock *);
 extern int posix_unblock_lock(struct file *, struct file_lock *);
@@ -1208,6 +1209,11 @@ static inline void locks_remove_posix(struct file *filp, fl_owner_t owner)
 	return;
 }
 
+static inline bool has_locks_with_owner(struct file *filp, fl_owner_t owner)
+{
+	return false;
+}
+
 static inline void locks_remove_flock(struct file *filp)
 {
 	return;
-- 
1.7.4
