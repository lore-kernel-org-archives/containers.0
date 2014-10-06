From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V5 07/13] audit: dump namespace IDs for pid on receipt of
	AUDIT_NS_INFO
Date: Mon,  6 Oct 2014 01:08:32 -0400
Message-ID: <2503a41768e92791f9901e8ee7c132634821a2db.1412543112.git.rgb@redhat.com>
References: <cover.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

When a task with CAP_AUDIT_CONTROL sends a NETLINK_AUDIT message of type
AUDIT_NS_INFO with a PID of interest, dump the namespace IDs of that task to
the audit log.
---
 kernel/audit.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index a17a09f..cc63445 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -671,6 +671,7 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 	case AUDIT_TTY_SET:
 	case AUDIT_TRIM:
 	case AUDIT_MAKE_EQUIV:
+	case AUDIT_NS_INFO:
 		/* Only support auditd and auditctl in initial pid namespace
 		 * for now. */
 		if ((task_active_pid_ns(current) != &init_pid_ns))
@@ -1068,6 +1069,19 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		audit_log_end(ab);
 		break;
 	}
+	case AUDIT_NS_INFO:
+#ifdef CONFIG_NAMESPACES
+	{
+		struct task_struct *tsk;
+
+		rcu_read_lock();
+		tsk = find_task_by_vpid(*(pid_t *)data);
+		rcu_read_unlock();
+		audit_log_ns_info(tsk);
+	}
+#else /* CONFIG_NAMESPACES */
+		err = -EOPNOTSUPP;
+#endif /* CONFIG_NAMESPACES */
 	default:
 		err = -EINVAL;
 		break;
-- 
1.7.1
