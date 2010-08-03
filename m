From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 01/16][cr][v3]: Add uid, euid params to f_modown()
Date: Tue,  3 Aug 2010 16:11:22 -0700
Message-ID: <1280877097-12377-2-git-send-email-sukadev__31466.8292565786$1280877167$gmane$org@linux.vnet.ibm.com>
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

Checkpoint/restart of file-owner.

Add uid, euid parameters to f_modown(). These parameters will be needed
when restarting an application (and hence restoring the file information),
from a checkpoint image.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/fcntl.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 2079af0..aeab1f4 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -197,7 +197,7 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 }
 
 static void f_modown(struct file *filp, struct pid *pid, enum pid_type type,
-                     int force)
+                     uid_t uid, uid_t euid, int force)
 {
 	write_lock_irq(&filp->f_owner.lock);
 	if (force || !filp->f_owner.pid) {
@@ -206,9 +206,8 @@ static void f_modown(struct file *filp, struct pid *pid, enum pid_type type,
 		filp->f_owner.pid_type = type;
 
 		if (pid) {
-			const struct cred *cred = current_cred();
-			filp->f_owner.uid = cred->uid;
-			filp->f_owner.euid = cred->euid;
+			filp->f_owner.uid = uid;
+			filp->f_owner.euid = euid;
 		}
 	}
 	write_unlock_irq(&filp->f_owner.lock);
@@ -223,7 +222,7 @@ int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
 	if (err)
 		return err;
 
-	f_modown(filp, pid, type, force);
+	f_modown(filp, pid, type, current_uid(), current_euid(), force);
 	return 0;
 }
 EXPORT_SYMBOL(__f_setown);
@@ -249,7 +248,7 @@ EXPORT_SYMBOL(f_setown);
 
 void f_delown(struct file *filp)
 {
-	f_modown(filp, NULL, PIDTYPE_PID, 1);
+	f_modown(filp, NULL, PIDTYPE_PID, current_uid(), current_euid(), 1);
 }
 
 pid_t f_getown(struct file *filp)
-- 
1.6.0.4
