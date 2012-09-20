From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 05/27] audit: kill audit_prepare_user_tty
Date: Wed, 19 Sep 2012 18:52:07 -0700
Message-ID: <1348105949-25454-5-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Now that netlink messages are processed in the context of the sender
tty_audit_push_task can be called directly and audit_prepare_user_tty
which only added looking up the task of the tty by process id is
not needed.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/audit.c |   20 +-------------------
 1 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index fecb150..58f704b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -468,24 +468,6 @@ static int kauditd_thread(void *dummy)
 	return 0;
 }
 
-static int audit_prepare_user_tty(pid_t pid, uid_t loginuid, u32 sessionid)
-{
-	struct task_struct *tsk;
-	int err;
-
-	rcu_read_lock();
-	tsk = find_task_by_vpid(pid);
-	if (!tsk) {
-		rcu_read_unlock();
-		return -ESRCH;
-	}
-	get_task_struct(tsk);
-	rcu_read_unlock();
-	err = tty_audit_push_task(tsk, loginuid, sessionid);
-	put_task_struct(tsk);
-	return err;
-}
-
 int audit_send_list(void *_dest)
 {
 	struct audit_netlink_list *dest = _dest;
@@ -748,7 +730,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (err == 1) {
 			err = 0;
 			if (msg_type == AUDIT_USER_TTY) {
-				err = audit_prepare_user_tty(pid, loginuid,
+				err = tty_audit_push_task(current, loginuid,
 							     sessionid);
 				if (err)
 					break;
-- 
1.7.5.4
