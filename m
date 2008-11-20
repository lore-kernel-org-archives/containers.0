From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 4/7] enables bio-cgroup in io-throttle, have to mount together
Date: Thu, 20 Nov 2008 19:12:23 +0800
Message-ID: <49254617.2090409__31914.5406749614$1227179879$gmane$org@cn.fujitsu.com>
References: <4925445C.10302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4925445C.10302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch enables bio-cgroup in io-throttle, but you have to mount them together.

Signed-of-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/blk-io-throttle.c    |    7 +++++--
 include/linux/biotrack.h   |    2 ++
 include/linux/memcontrol.h |    3 ---
 init/Kconfig               |    2 +-
 mm/biotrack.c              |   35 +++++++++++++++++++++++++++++++++++
 mm/memcontrol.c            |   30 ------------------------------
 6 files changed, 43 insertions(+), 36 deletions(-)

diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
index bb27587..e6a0a03 100644
--- a/block/blk-io-throttle.c
+++ b/block/blk-io-throttle.c
@@ -22,7 +22,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/res_counter.h>
-#include <linux/memcontrol.h>
+#include <linux/biotrack.h>
 #include <linux/slab.h>
 #include <linux/gfp.h>
 #include <linux/err.h>
@@ -649,7 +649,10 @@ static struct iothrottle *get_iothrottle_from_page(struct page *page)
 	if (!cgrp)
 		return NULL;
 	iot = cgroup_to_iothrottle(cgrp);
-	css_get(&iot->css);
+	if (iot)
+		css_get(&iot->css);
+	else
+		return NULL;
 	put_cgroup_from_page(page);
 
 	return iot;
diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
index d352abd..371d263 100644
--- a/include/linux/biotrack.h
+++ b/include/linux/biotrack.h
@@ -21,6 +21,8 @@ static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
 {
 	pc->bio_cgroup_id = 0;
 }
+extern struct cgroup *get_cgroup_from_page(struct page *page);
+extern void put_cgroup_from_page(struct page *page);
 
 static inline int bio_cgroup_disabled(void)
 {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 009e5e4..a7e3dc2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -49,9 +49,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
-extern struct cgroup *get_cgroup_from_page(struct page *page);
-extern void put_cgroup_from_page(struct page *page);
-
 #define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
diff --git a/init/Kconfig b/init/Kconfig
index 06649c5..4082e8e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -315,7 +315,7 @@ config CGROUP_DEVICE
 
 config CGROUP_IO_THROTTLE
 	bool "Enable cgroup I/O throttling (EXPERIMENTAL)"
-	depends on CGROUPS && CGROUP_MEM_RES_CTLR && RESOURCE_COUNTERS && EXPERIMENTAL
+	depends on CGROUPS && CGROUP_BIO && RESOURCE_COUNTERS && EXPERIMENTAL
 	help
 	  This allows to limit the maximum I/O bandwidth for specific
 	  cgroup(s).
diff --git a/mm/biotrack.c b/mm/biotrack.c
index 1af5910..ba6b45b 100644
--- a/mm/biotrack.c
+++ b/mm/biotrack.c
@@ -213,6 +213,41 @@ static struct bio_cgroup *find_bio_cgroup(int id)
 	return biog;
 }
 
+struct cgroup *get_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct bio_cgroup *biog;
+	struct cgroup *cgrp = NULL;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		biog = find_bio_cgroup(pc->bio_cgroup_id);
+		if (biog) {
+			css_get(&biog->css);
+			cgrp = biog->css.cgroup;
+		}
+		unlock_page_cgroup(pc);
+	}
+
+	return cgrp;
+}
+
+void put_cgroup_from_page(struct page *page)
+{
+	struct bio_cgroup *biog;
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		biog = find_bio_cgroup(pc->bio_cgroup_id);
+		if (biog)
+			css_put(&biog->css);
+		unlock_page_cgroup(pc);
+	}
+}
+
 /* Determine the bio-cgroup id of a given bio. */
 int get_bio_cgroup_id(struct bio *bio)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 097278c..95048fe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -241,36 +241,6 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 				struct mem_cgroup, css);
 }
 
-struct cgroup *get_cgroup_from_page(struct page *page)
-{
-	struct page_cgroup *pc;
-	struct cgroup *cgrp = NULL;
-
-	pc = lookup_page_cgroup(page);
-	if (pc) {
-		lock_page_cgroup(pc);
-		if(pc->mem_cgroup) {
-			css_get(&pc->mem_cgroup->css);
-			cgrp = pc->mem_cgroup->css.cgroup;
-		}
-		unlock_page_cgroup(pc);
-	}
-
-	return cgrp;
-}
-
-void put_cgroup_from_page(struct page *page)
-{
-	struct page_cgroup *pc;
-
-	pc = lookup_page_cgroup(page);
-	if (pc) {
-		lock_page_cgroup(pc);
-		css_put(&pc->mem_cgroup->css);
-		unlock_page_cgroup(pc);
-	}
-}
-
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
-- 1.5.4.rc3 
