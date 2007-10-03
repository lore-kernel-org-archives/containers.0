From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] Introduce the res_counter_populate() function
Date: Wed, 03 Oct 2007 14:57:54 +0400
Message-ID: <470375B2.5090100@openvz.org>
References: <470374A7.6030805@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <470374A7.6030805-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This one is responsible for initializing the RES_CFT_MAX files
properly and register them inside the container.

The caller must provide the cgroup, the cgroup_subsys, the
RES_CFT_MAX * sizeof(cftype) chunk of uninitialized memory
and the read and write callbacks.

In the future, if we add more res_counter files, change their
names or anything else, no caller will be affected.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 61363ce..8ee8316 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -58,6 +58,9 @@ ssize_t res_counter_write(struct res_cou
 		const char __user *buf, size_t nbytes, loff_t *pos,
 		int (*write_strategy)(char *buf, unsigned long long *val));
 
+int res_counter_populate(struct cgroup_subsys *ss, struct cgroup *cont,
+		struct cftype files[], cft_read read_fn, cft_write write_fn);
+
 /*
  * the field descriptors. one for each member of res_counter
  */
@@ -66,6 +69,8 @@ enum {
 	RES_USAGE,
 	RES_LIMIT,
 	RES_FAILCNT,
+
+	RES_CFT_MAX,
 };
 
 /*
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d7f43cd..018eb2b 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -10,9 +10,34 @@
 #include <linux/types.h>
 #include <linux/parser.h>
 #include <linux/fs.h>
+#include <linux/cgroup.h>
 #include <linux/res_counter.h>
 #include <linux/uaccess.h>
 
+int res_counter_populate(struct cgroup_subsys *ss, struct cgroup *cont,
+		struct cftype files[], cft_read read_fn, cft_write write_fn)
+{
+	/*
+	 * to be on the safe side
+	 */
+	memset(files, 0, RES_CFT_MAX * sizeof(struct cftype));
+
+	strcpy(files[RES_USAGE].name, "usage_in_bytes");
+	files[RES_USAGE].private = RES_USAGE;
+	files[RES_USAGE].read = read_fn;
+
+	strcpy(files[RES_LIMIT].name, "limit_in_bytes");
+	files[RES_LIMIT].private = RES_LIMIT;
+	files[RES_LIMIT].read = read_fn;
+	files[RES_LIMIT].write = write_fn;
+
+	strcpy(files[RES_FAILCNT].name, "failcnt");
+	files[RES_FAILCNT].private = RES_FAILCNT;
+	files[RES_FAILCNT].read = read_fn;
+
+	return cgroup_add_files(cont, ss, files, RES_CFT_MAX);
+}
+
 void res_counter_init(struct res_counter *counter)
 {
 	spin_lock_init(&counter->lock);
