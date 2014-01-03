From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH net-next 2/4] cls_cgroup: introduce a helper:
	bk_cls_classid()
Date: Fri, 3 Jan 2014 11:11:09 +0800
Message-ID: <52C62A4D.5010000__2569.47819511897$1388718748$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


it can save classid from skb->sk->sk_classid
to skb->bk_classid

Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/net/cls_cgroup.h | 11 +++++++++++
 net/sched/cls_cgroup.c   |  1 -
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 33d03b6..4249ea3 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
+#include <net/sock.h>

 #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 struct cgroup_cls_state
@@ -26,6 +27,12 @@ struct cgroup_cls_state

 void sock_update_classid(struct sock *sk);

+static inline void bk_cls_classid(struct sk_buff *skb)
+{
+	if (skb->sk && skb->sk->sk_classid)
+		skb->backup_classid = skb->sk->sk_classid;
+}
+
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
 {
@@ -61,6 +68,10 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else /* !CGROUP_NET_CLS_CGROUP */
+static inline void bk_cls_classid(struct sk_buff *skb)
+{
+}
+
 static inline void sock_update_classid(struct sock *sk)
 {
 }
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index f9d21258..d228a5d 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -20,7 +20,6 @@
 #include <linux/fdtable.h>
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
-#include <net/sock.h>
 #include <net/cls_cgroup.h>

 static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state *css)
-- 
1.8.2.2
