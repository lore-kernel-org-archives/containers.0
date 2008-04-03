From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [RFC][patch 6/12][CFQ-cgroup] Add cfq optional operation framework
Date: Thu, 3 Apr 2008 16:14:39 +0900
Message-ID: <006301c8955a$61b66dc0$25234940$__34591.1449440338$1207207002$gmane$org@jp.nec.com>
References: <007801c893d9$d89726f0$89c574d0$@jp.nec.com>		<008001c893db$4e2eccf0$ea8c66d0$@jp.nec.com>	<6599ad830804021541s3c1e3197y77d87f63bf47e4b3@mail.gmail.com>
	<005d01c89559$9e538200$dafa8600$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <005d01c89559$9e538200$dafa8600$@jp.nec.com>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Satoshi UCHIDA' <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>, 'Paul Menage' <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

This patch creates a cfq optional operations framework.
This framework defines specific functions for expanding CFQ.

      Signed-off-by: Satoshi UCHIDA <uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |    4 ++++
 block/cfq-iosched.c         |    5 +++++
 include/linux/cfq-iosched.h |    6 ++++++
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index 378a23d..bcb55c8 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -151,3 +151,7 @@ struct cgroup_subsys cfq_subsys = {
 	.subsys_id = cfq_subsys_id,
 	.populate = cfq_cgroup_populate,
 };
+
+
+struct cfq_ops opt = {
+};
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index aaf5d7e..245c252 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2233,6 +2233,11 @@ static void __exit cfq_exit(void)
 module_init(cfq_init);
 module_exit(cfq_exit);
 
+#ifndef CONFIG_CGROUP_CFQ
+struct cfq_ops opt = {
+};
+#endif
+
 MODULE_AUTHOR("Jens Axboe");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Completely Fair Queueing IO scheduler");
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index 035bfc4..9287da1 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -87,4 +87,10 @@ static inline struct request_queue * __cfq_container_of_queue(struct work_struct
 	return cfqd->cfq_driv_d.queue;
 };
 
+struct cfq_ops
+{
+};
+
+extern struct cfq_ops opt;
+
 #endif  /* _LINUX_CFQ_IOSCHED_H */
-- 
1.5.4.1
