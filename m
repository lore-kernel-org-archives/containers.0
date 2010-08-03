From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 15/16][cr][v3]: Define do_setlease()
Date: Tue,  3 Aug 2010 16:11:36 -0700
Message-ID: <1280877097-12377-16-git-send-email-sukadev__21644.7843275548$1280878065$gmane$org@linux.vnet.ibm.com>
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

Move the core functionality of fcntl_setlease() into a new function,
do_setlease(). do_setlease() is, same as fcntl_setlease(), except for
two new parameters, 'notified' and 'break_time'.

do_setlease() is used, in a follow-on patch when restoring file leases.
These new parameters are needed if the lease was being broken when the
process was checkpointed.

The parameter 'notified' is used to notify the lease-holder exactly once,
even if the lease was checkpointed during a lease-break and then restarted.

The parameter, 'break_time' specifies the new break-time for the lease.
(i.e if the process had 10-seconds remaining on the lease when it was
checkpointed, the 'break_time' is used give the process 10 seconds on
the lease after the process is restarted).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |   31 ++++++++++++++++++++-----------
 include/linux/fs.h |    2 ++
 2 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index b5eb4c0..6e84d90 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1490,17 +1490,8 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
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
+int do_setlease(unsigned int fd, struct file *filp, long arg, 
+			unsigned long break_time, int notified)
 {
 	struct file_lock fl, *flp = &fl;
 	struct inode *inode = filp->f_path.dentry->d_inode;
@@ -1511,6 +1502,9 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 	if (error)
 		return error;
 
+	fl.fl_break_notified = notified;
+	fl.fl_break_time = break_time;
+
 	lock_kernel();
 
 	error = vfs_setlease(filp, arg, &flp);
@@ -1534,6 +1528,21 @@ out_unlock:
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
+	return do_setlease(fd, filp, arg, 0UL, 0);
+}
+
+/**
  * flock_lock_file_wait - Apply a FLOCK-style lock to a file
  * @filp: The file to apply the lock to
  * @fl: The lock to be applied
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c21f002..5056477 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1124,6 +1124,8 @@ extern int flock64_set(unsigned int, struct file *, unsigned int,
 			struct flock64 *);
 #endif
 
+extern int do_setlease(unsigned int fd, struct file *filp, long arg,
+			unsigned long break_time, int notified);
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
-- 
1.6.0.4
