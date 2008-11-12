From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][12/12] Interface for parameter of cfq driver data
Date: Wed, 12 Nov 2008 17:31:39 +0900
Message-ID: <001901c944a1$15798a40$406c9ec0$__46765.3247331784$1226481375$gmane$org@jp.nec.com>
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

From 8bdb6a318fbc266cf359aea699c97a964baeff35 Mon Sep 17 00:00:00 2001
From: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Date: Fri, 31 Oct 2008 20:49:57 +0900
Subject: [PATCH][cfq-cgroups] Interface for parameter of cfq driver data

  This patch add a interface for parameter of cfq driver data.
 
 
    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 58 insertions(+), 1 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index 4938fa0..776874d 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -1028,6 +1028,62 @@ STORE_FUNCTION(cfq_cgroup_slice_async_rq_store, cfq_slice_async_rq, 1,
 STORE_FUNCTION(cfq_cgroup_ioprio_store, ioprio, 0, CFQ_CGROUP_MAX_IOPRIO, 0);
 #undef STORE_FUNCTION
 
+static ssize_t
+cfq_cgroup_var_show2(unsigned int var, char *page)
+{
+	return snprintf(page, PAGE_SIZE, "%d\n", var);
+}
+
+static ssize_t
+cfq_cgroup_var_store2(unsigned int *var, const char *page, size_t count)
+{
+	int err;
+	char *p = (char *) page;
+	unsigned long new_var;
+
+	err = strict_strtoul(p, 10, &new_var);
+	if (err)
+		count = 0;
+
+	*var = new_var;
+
+	return count;
+}
+
+#define SHOW_FUNCTION2(__FUNC, __VAR, __CONV)				\
+static ssize_t __FUNC(elevator_t *e, char *page)			\
+{									\
+	struct cfq_data *cfqd = e->elevator_data;			\
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;			\
+	unsigned int __data = __VAR;					\
+	if (__CONV)							\
+		__data = jiffies_to_msecs(__data);			\
+	return cfq_cgroup_var_show2(__data, (page));			\
+}
+SHOW_FUNCTION2(cfq_cgroup_slice_cgroup_show, cfqdd->cfq_cgroup_slice, 1);
+#undef SHOW_FUNCTION2
+
+#define STORE_FUNCTION2(__FUNC, __PTR, MIN, MAX, __CONV)		\
+static ssize_t __FUNC(elevator_t *e, const char *page, size_t count)	\
+{									\
+	struct cfq_data *cfqd = e->elevator_data;			\
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;			\
+	unsigned int __data;						\
+	int ret = cfq_cgroup_var_store2(&__data, (page), count);	\
+	if (__data < (MIN))						\
+		__data = (MIN);						\
+	else if (__data > (MAX))					\
+		__data = (MAX);						\
+	if (__CONV)							\
+		*(__PTR) = msecs_to_jiffies(__data);			\
+	else								\
+		*(__PTR) = __data;					\
+	return ret;							\
+}
+STORE_FUNCTION2(cfq_cgroup_slice_cgroup_store, &cfqdd->cfq_cgroup_slice, 1,
+		UINT_MAX, 1);
+#undef STORE_FUNCTION2
+
 #define CFQ_CGROUP_ATTR(name)					\
 	__ATTR(name, S_IRUGO|S_IWUSR, cfq_cgroup_##name##_show,	\
 	       cfq_cgroup_##name##_store)
@@ -1043,6 +1099,7 @@ static struct elv_fs_entry cfq_cgroup_attrs[] = {
 	CFQ_CGROUP_ATTR(slice_async_rq),
 	CFQ_CGROUP_ATTR(slice_idle),
 	CFQ_CGROUP_ATTR(ioprio),
+	CFQ_CGROUP_ATTR(slice_cgroup),
 	__ATTR_NULL
 };
 
-- 
1.5.6.5
