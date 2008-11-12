From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][07/12] Add sibling tree control for group
	data(cfq_cgroup).
Date: Wed, 12 Nov 2008 17:28:20 +0900
Message-ID: <001401c944a0$9e9375d0$dbba6170$__16465.9977461726$1226480404$gmane$org@jp.nec.com>
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


  This patch adds a tree control for siblings of group data(cfq_cgroup).
  This tree controls cfq data(cfq_data) for same group, and is used mainly
  when a new group is registerecd or a existed group is unregistered.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |  126 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/cfq-iosched.h |    5 ++
 include/linux/cgroup.h      |    1 +
 kernel/cgroup.c             |    5 ++
 4 files changed, 137 insertions(+), 0 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index ce35af2..25da08e 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -22,8 +22,12 @@ static struct cfq_ops cfq_cgroup_op;
 struct cfq_cgroup {
 	struct cgroup_subsys_state css;
 	unsigned int ioprio;
+
+	struct rb_root sibling_tree;
+	unsigned int siblings;
 };
 
+
 static inline struct cfq_cgroup *cgroup_to_cfq_cgroup(struct cgroup *cont)
 {
 	return container_of(cgroup_subsys_state(cont, cfq_subsys_id),
@@ -77,6 +81,68 @@ static void cfq_driver_sibling_tree_add(struct cfq_driver_data *cfqdd,
 	cfqd->cfqdd = cfqdd;
 }
 
+static void cfq_cgroup_sibling_tree_add(struct cfq_cgroup *cfqc,
+					struct cfq_data *cfqd)
+{
+	struct rb_node **p;
+	struct rb_node *parent = NULL;
+
+	BUG_ON(!RB_EMPTY_NODE(&cfqd->group_node));
+
+	p = &cfqc->sibling_tree.rb_node;
+
+	while (*p) {
+		struct cfq_data *__cfqd;
+		struct rb_node **n;
+
+		parent = *p;
+		__cfqd = rb_entry(parent, struct cfq_data, group_node);
+
+		if (cfqd->cfqdd < __cfqd->cfqdd)
+			n = &(*p)->rb_left;
+		else
+			n = &(*p)->rb_right;
+		p = n;
+	}
+
+	rb_link_node(&cfqd->group_node, parent, p);
+	rb_insert_color(&cfqd->group_node, &cfqc->sibling_tree);
+	cfqc->siblings++;
+	cfqd->cfqc = cfqc;
+}
+
+static struct cfq_data *
+__cfq_cgroup_init_queue(struct request_queue *, struct cfq_driver_data *);
+
+static void *cfq_cgroup_init_cfq_data(struct cfq_cgroup *cfqc,
+				       struct cfq_data *cfqd)
+{
+	struct cgroup *child;
+
+	/* setting cfq_data for cfq_cgroup */
+	if (!cfqc) {
+		cfqc = cgroup_to_cfq_cgroup(get_root_subsys(&cfq_subsys));
+		cfq_cgroup_sibling_tree_add(cfqc, cfqd);
+	} else {
+		struct cfq_data *__cfqd;
+		__cfqd = __cfq_cgroup_init_queue(cfqd->cfqdd->queue,
+						 cfqd->cfqdd);
+		if (!__cfqd)
+			return NULL;
+		cfq_cgroup_sibling_tree_add(cfqc, __cfqd);
+	}
+
+	/* check and create cfq_data for children */
+	if (cfqc->css.cgroup)
+		list_for_each_entry(child, &cfqc->css.cgroup->children,
+				    sibling){
+			cfq_cgroup_init_cfq_data(cgroup_to_cfq_cgroup(child),
+						 cfqd);
+		}
+
+	return cfqc;
+}
+
 static struct cfq_data *
 __cfq_cgroup_init_queue(struct request_queue *q, struct cfq_driver_data *cfqdd)
 {
@@ -86,9 +152,13 @@ __cfq_cgroup_init_queue(struct request_queue *q, struct cfq_driver_data *cfqdd)
 		return NULL;
 
 	RB_CLEAR_NODE(&cfqd->sib_node);
+	RB_CLEAR_NODE(&cfqd->group_node);
 
 	cfq_driver_sibling_tree_add(cfqd->cfqdd, cfqd);
 
+	if (!cfqdd)
+		cfq_cgroup_init_cfq_data(NULL, cfqd);
+
 	return cfqd;
 }
 
@@ -101,6 +171,28 @@ static void *cfq_cgroup_init_queue(struct request_queue *q)
 	return cfqd;
 }
 
+static void *cfq_cgroup_init_cgroup(struct cfq_cgroup *cfqc,
+					struct cgroup *parent)
+{
+	struct rb_node *p;
+	if (parent) {
+		struct cfq_cgroup *cfqc_p = cgroup_to_cfq_cgroup(parent);
+
+		p = rb_first(&cfqc_p->sibling_tree);
+		while (p) {
+			struct cfq_data *__cfqd;
+			__cfqd = rb_entry(p, struct cfq_data, group_node);
+
+			cfq_cgroup_init_cfq_data(cfqc, __cfqd);
+
+			p = rb_next(p);
+		}
+	}
+
+	return cfqc;
+}
+
+
 static struct cgroup_subsys_state *
 cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -118,6 +210,12 @@ cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 
 	cfqc->ioprio = 3;
 
+	cfqc->sibling_tree = RB_ROOT;
+	cfqc->siblings = 0;
+
+	if (!cfq_cgroup_init_cgroup(cfqc, cont->parent))
+		return ERR_PTR(-ENOMEM);
+
 	return &cfqc->css;
 }
 
@@ -132,6 +230,13 @@ static void cfq_cgroup_erase_driver_siblings(struct cfq_driver_data *cfqdd,
 	cfqdd->siblings--;
 }
 
+static void cfq_cgroup_erase_cgroup_siblings(struct cfq_cgroup *cfqc,
+					      struct cfq_data *cfqd)
+{
+	rb_erase(&cfqd->group_node, &cfqc->sibling_tree);
+	cfqc->siblings--;
+}
+
 static void cfq_exit_device_group(struct cfq_driver_data *cfqdd)
 {
 	struct rb_node *p, *n;
@@ -144,6 +249,7 @@ static void cfq_exit_device_group(struct cfq_driver_data *cfqdd)
 		cfqd = rb_entry(p, struct cfq_data, sib_node);
 
 		cfq_cgroup_erase_driver_siblings(cfqdd, cfqd);
+		cfq_cgroup_erase_cgroup_siblings(cfqd->cfqc, cfqd);
 		cfq_free_cfq_data(cfqd);
 
 		p = n;
@@ -159,8 +265,28 @@ static void cfq_cgroup_exit_queue(elevator_t *e)
 	kfree(cfqdd);
 }
 
+static void cfq_exit_cgroup(struct cfq_cgroup *cfqc)
+{
+	struct rb_node *p, *n;
+	struct cfq_data *cfqd;
+
+	p =  rb_first(&cfqc->sibling_tree);
+
+	while (p) {
+		n = rb_next(p);
+		cfqd = rb_entry(p, struct cfq_data, group_node);
+
+		cfq_cgroup_erase_driver_siblings(cfqd->cfqdd, cfqd);
+		cfq_cgroup_erase_cgroup_siblings(cfqc, cfqd);
+		cfq_free_cfq_data(cfqd);
+
+		p = n;
+	}
+}
+
 static void cfq_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
 {
+	cfq_exit_cgroup(cgroup_to_cfq_cgroup(cont));
 	kfree(cgroup_to_cfq_cgroup(cont));
 }
 
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index 22d1aed..382fc0a 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -93,6 +93,11 @@ struct cfq_data {
 #ifdef CONFIG_IOSCHED_CFQ_CGROUP
 	/* sibling_tree member for cfq_meta_data */
 	struct rb_node sib_node;
+
+	/* cfq_cgroup attribute */
+	struct cfq_cgroup *cfqc;
+	/* group_tree member for cfq_cgroup */
+	struct rb_node group_node;
 #endif
 };
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8b00f66..4bfd815 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -402,6 +402,7 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
 void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
+struct cgroup *get_root_subsys(struct cgroup_subsys *css);
 
 void cgroup_mm_owner_callbacks(struct task_struct *old,
 			       struct task_struct *new);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 35eebd5..71bb335 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1316,6 +1316,11 @@ static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
 	return ret;
 }
 
+struct cgroup *get_root_subsys(struct cgroup_subsys *css)
+{
+	return &css->root->top_cgroup;
+}
+
 /* The various types of files and directories in a cgroup file system */
 enum cgroup_filetype {
 	FILE_ROOT,
-- 
1.5.6.5
