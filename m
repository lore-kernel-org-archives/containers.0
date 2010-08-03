From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 07/16][cr][v3]: Define flock_set()
Date: Tue,  3 Aug 2010 16:11:28 -0700
Message-ID: <1280877097-12377-8-git-send-email-sukadev__3626.36850118196$1280877419$gmane$org@linux.vnet.ibm.com>
References: <1280877097-12377-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280877097-12377-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Extract core functionality of fcntl_setlk() into a separate function,
flock_set(). flock_set() can be also used when restarting a checkpointed
application and restoring its file-locks.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |   44 +++++++++++++++++++++++++++-----------------
 include/linux/fs.h |    1 +
 2 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 741b8b7..cb83741 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1759,14 +1759,10 @@ static int do_lock_file_wait(struct file *filp, unsigned int cmd,
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
@@ -1774,13 +1770,6 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
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
@@ -1792,7 +1781,7 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
 	}
 
 again:
-	error = flock_to_posix_lock(filp, file_lock, &flock);
+	error = flock_to_posix_lock(filp, file_lock, flock);
 	if (error)
 		goto out;
 	if (cmd == F_SETLKW) {
@@ -1800,7 +1789,7 @@ again:
 	}
 	
 	error = -EBADF;
-	switch (flock.l_type) {
+	switch (flock->l_type) {
 	case F_RDLCK:
 		if (!(filp->f_mode & FMODE_READ))
 			goto out;
@@ -1830,8 +1819,8 @@ again:
 	spin_lock(&current->files->file_lock);
 	f = fcheck(fd);
 	spin_unlock(&current->files->file_lock);
-	if (!error && f != filp && flock.l_type != F_UNLCK) {
-		flock.l_type = F_UNLCK;
+	if (!error && f != filp && flock->l_type != F_UNLCK) {
+		flock->l_type = F_UNLCK;
 		goto again;
 	}
 
@@ -1840,6 +1829,27 @@ out:
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
index abd2267..fd66f37 100644
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
