From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/2] Refactor fcntl_setlk() and fcntl_setlk64()
Date: Mon, 10 Jan 2011 20:37:04 -0500
Message-ID: <1294709825-23357-2-git-send-email-orenl@cs.columbia.edu>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1288333001-28838-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Extract core functionality of fcntl_setlk() and fcntl_setlk64() into
separate functions, flock_set() and flock64_set() respective. These
functions can be also used when restarting a checkpointed application
and restoring its file-locks.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/locks.c         |   76 +++++++++++++++++++++++++++++++--------------------
 include/linux/fs.h |    4 +++
 2 files changed, 50 insertions(+), 30 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index e30ad46..c3fc56d 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1807,14 +1807,13 @@ static int do_lock_file_wait(struct file *filp, unsigned int cmd,
 	return error;
 }
 
-/* Apply the lock described by l to an open file descriptor.
+/* Apply the lock described by @flock to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
-		struct flock __user *l)
+int do_fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
+		   struct flock *flock)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
-	struct flock flock;
 	struct inode *inode;
 	struct file *f;
 	int error;
@@ -1822,13 +1821,6 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
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
@@ -1840,7 +1832,7 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
 	}
 
 again:
-	error = flock_to_posix_lock(filp, file_lock, &flock);
+	error = flock_to_posix_lock(filp, file_lock, flock);
 	if (error)
 		goto out;
 	if (cmd == F_SETLKW) {
@@ -1848,7 +1840,7 @@ again:
 	}
 	
 	error = -EBADF;
-	switch (flock.l_type) {
+	switch (flock->l_type) {
 	case F_RDLCK:
 		if (!(filp->f_mode & FMODE_READ))
 			goto out;
@@ -1878,8 +1870,8 @@ again:
 	spin_lock(&current->files->file_lock);
 	f = fcheck(fd);
 	spin_unlock(&current->files->file_lock);
-	if (!error && f != filp && flock.l_type != F_UNLCK) {
-		flock.l_type = F_UNLCK;
+	if (!error && f != filp && flock->l_type != F_UNLCK) {
+		flock->l_type = F_UNLCK;
 		goto again;
 	}
 
@@ -1888,6 +1880,23 @@ out:
 	return error;
 }
 
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
+	return do_fcntl_setlk(fd, filp, cmd, &flock);
+}
+
 #if BITS_PER_LONG == 32
 /* Report the first existing lock that would conflict with l.
  * This implements the F_GETLK command of fcntl().
@@ -1925,14 +1934,13 @@ out:
 	return error;
 }
 
-/* Apply the lock described by l to an open file descriptor.
+/* Apply the lock described by @flock to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
-		struct flock64 __user *l)
+int do_fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
+		     struct flock64 *flock)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
-	struct flock64 flock;
 	struct inode *inode;
 	struct file *f;
 	int error;
@@ -1940,13 +1948,6 @@ int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
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
@@ -1958,7 +1959,7 @@ int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
 	}
 
 again:
-	error = flock64_to_posix_lock(filp, file_lock, &flock);
+	error = flock64_to_posix_lock(filp, file_lock, flock);
 	if (error)
 		goto out;
 	if (cmd == F_SETLKW64) {
@@ -1966,7 +1967,7 @@ again:
 	}
 	
 	error = -EBADF;
-	switch (flock.l_type) {
+	switch (flock->l_type) {
 	case F_RDLCK:
 		if (!(filp->f_mode & FMODE_READ))
 			goto out;
@@ -1991,8 +1992,8 @@ again:
 	spin_lock(&current->files->file_lock);
 	f = fcheck(fd);
 	spin_unlock(&current->files->file_lock);
-	if (!error && f != filp && flock.l_type != F_UNLCK) {
-		flock.l_type = F_UNLCK;
+	if (!error && f != filp && flock->l_type != F_UNLCK) {
+		flock->l_type = F_UNLCK;
 		goto again;
 	}
 
@@ -2002,6 +2003,21 @@ out:
 }
 #endif /* BITS_PER_LONG == 32 */
 
+int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
+		struct flock64 __user *l)
+{
+	struct flock64 flock;
+
+	/*
+	 * This might block, so we do it before checking the inode in
+	 * flock64_set().
+	 */
+	if (copy_from_user(&flock, l, sizeof(flock)))
+		return -EFAULT;
+
+	return do_fcntl_setlk64(fd, filp, cmd, &flock);
+}
+
 /*
  * This function is called when the file is being removed
  * from the task's fd array.  POSIX locks belonging to this task
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3d8bf75..7f38be1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1121,11 +1121,15 @@ extern void send_sigio(struct fown_struct *fown, int fd, int band);
 extern int fcntl_getlk(struct file *, struct flock __user *);
 extern int fcntl_setlk(unsigned int, struct file *, unsigned int,
 			struct flock __user *);
+extern int do_fcntl_setlk(unsigned int, struct file *, unsigned int,
+			  struct flock *);
 
 #if BITS_PER_LONG == 32
 extern int fcntl_getlk64(struct file *, struct flock64 __user *);
 extern int fcntl_setlk64(unsigned int, struct file *, unsigned int,
 			struct flock64 __user *);
+extern int do_fcntl_set(unsigned int, struct file *, unsigned int,
+			struct flock64 *);
 #endif
 
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
-- 
1.7.1
