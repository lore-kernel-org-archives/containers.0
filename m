From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 02/16][cr][v3]: Add uid, euid params to __f_setown()
Date: Tue,  3 Aug 2010 16:11:23 -0700
Message-ID: <1280877097-12377-3-git-send-email-sukadev__49536.7242758677$1280877036$gmane$org@linux.vnet.ibm.com>
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

Instead of letting __f_setown() use the UID and EUID of the calling process,
pass them in as parameters.

This modified interface will be useful when checkpointing and restarting an
application that has a 'file owner' specified for an open file.  When
checkpointing the application, the UID and EUID of the process setting up
the owner are saved in the checkpoint image.

When the application is restarted, we use the UID and EUID values saved in
the checkpoint-image, rather than that of the calling process.

Changelog[v2]:
	- [Matthew Wilcox] Rather than a new __f_setown_uid() interface add
	  the uid parameters to __f_setown() itself.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 drivers/char/tty_io.c       |    3 ++-
 drivers/net/tun.c           |    3 ++-
 fs/fcntl.c                  |   10 ++++++----
 fs/locks.c                  |    3 ++-
 fs/notify/dnotify/dnotify.c |    3 ++-
 include/linux/fs.h          |    3 ++-
 6 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 115c8e4..9c282b2 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -1969,7 +1969,8 @@ static int tty_fasync(int fd, struct file *filp, int on)
 		}
 		get_pid(pid);
 		spin_unlock_irqrestore(&tty->ctrl_lock, flags);
-		retval = __f_setown(filp, pid, type, 0);
+		retval = __f_setown(filp, pid, type, current_uid(),
+				current_euid(), 0);
 		put_pid(pid);
 		if (retval)
 			goto out;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4326520..dcbc37d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1400,7 +1400,8 @@ static int tun_chr_fasync(int fd, struct file *file, int on)
 		goto out;
 
 	if (on) {
-		ret = __f_setown(file, task_pid(current), PIDTYPE_PID, 0);
+		ret = __f_setown(file, task_pid(current), PIDTYPE_PID,
+				current_uid(), current_euid(), 0);
 		if (ret)
 			goto out;
 		tun->flags |= TUN_FASYNC;
diff --git a/fs/fcntl.c b/fs/fcntl.c
index aeab1f4..f44327d 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -214,7 +214,7 @@ static void f_modown(struct file *filp, struct pid *pid, enum pid_type type,
 }
 
 int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
-		int force)
+		uid_t uid, uid_t euid, int force)
 {
 	int err;
 
@@ -222,7 +222,7 @@ int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
 	if (err)
 		return err;
 
-	f_modown(filp, pid, type, current_uid(), current_euid(), force);
+	f_modown(filp, pid, type, uid, euid, force);
 	return 0;
 }
 EXPORT_SYMBOL(__f_setown);
@@ -240,7 +240,8 @@ int f_setown(struct file *filp, unsigned long arg, int force)
 	}
 	rcu_read_lock();
 	pid = find_vpid(who);
-	result = __f_setown(filp, pid, type, force);
+	result = __f_setown(filp, pid, type, current_uid(), current_euid(),
+			force);
 	rcu_read_unlock();
 	return result;
 }
@@ -296,7 +297,8 @@ static int f_setown_ex(struct file *filp, unsigned long arg)
 	if (owner.pid && !pid)
 		ret = -ESRCH;
 	else
-		ret = __f_setown(filp, pid, type, 1);
+		ret = __f_setown(filp, pid, type, current_uid(), 
+				current_euid(), 1);
 	rcu_read_unlock();
 
 	return ret;
diff --git a/fs/locks.c b/fs/locks.c
index 9cd859e..ca0c7e2 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1514,7 +1514,8 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 		goto out_unlock;
 	}
 
-	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
+	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, current_uid(),
+				current_euid(), 0);
 out_unlock:
 	unlock_kernel();
 	return error;
diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 0a63bf6..3e025e5 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -409,7 +409,8 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
 		goto out;
 	}
 
-	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
+	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, current_uid(),
+				current_euid(), 0);
 	if (error) {
 		/* if we added, we must shoot */
 		if (dnentry == new_dnentry)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ee725ff..b4a6fb0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1304,7 +1304,8 @@ extern void kill_fasync(struct fasync_struct **, int, int);
 /* only for net: no internal synchronization */
 extern void __kill_fasync(struct fasync_struct *, int, int);
 
-extern int __f_setown(struct file *filp, struct pid *, enum pid_type, int force);
+extern int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
+		uid_t uid, uid_t euid, int force);
 extern int f_setown(struct file *filp, unsigned long arg, int force);
 extern void f_delown(struct file *filp);
 extern pid_t f_getown(struct file *filp);
-- 
1.6.0.4
