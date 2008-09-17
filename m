From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 4/6] memcg: interface to charge the right cgroup of
	asynchronous i/o activity
Date: Wed, 17 Sep 2008 13:05:26 +0200
Message-ID: <1221649528-8519-5-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Implement get_cgroup_from_page() / put_cgroup_from_page() in the cgroup memory
controller used to retrieve the owner of a page during writes in submit_bio()
processed asynchronously by kernel threads (i.e. pdflush).

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/memcontrol.h |    3 +++
 mm/memcontrol.c            |   26 ++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..92dfd40 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -50,6 +50,9 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
+extern struct cgroup *get_cgroup_from_page(struct page *page);
+extern void put_cgroup_from_page(struct page *page);
+
 #define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2979d22..5321b8b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -279,6 +279,32 @@ static void unlock_page_cgroup(struct page *page)
 	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
+struct cgroup *get_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct cgroup *cgrp = NULL;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (pc) {
+		css_get(&pc->mem_cgroup->css);
+		cgrp = pc->mem_cgroup->css.cgroup;
+	}
+	unlock_page_cgroup(page);
+	return cgrp;
+}
+
+void put_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (pc)
+		css_put(&pc->mem_cgroup->css);
+	unlock_page_cgroup(page);
+}
+
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
-- 
1.5.4.3
