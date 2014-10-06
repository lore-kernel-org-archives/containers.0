From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V5 11/13] audit: emit AUDIT_NS_INFO record with
	AUDIT_VIRT_CONTROL record
Date: Mon,  6 Oct 2014 01:08:36 -0400
Message-ID: <ad90efa917cfa5995421d36c84754f05e1934c53.1412543112.git.rgb__34742.7763780162$1412572246$gmane$org@redhat.com>
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

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/uapi/linux/audit.h |    2 ++
 kernel/audit.c             |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index 7ec7209..beb23f7 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -163,6 +163,8 @@
 
 #define AUDIT_KERNEL		2000	/* Asynchronous audit record. NOT A REQUEST. */
 
+#define AUDIT_VIRT_CONTROL	2500	/* Start, Pause, Stop VM */
+
 /* Rule flags */
 #define AUDIT_FILTER_USER	0x00	/* Apply rule to user-generated messages */
 #define AUDIT_FILTER_TASK	0x01	/* Apply rule at task creation (not syscall) */
diff --git a/kernel/audit.c b/kernel/audit.c
index 84590d1..5404c24 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -941,6 +941,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			}
 			audit_set_portid(ab, NETLINK_CB(skb).portid);
 			audit_log_end(ab);
+			if (msg_type == AUDIT_VIRT_CONTROL)
+				audit_log_ns_info(NULL);
 			mutex_lock(&audit_cmd_mutex);
 		}
 		break;
-- 
1.7.1
