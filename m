From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][cr][PATCH  5/6] Define do_setlease()
Date: Tue, 4 May 2010 22:32:05 -0700
Message-ID: <20100505053205.GE20993__40946.6182849885$1273037197$gmane$org@us.ibm.com>
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


From 3ee14213853e8d72fb8b9791bc1441533952347e Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 4 May 2010 10:59:09 -0700
Subject: [RFC][cr][PATCH  5/6] Define do_setlease()

Move the core functionality of fcntl_setlease() into a new function,
do_setlease(). do_setlease() is same as fcntl_setlease() except that
it takes an extra 'rem_lease' parameter. do_setlease() will be used
in a follow-on patch to checkpoint/restart file-leases.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |   28 +++++++++++++++++-----------
 include/linux/fs.h |    1 +
 2 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 6c6ced4..053ac5f 100644
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
@@ -1508,12 +1498,28 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 	}
 
 	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
+
 out_unlock:
 	unlock_kernel();
 	return error;
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
index 5e9ea17..137f244 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1120,6 +1120,7 @@ extern int fcntl_setlk64(unsigned int, struct file *, unsigned int,
 			struct flock64 __user *);
 #endif
 
+extern int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease);
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
-- 
1.6.0.4
