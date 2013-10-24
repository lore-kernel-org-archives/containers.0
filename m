From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 10/20] audit: allow un-init audit ns to change pid and portid
	only
Date: Thu, 24 Oct 2013 15:31:55 +0800
Message-ID: <1382599925-25143-11-git-send-email-gaofeng__22912.6899656423$1382599970$gmane$org@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1382599925-25143-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: toshi.okajima-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Only these two vars are namespace aware.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index d7a0993..2132929 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -685,16 +685,6 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (nlh->nlmsg_len < sizeof(struct audit_status))
 			return -EINVAL;
 		status_get   = (struct audit_status *)data;
-		if (status_get->mask & AUDIT_STATUS_ENABLED) {
-			err = audit_set_enabled(status_get->enabled);
-			if (err < 0)
-				return err;
-		}
-		if (status_get->mask & AUDIT_STATUS_FAILURE) {
-			err = audit_set_failure(status_get->failure);
-			if (err < 0)
-				return err;
-		}
 		if (status_get->mask & AUDIT_STATUS_PID) {
 			int new_pid = status_get->pid;
 			struct task_struct *task;
@@ -713,6 +703,22 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			init_audit_ns.portid = NETLINK_CB(skb).portid;
 		}
+
+		/* Right now, only audit_pid and audit_portid are namesapce
+		 * aware. */
+		if (ns != &init_audit_ns)
+			return -EPERM;
+
+		if (status_get->mask & AUDIT_STATUS_ENABLED) {
+			err = audit_set_enabled(status_get->enabled);
+			if (err < 0)
+				return err;
+		}
+		if (status_get->mask & AUDIT_STATUS_FAILURE) {
+			err = audit_set_failure(status_get->failure);
+			if (err < 0)
+				return err;
+		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
 			err = audit_set_rate_limit(status_get->rate_limit);
 			if (err < 0)
-- 
1.8.3.1
