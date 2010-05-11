From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/4][cr]: Define __f_setown_uid()
Date: Tue, 11 May 2010 15:38:18 -0700
Message-ID: <1273617500-13653-3-git-send-email-sukadev__4253.39449798248$1273617351$gmane$org@linux.vnet.ibm.com>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273617500-13653-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

__f_setown_uid() is same as __f_setown(), except that instead of assuming the
uid and euid of current process, it expects them to be passed in as parameters.

This interface will be useful when checkpointing and restarting an application
that has a 'file owner' specified for any of the application's open files.
The uid, euid of the process setting up the owner is saved in the checkpoint
image. When the application is restarted, the save uid and euid values are
restored.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/fcntl.c         |   13 ++++++++++---
 include/linux/fs.h |    2 ++
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index aeab1f4..6e5d2bc 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -213,8 +213,8 @@ static void f_modown(struct file *filp, struct pid *pid, enum pid_type type,
 	write_unlock_irq(&filp->f_owner.lock);
 }
 
-int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
-		int force)
+int __f_setown_uid(struct file *filp, struct pid *pid, enum pid_type type,
+		uid_t uid, uid_t euid, int force)
 {
 	int err;
 
@@ -222,9 +222,16 @@ int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
 	if (err)
 		return err;
 
-	f_modown(filp, pid, type, current_uid(), current_euid(), force);
+	f_modown(filp, pid, type, uid, euid, force);
 	return 0;
 }
+
+int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
+		int force)
+{
+	return __f_setown_uid(filp, pid, type, current_uid(), current_euid(),
+			force);
+}
 EXPORT_SYMBOL(__f_setown);
 
 int f_setown(struct file *filp, unsigned long arg, int force)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ee725ff..8257b1a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1304,6 +1304,8 @@ extern void kill_fasync(struct fasync_struct **, int, int);
 /* only for net: no internal synchronization */
 extern void __kill_fasync(struct fasync_struct *, int, int);
 
+extern int __f_setown_uid(struct file *filp, struct pid *, enum pid_type,
+		uid_t uid, uid_t euid, int force);
 extern int __f_setown(struct file *filp, struct pid *, enum pid_type, int force);
 extern int f_setown(struct file *filp, unsigned long arg, int force);
 extern void f_delown(struct file *filp);
-- 
1.6.0.4
