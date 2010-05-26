From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 1/3][cr][v2]: Define do_setlease()
Date: Tue, 25 May 2010 18:07:41 -0700
Message-ID: <1274836063-13271-2-git-send-email-sukadev__2541.96563405475$1274835821$gmane$org@linux.vnet.ibm.com>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274836063-13271-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Move the core functionality of fcntl_setlease() into a new function,
do_setlease(). do_setlease() is same as fcntl_setlease() except that
it takes an extra 'rem_lease' parameter. do_setlease() will be used
in a follow-on patch to checkpoint/restart file-leases.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |   27 ++++++++++++++++-----------
 include/linux/fs.h |    1 +
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index c62ab7f..4107295 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1471,17 +1471,7 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
-/**
- *	fcntl_setlease	-	sets a lease on an open file
- *	@fd: open file descriptor
- *	@filp: file pointer
- *	@arg: type of lease to obtain
- *
- *	Call this fcntl to establish a lease on the file.
- *	Note that you also need to call %F_SETSIG to
- *	receive a signal when the lease is broken.
- */
-int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
+int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease)
 {
 	struct file_lock fl, *flp = &fl;
 	struct inode *inode = filp->f_path.dentry->d_inode;
@@ -1515,6 +1505,21 @@ out_unlock:
 }
 
 /**
+ *	fcntl_setlease	-	sets a lease on an open file
+ *	@fd: open file descriptor
+ *	@filp: file pointer
+ *	@arg: type of lease to obtain
+ *
+ *	Call this fcntl to establish a lease on the file.
+ *	Note that you also need to call %F_SETSIG to
+ *	receive a signal when the lease is broken.
+ */
+int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
+{
+	return do_setlease(fd, filp, arg, 0);
+}
+
+/**
  * flock_lock_file_wait - Apply a FLOCK-style lock to a file
  * @filp: The file to apply the lock to
  * @fl: The lock to be applied
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 49d4eeb..700317a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1122,6 +1122,7 @@ extern int flock64_set(unsigned int, struct file *, unsigned int,
 			struct flock64 *);
 #endif
 
+extern int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease);
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
-- 
1.6.0.4
