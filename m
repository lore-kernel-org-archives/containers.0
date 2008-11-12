From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][04/12] Register or unregister "cfq-cgroups"
	module.
Date: Wed, 12 Nov 2008 17:26:18 +0900
Message-ID: <001101c944a0$561b0fc0$02512f40$__33729.8430772082$1226479863$gmane$org@jp.nec.com>
References: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, 'Ryo Tsuruta' <ryov@valin>
Cc: 'Andrew Morton' <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, 'SUGAWARA Tomoyoshi' <tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


  This patch introduce a register/unregister functions of 
  "cfq-cgroups" module.
  A elevator_type variables is inherited one of the original CFQ
  scheduler.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |  122 +++++++++++++++++++++++++++++++++++++++++++
 block/cfq-iosched.c         |    2 +-
 include/linux/cfq-iosched.h |    2 +
 3 files changed, 125 insertions(+), 1 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index 3deef41..aaa00ef 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -15,13 +15,135 @@
 #include <linux/cgroup.h>
 #include <linux/cfq-iosched.h>
 
+/*
+ * sysfs parts below -->
+ */
+static ssize_t
+cfq_cgroup_var_show(char *page, struct cfq_data *cfqd,
+		    int (func)(struct cfq_data *))
+{
+	int val, retval = 0;
+
+	val = func(cfqd);
+
+	retval = snprintf(page, PAGE_SIZE, "%d\n", val);
+
+	return retval;
+}
+
+#define SHOW_FUNCTION(__FUNC, __VAR, __CONV)				\
+static int val_transrate_##__FUNC(struct cfq_data *cfqd)		\
+{									\
+	if (__CONV)							\
+		return jiffies_to_msecs(cfqd->__VAR);			\
+	else								\
+		return cfqd->__VAR;					\
+}									\
+static ssize_t __FUNC(elevator_t *e, char *page)			\
+{									\
+	struct cfq_data *cfqd = e->elevator_data;			\
+									\
+	return cfq_cgroup_var_show((page), (cfqd),			\
+				   val_transrate_##__FUNC);		\
+}
+SHOW_FUNCTION(cfq_cgroup_quantum_show, cfq_quantum, 0);
+SHOW_FUNCTION(cfq_cgroup_fifo_expire_sync_show, cfq_fifo_expire[1], 1);
+SHOW_FUNCTION(cfq_cgroup_fifo_expire_async_show, cfq_fifo_expire[0], 1);
+SHOW_FUNCTION(cfq_cgroup_back_seek_max_show, cfq_back_max, 0);
+SHOW_FUNCTION(cfq_cgroup_back_seek_penalty_show, cfq_back_penalty, 0);
+SHOW_FUNCTION(cfq_cgroup_slice_idle_show, cfq_slice_idle, 1);
+SHOW_FUNCTION(cfq_cgroup_slice_sync_show, cfq_slice[1], 1);
+SHOW_FUNCTION(cfq_cgroup_slice_async_show, cfq_slice[0], 1);
+SHOW_FUNCTION(cfq_cgroup_slice_async_rq_show, cfq_slice_async_rq, 0);
+#undef SHOW_FUNCTION
+
+static ssize_t
+cfq_cgroup_var_store(const char *page, size_t count, struct cfq_data *cfqd,
+		     void (func)(struct cfq_data *, unsigned int))
+{
+	int err;
+	unsigned long val;
+
+	err = strict_strtoul(page, 10, &val);
+	if (err)
+		return 0;
+
+	func(cfqd, val);
+
+	return count;
+}
+
+#define STORE_FUNCTION(__FUNC, __VAR, MIN, MAX, __CONV)			\
+static void val_transrate_##__FUNC(struct cfq_data *cfqd,		\
+				   unsigned int __data)			\
+{									\
+	if (__data < (MIN))						\
+		__data = (MIN);						\
+	else if (__data > (MAX))					\
+		__data = (MAX);						\
+	if (__CONV)							\
+		cfqd->__VAR = msecs_to_jiffies(__data);			\
+	else								\
+		cfqd->__VAR = __data;					\
+}									\
+static ssize_t __FUNC(elevator_t *e, const char *page, size_t count)	\
+{									\
+	struct cfq_data *cfqd = e->elevator_data;			\
+	int ret = cfq_cgroup_var_store((page), count, cfqd,		\
+				      val_transrate_##__FUNC);		\
+	return ret;							\
+}
+STORE_FUNCTION(cfq_cgroup_quantum_store, cfq_quantum, 1, UINT_MAX, 0);
+STORE_FUNCTION(cfq_cgroup_fifo_expire_sync_store, cfq_fifo_expire[1], 1,
+		UINT_MAX, 1);
+STORE_FUNCTION(cfq_cgroup_fifo_expire_async_store, cfq_fifo_expire[0], 1,
+		UINT_MAX, 1);
+STORE_FUNCTION(cfq_cgroup_back_seek_max_store, cfq_back_max, 0, UINT_MAX, 0);
+STORE_FUNCTION(cfq_cgroup_back_seek_penalty_store, cfq_back_penalty, 1,
+		UINT_MAX, 0);
+STORE_FUNCTION(cfq_cgroup_slice_idle_store, cfq_slice_idle,
+		0, UINT_MAX, 1);
+STORE_FUNCTION(cfq_cgroup_slice_sync_store, cfq_slice[1], 1, UINT_MAX, 1);
+STORE_FUNCTION(cfq_cgroup_slice_async_store, cfq_slice[0], 1, UINT_MAX, 1);
+STORE_FUNCTION(cfq_cgroup_slice_async_rq_store, cfq_slice_async_rq, 1,
+		UINT_MAX, 0);
+#undef STORE_FUNCTION
+
+#define CFQ_CGROUP_ATTR(name)					\
+	__ATTR(name, S_IRUGO|S_IWUSR, cfq_cgroup_##name##_show,	\
+	       cfq_cgroup_##name##_store)
+
+static struct elv_fs_entry cfq_cgroup_attrs[] = {
+	CFQ_CGROUP_ATTR(quantum),
+	CFQ_CGROUP_ATTR(fifo_expire_sync),
+	CFQ_CGROUP_ATTR(fifo_expire_async),
+	CFQ_CGROUP_ATTR(back_seek_max),
+	CFQ_CGROUP_ATTR(back_seek_penalty),
+	CFQ_CGROUP_ATTR(slice_sync),
+	CFQ_CGROUP_ATTR(slice_async),
+	CFQ_CGROUP_ATTR(slice_async_rq),
+	CFQ_CGROUP_ATTR(slice_idle),
+	__ATTR_NULL
+};
+
+static struct elevator_type iosched_cfq_cgroup = {
+	.elevator_attrs	= cfq_cgroup_attrs,
+	.elevator_name	= "cfq-cgroups",
+	.elevator_owner	= THIS_MODULE,
+};
+
 static int __init cfq_cgroup_init(void)
 {
+	iosched_cfq_cgroup.ops = iosched_cfq.ops;
+
+	elv_register(&iosched_cfq_cgroup);
+
 	return 0;
 }
 
 static void __exit cfq_cgroup_exit(void)
 {
+	elv_unregister(&iosched_cfq_cgroup);
 }
 
 module_init(cfq_cgroup_init);
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index b726e85..e105827 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2332,7 +2332,7 @@ static struct elv_fs_entry cfq_attrs[] = {
 	__ATTR_NULL
 };
 
-static struct elevator_type iosched_cfq = {
+struct elevator_type iosched_cfq = {
 	.ops = {
 		.elevator_merge_fn = 		cfq_merge,
 		.elevator_merged_fn =		cfq_merged_request,
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index 50003f7..a28ef00 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -82,4 +82,6 @@ struct cfq_data {
 	struct cfq_driver_data *cfqdd;
 };
 
+extern struct elevator_type iosched_cfq;
+
 #endif  /* _LINUX_CFQ_IOSCHED_H */
-- 
1.5.6.5
