From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][cr][PATCH  3/6] Define flock_set()
Date: Tue, 4 May 2010 22:31:29 -0700
Message-ID: <20100505053129.GC20993__20922.8569445715$1273037152$gmane$org@us.ibm.com>
References: <20100505053016.GA20483@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100505053016.GA20483-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From e773dc3d5e3d4ead9db7ddbd85b58a20ec95afc0 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 30 Apr 2010 11:03:28 -0700
Subject: [RFC][cr][PATCH  3/6] Define flock_set()

Extract core functionality of fcntl_setlk() into a separate function,
flock_set(). flock_set() can be also used when restarting a checkpointed
application and restoring its file-locks.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |   44 +++++++++++++++++++++++++++-----------------
 include/linux/fs.h |    1 +
 2 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index da53795..6c6ced4 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1758,14 +1758,10 @@ static int do_lock_file_wait(struct file *filp, unsigned int cmd,
 	return error;
 }
 
-/* Apply the lock described by l to an open file descriptor.
- * This implements both the F_SETLK and F_SETLKW commands of fcntl().
- */
-int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
-		struct flock __user *l)
+int flock_set(unsigned int fd, struct file *filp, unsigned int cmd,
+		struct flock *flock)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
-	struct flock flock;
 	struct inode *inode;
 	struct file *f;
 	int error;
@@ -1773,13 +1769,6 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
 	if (file_lock == NULL)
 		return -ENOLCK;
 
-	/*
-	 * This might block, so we do it before checking the inode.
-	 */
-	error = -EFAULT;
-	if (copy_from_user(&flock, l, sizeof(flock)))
-		goto out;
-
 	inode = filp->f_path.dentry->d_inode;
 
 	/* Don't allow mandatory locks on files that may be memory mapped
@@ -1791,7 +1780,7 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
 	}
 
 again:
-	error = flock_to_posix_lock(filp, file_lock, &flock);
+	error = flock_to_posix_lock(filp, file_lock, flock);
 	if (error)
 		goto out;
 	if (cmd == F_SETLKW) {
@@ -1799,7 +1788,7 @@ again:
 	}
 	
 	error = -EBADF;
-	switch (flock.l_type) {
+	switch (flock->l_type) {
 	case F_RDLCK:
 		if (!(filp->f_mode & FMODE_READ))
 			goto out;
@@ -1829,8 +1818,8 @@ again:
 	spin_lock(&current->files->file_lock);
 	f = fcheck(fd);
 	spin_unlock(&current->files->file_lock);
-	if (!error && f != filp && flock.l_type != F_UNLCK) {
-		flock.l_type = F_UNLCK;
+	if (!error && f != filp && flock->l_type != F_UNLCK) {
+		flock->l_type = F_UNLCK;
 		goto again;
 	}
 
@@ -1839,6 +1828,27 @@ out:
 	return error;
 }
 
+/* Apply the lock described by l to an open file descriptor.
+ * This implements both the F_SETLK and F_SETLKW commands of fcntl().
+ */
+int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
+		struct flock __user *l)
+{
+	int error;
+	struct flock flock;
+	
+	/*
+	 * This might block, so we do it before checking the inode
+	 * in flock_set().
+	 */
+	error = -EFAULT;
+	if (copy_from_user(&flock, l, sizeof(flock)))
+		return error;
+
+	return flock_set(fd, filp, cmd, &flock);
+}
+
+
 #if BITS_PER_LONG == 32
 /* Report the first existing lock that would conflict with l.
  * This implements the F_GETLK command of fcntl().
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 909a535..5e9ea17 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1112,6 +1112,7 @@ extern void send_sigio(struct fown_struct *fown, int fd, int band);
 extern int fcntl_getlk(struct file *, struct flock __user *);
 extern int fcntl_setlk(unsigned int, struct file *, unsigned int,
 			struct flock __user *);
+extern int flock_set(unsigned int, struct file *, unsigned int, struct flock *);
 
 #if BITS_PER_LONG == 32
 extern int fcntl_getlk64(struct file *, struct flock64 __user *);
-- 
1.6.0.4
