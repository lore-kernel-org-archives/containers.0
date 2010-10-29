From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/5][v5][cr]: Define flock64_set()
Date: Thu, 28 Oct 2010 23:16:39 -0700
Message-ID: <1288333001-28838-4-git-send-email-sukadev__14144.1440362998$1288332618$gmane$org@linux.vnet.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Extract core functionality of fcntl_setlk64() into a separate function,
flock64_set(). flock64_set() can be also used when restarting a checkpointed
application and restoring its file-locks.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |   38 ++++++++++++++++++++++++--------------
 include/linux/fs.h |    2 ++
 2 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 6c6ced4..34b0e14 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1889,11 +1889,10 @@ out:
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
-		struct flock64 __user *l)
+int flock64_set(unsigned int fd, struct file *filp, unsigned int cmd,
+		struct flock64 *flock)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
-	struct flock64 flock;
 	struct inode *inode;
 	struct file *f;
 	int error;
@@ -1901,13 +1900,6 @@ int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
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
@@ -1919,7 +1911,7 @@ int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
 	}
 
 again:
-	error = flock64_to_posix_lock(filp, file_lock, &flock);
+	error = flock64_to_posix_lock(filp, file_lock, flock);
 	if (error)
 		goto out;
 	if (cmd == F_SETLKW64) {
@@ -1927,7 +1919,7 @@ again:
 	}
 	
 	error = -EBADF;
-	switch (flock.l_type) {
+	switch (flock->l_type) {
 	case F_RDLCK:
 		if (!(filp->f_mode & FMODE_READ))
 			goto out;
@@ -1952,8 +1944,8 @@ again:
 	spin_lock(&current->files->file_lock);
 	f = fcheck(fd);
 	spin_unlock(&current->files->file_lock);
-	if (!error && f != filp && flock.l_type != F_UNLCK) {
-		flock.l_type = F_UNLCK;
+	if (!error && f != filp && flock->l_type != F_UNLCK) {
+		flock->l_type = F_UNLCK;
 		goto again;
 	}
 
@@ -1961,6 +1953,24 @@ out:
 	locks_free_lock(file_lock);
 	return error;
 }
+
+/* Apply the lock described by l to an open file descriptor.
+ * This implements both the F_SETLK and F_SETLKW commands of fcntl().
+ */
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
+	return flock64_set(fd, filp, cmd, &flock);
+}
 #endif /* BITS_PER_LONG == 32 */
 
 /*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5e9ea17..3f72462 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1118,6 +1118,8 @@ extern int flock_set(unsigned int, struct file *, unsigned int, struct flock *);
 extern int fcntl_getlk64(struct file *, struct flock64 __user *);
 extern int fcntl_setlk64(unsigned int, struct file *, unsigned int,
 			struct flock64 __user *);
+extern int flock64_set(unsigned int, struct file *, unsigned int,
+			struct flock64 *);
 #endif
 
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
-- 
1.6.0.4
