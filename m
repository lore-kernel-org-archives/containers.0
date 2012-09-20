From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 06/27] audit: Simply AUDIT_TTY_SET and AUDIT_TTY_GET
Date: Wed, 19 Sep 2012 18:52:08 -0700
Message-ID: <1348105949-25454-6-git-send-email-ebiederm@xmission.com>
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

Use current instead of looking up the current up the current task by
process identifier.  Netlink requests are processed in trhe context of
the sending task so this is safe.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/audit.c |   38 +++++++++++++-------------------------
 1 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 58f704b..2a8728f 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -866,41 +866,29 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		break;
 	case AUDIT_TTY_GET: {
 		struct audit_tty_status s;
-		struct task_struct *tsk;
-		unsigned long flags;
-
-		rcu_read_lock();
-		tsk = find_task_by_vpid(pid);
-		if (tsk && lock_task_sighand(tsk, &flags)) {
-			s.enabled = tsk->signal->audit_tty != 0;
-			unlock_task_sighand(tsk, &flags);
-		} else
-			err = -ESRCH;
-		rcu_read_unlock();
-
-		if (!err)
-			audit_send_reply(NETLINK_CB(skb).pid, seq,
-					 AUDIT_TTY_GET, 0, 0, &s, sizeof(s));
+		struct task_struct *tsk = current;
+
+		spin_lock_irq(&tsk->sighand->siglock);
+		s.enabled = tsk->signal->audit_tty != 0;
+		spin_unlock_irq(&tsk->sighand->siglock);
+
+		audit_send_reply(NETLINK_CB(skb).pid, seq,
+				 AUDIT_TTY_GET, 0, 0, &s, sizeof(s));
 		break;
 	}
 	case AUDIT_TTY_SET: {
 		struct audit_tty_status *s;
-		struct task_struct *tsk;
-		unsigned long flags;
+		struct task_struct *tsk = current;
 
 		if (nlh->nlmsg_len < sizeof(struct audit_tty_status))
 			return -EINVAL;
 		s = data;
 		if (s->enabled != 0 && s->enabled != 1)
 			return -EINVAL;
-		rcu_read_lock();
-		tsk = find_task_by_vpid(pid);
-		if (tsk && lock_task_sighand(tsk, &flags)) {
-			tsk->signal->audit_tty = s->enabled != 0;
-			unlock_task_sighand(tsk, &flags);
-		} else
-			err = -ESRCH;
-		rcu_read_unlock();
+
+		spin_lock_irq(&tsk->sighand->siglock);
+		tsk->signal->audit_tty = s->enabled != 0;
+		spin_unlock_irq(&tsk->sighand->siglock);
 		break;
 	}
 	default:
-- 
1.7.5.4
