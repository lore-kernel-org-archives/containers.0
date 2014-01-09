From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH audit-next 2/2] Audit: make audit netlink socket net namespace
	unaware
Date: Thu, 9 Jan 2014 17:11:31 +0800
Message-ID: <1389258691-2680-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1389258691-2680-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1389258691-2680-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Add a compare function which always return true for
audit netlink socket, this will cause audit netlink
sockets netns unaware, and no matter which netns the
user space audit netlink sockets belong to, they all
can find out and communicate with audit_sock.

This gets rid of the necessary to create per-netns
audit kernel side socket(audit_sock), it's pain to
depend on and get reference of netns for auditns.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/kernel/audit.c b/kernel/audit.c
index b62153a..2ac6212 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1064,12 +1064,18 @@ static void audit_receive(struct sk_buff  *skb)
 	mutex_unlock(&audit_cmd_mutex);
 }
 
+static bool audit_compare(struct net *net, struct sock *sk)
+{
+	return true;
+}
+
 /* Initialize audit support at boot time. */
 static int __init audit_init(void)
 {
 	int i;
 	struct netlink_kernel_cfg cfg = {
 		.input	= audit_receive,
+		.compare = audit_compare,
 	};
 
 	if (audit_initialized == AUDIT_DISABLED)
-- 
1.8.4.2
