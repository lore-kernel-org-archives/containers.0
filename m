From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][Option 2] Introduce ioprio class for top layer.
Date: Wed, 12 Nov 2008 17:37:59 +0900
Message-ID: <002701c944a1$f7954c70$e6bfe550$__25276.3458913707$1226481434$gmane$org@jp.nec.com>
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

From c13547c5758479116b6dcf10c58d0ef4f058351e Mon Sep 17 00:00:00 2001
From: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Date: Fri, 7 Nov 2008 19:21:19 +0900
Subject: [PATCH][cfq-cgroups] Introduce ioprio class for top layer.

  This patch introduces iprio class for cfq data control layer.
  By applying this patch, controller can also handle the RT/IDLE properties
  among groups.

    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |  344 +++++++++++++++++++++++++------------------
 include/linux/cfq-iosched.h |    1 +
 2 files changed, 203 insertions(+), 142 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index bb8cb6f..993a3b6 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -20,11 +20,24 @@
 
 static const int cfq_cgroup_slice = HZ / 10;
 
+/*
+ * offset from end of service tree
+ */
+#define CFQ_CGROUP_IDLE_DELAY		(HZ / 5)
+
+#define cfq_data_class_idle(cfqd)				\
+		((cfqd)->ioprio_class == IOPRIO_CLASS_IDLE)
+#define cfq_data_class_rt(cfqd)					\
+		((cfqd)->ioprio_class == IOPRIO_CLASS_RT)
+
+
+
 static struct cfq_ops cfq_cgroup_op;
 
 struct cfq_cgroup {
 	struct cgroup_subsys_state css;
 	unsigned int ioprio;
+	unsigned short ioprio_class;
 
 	struct rb_root sibling_tree;
 	unsigned int siblings;
@@ -161,6 +174,7 @@ static void *cfq_cgroup_init_cfq_data(struct cfq_cgroup *cfqc,
 		cfqc = cgroup_to_cfq_cgroup(get_root_subsys(&cfq_subsys));
 		cfq_cgroup_sibling_tree_add(cfqc, cfqd);
 		cfqd->ioprio = cfqc->ioprio;
+		cfqd->ioprio_class = cfqc->ioprio_class;
 	} else {
 		struct cfq_data *__cfqd;
 		__cfqd = __cfq_cgroup_init_queue(cfqd->cfqdd->queue,
@@ -168,7 +182,7 @@ static void *cfq_cgroup_init_cfq_data(struct cfq_cgroup *cfqc,
 		if (!__cfqd)
 			return NULL;
 		cfq_cgroup_sibling_tree_add(cfqc, __cfqd);
-		__cfqd->ioprio = cfqc->ioprio;
+		__cfqd->ioprio_class = cfqc->ioprio_class;
 	}
 
 	/* check and create cfq_data for children */
@@ -250,6 +264,7 @@ cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		return ERR_PTR(-ENOMEM);
 
 	cfqc->ioprio = 3;
+	cfqc->ioprio = IOPRIO_CLASS_BE;
 
 	cfqc->sibling_tree = RB_ROOT;
 	cfqc->siblings = 0;
@@ -378,7 +393,15 @@ static void cfq_cgroup_service_tree_add(struct cfq_data *cfqd, int add_front)
 	unsigned long rb_key;
 	int left;
 
-	if (!add_front) {
+	if (cfq_data_class_idle(cfqd)) {
+		rb_key = CFQ_CGROUP_IDLE_DELAY;
+		parent = rb_last(&cfqdd->service_tree.rb);
+		if (parent && parent != &cfqd->rb_node) {
+			__cfqd = rb_entry(parent, struct cfq_data, rb_node);
+			rb_key += __cfqd->rb_key;
+		} else
+			rb_key += jiffies;
+	} else if (!add_front) {
 		rb_key = cfq_cgroup_slice_offset(cfqd) + jiffies;
 		rb_key += cfqd->slice_resid;
 		cfqd->slice_resid = 0;
@@ -400,7 +423,23 @@ static void cfq_cgroup_service_tree_add(struct cfq_data *cfqd, int add_front)
 		parent = *p;
 		__cfqd = rb_entry(parent, struct cfq_data, rb_node);
 
-		if (rb_key < __cfqd->rb_key)
+
+		/*
+		 * sort RT cfq_data first, we always want to give
+		 * preference to them. IDLE cfq_data goes to the back.
+		 * after that, sort on the next service time.
+		 */
+		if (cfq_data_class_rt(cfqd) > cfq_data_class_rt(__cfqd))
+			n = &(*p)->rb_left;
+		else if (cfq_data_class_rt(cfqd) < cfq_data_class_rt(__cfqd))
+			n = &(*p)->rb_right;
+		else if (cfq_data_class_idle(cfqd) <
+					cfq_data_class_idle(__cfqd))
+			n = &(*p)->rb_left;
+		else if (cfq_data_class_idle(cfqd) >
+					cfq_data_class_idle(__cfqd))
+			n = &(*p)->rb_right;
+		else if (rb_key < __cfqd->rb_key)
 			n = &(*p)->rb_left;
 		else
 			n = &(*p)->rb_right;
@@ -542,6 +579,14 @@ int cfq_cgroup_dispatch_requests(struct request_queue *q, int force)
 	if (cfqd)
 		dispatched = cfq_queue_dispatch_requests(cfqd, force);
 
+	/*
+	 * idle cfq_data always expire after 1 dispatch round.
+	 */
+	if (cfqdd->busy_data > 1 && cfq_data_class_idle(cfqd)) {
+		cfqd->slice_end = jiffies + 1;
+		cfq_cgroup_slice_expired(cfqdd, 0);
+	}
+
 	return dispatched;
 }
 
@@ -699,149 +744,164 @@ param_separate(const char *master, char *valbuf, char *pathbuf,  int size)
 	*pc2 = '\0';
 }
 
-static ssize_t cfq_cgroup_read(struct cgroup *cont, struct cftype *cft,
-			       struct file *file, char __user *userbuf,
-			       size_t nbytes, loff_t *ppos)
-{
-	struct cfq_cgroup *cfqc;
-	char *page;
-	ssize_t ret;
-	struct rb_node *p;
-
-	page = (char *)__get_free_page(GFP_TEMPORARY);
-	if (!page)
-		return -ENOMEM;
-
-	cgroup_lock();
-	if (cgroup_is_removed(cont)) {
-		cgroup_unlock();
-		ret = -ENODEV;
-		goto out;
-	}
-
-	cfqc = cgroup_to_cfq_cgroup(cont);
-
-	cgroup_unlock();
-
-	/* print priority */
-	ret = snprintf(page, PAGE_SIZE, "default priority: %d\n", cfqc->ioprio);
-
-	p = rb_first(&cfqc->sibling_tree);
-	while (p) {
-		struct cfq_data *__cfqd;
-
-		__cfqd = rb_entry(p, struct cfq_data, group_node);
-
-		ret += snprintf(page + ret, PAGE_SIZE - ret, " %s %d\n",
-			       __cfqd->cfqdd->queue->kobj.parent->name,
-			       __cfqd->ioprio);
-
-		p = rb_next(p);
-	}
 
-	ret = simple_read_from_buffer(userbuf, nbytes, ppos, page, ret);
-
-out:
-	free_page((unsigned long)page);
-	return ret;
+#define READ_FUNCTION(__FUNC, __VAR, __DEF_MSG)				\
+static ssize_t __FUNC(struct cgroup *cont, struct cftype *cft,		\
+			struct file *file, char __user *userbuf,	\
+			size_t nbytes, loff_t *ppos)			\
+{									\
+	struct cfq_cgroup *cfqc;					\
+	char *page;							\
+	ssize_t ret;							\
+	struct rb_node *p;						\
+									\
+	page = (char *)__get_free_page(GFP_TEMPORARY);			\
+	if (!page)							\
+		return -ENOMEM;						\
+									\
+	cgroup_lock();							\
+	if (cgroup_is_removed(cont)) {					\
+		cgroup_unlock();					\
+		ret = -ENODEV;						\
+		goto out;						\
+	}								\
+									\
+	cfqc = cgroup_to_cfq_cgroup(cont);				\
+									\
+	cgroup_unlock();						\
+									\
+	/* print */							\
+	ret = snprintf(page, PAGE_SIZE, "default " __DEF_MSG ": %d\n",	\
+			cfqc->__VAR);					\
+									\
+	p = rb_first(&cfqc->sibling_tree);				\
+	while (p) {							\
+		struct cfq_data *__cfqd;				\
+									\
+		__cfqd = rb_entry(p, struct cfq_data, group_node);	\
+									\
+		ret += snprintf(page + ret, PAGE_SIZE - ret, " %s %d\n",\
+			       __cfqd->cfqdd->queue->kobj.parent->name,	\
+			       __cfqd->__VAR);				\
+									\
+		p = rb_next(p);						\
+	}								\
+									\
+	ret = simple_read_from_buffer(userbuf, nbytes, ppos, page, ret);\
+									\
+out:									\
+	free_page((unsigned long)page);					\
+	return ret;							\
 }
-
-static ssize_t cfq_cgroup_write(struct cgroup *cont, struct cftype *cft,
-				struct file *file, const char __user *userbuf,
-				size_t nbytes, loff_t *ppos)
-{
-	struct cfq_cgroup *cfqc;
-	ssize_t ret;
-	long new_prio;
-	int err, sn;
-	char *buffer = NULL;
-	char *valbuf = NULL, *pathbuf = NULL;
-	struct rb_node *p;
-
-	cgroup_lock();
-	if (cgroup_is_removed(cont)) {
-		cgroup_unlock();
-		ret = -ENODEV;
-		goto out;
-	}
-
-	cfqc = cgroup_to_cfq_cgroup(cont);
-	cgroup_unlock();
-
-	/* set priority */
-	buffer = kmalloc(nbytes + 1, GFP_KERNEL);
-	if (buffer == NULL)
-		return -ENOMEM;
-
-	if (copy_from_user(buffer, userbuf, nbytes)) {
-		ret = -EFAULT;
-		goto free_buf;
-	}
-	buffer[nbytes] = 0;
-
-	valbuf = kmalloc(nbytes + 1, GFP_KERNEL);
-	if (!valbuf) {
-		ret = -ENOMEM;
-		goto free_buf;
-	}
-
-	pathbuf = kmalloc(nbytes + 1, GFP_KERNEL);
-	if (!pathbuf) {
-		ret = -ENOMEM;
-		goto free_val;
-	}
-
-	param_separate(buffer, valbuf, pathbuf, nbytes);
-
-	err = strict_strtoul(valbuf, 10, &new_prio);
-	if ((err) || ((new_prio < 0) || (new_prio > CFQ_CGROUP_MAX_IOPRIO))) {
-		ret = -EINVAL;
-		goto free_path;
-	}
-
-	sn = strlen(pathbuf);
-
-	p = rb_first(&cfqc->sibling_tree);
-	while (p) {
-		struct cfq_data *__cfqd;
-		const char *namep;
-
-		__cfqd = rb_entry(p, struct cfq_data, group_node);
-		namep = __cfqd->cfqdd->queue->kobj.parent->name;
-
-		if (sn == 0) {
-			__cfqd->ioprio = new_prio;
-		} else if ((sn == strlen(namep)) &&
-			 (strncmp(pathbuf, namep, sn) == 0)) {
-			__cfqd->ioprio = new_prio;
-			break;
-		}
-
-		p = rb_next(p);
-	}
-
-	if ((sn == 0) ||
-	    ((sn == 7) && (strncmp(pathbuf, "default", 7) == 0)))
-		cfqc->ioprio = new_prio;
-
-	ret = nbytes;
-
-free_path:
-	kfree(pathbuf);
-free_val:
-	kfree(valbuf);
-free_buf:
-	kfree(buffer);
-out:
-	return ret;
+READ_FUNCTION(cfq_cgroup_ioprio_read, ioprio, "priority");
+READ_FUNCTION(cfq_cgroup_ioprio_class_read, ioprio_class, "priority class");
+#undef READ_FUNCTION
+
+#define WRITE_FUNCTION(__FUNC, __VAR, MIN, MAX)				\
+static ssize_t __FUNC(struct cgroup *cont, struct cftype *cft,		\
+			struct file *file, const char __user *userbuf,	\
+			size_t nbytes, loff_t *ppos)			\
+{									\
+	struct cfq_cgroup *cfqc;					\
+	ssize_t ret;							\
+	long new_val;							\
+	int err, sn;							\
+	char *buffer = NULL;						\
+	char *valbuf = NULL, *pathbuf = NULL;				\
+	struct rb_node *p;						\
+									\
+	cgroup_lock();							\
+	if (cgroup_is_removed(cont)) {					\
+		cgroup_unlock();					\
+		ret = -ENODEV;						\
+		goto out;						\
+	}								\
+									\
+	cfqc = cgroup_to_cfq_cgroup(cont);				\
+	cgroup_unlock();						\
+									\
+	/* set */							\
+	buffer = kmalloc(nbytes + 1, GFP_KERNEL);			\
+	if (buffer == NULL)						\
+		return -ENOMEM;						\
+									\
+	if (copy_from_user(buffer, userbuf, nbytes)) {			\
+		ret = -EFAULT;						\
+		goto free_buf;						\
+	}								\
+	buffer[nbytes] = 0;						\
+									\
+	valbuf = kmalloc(nbytes + 1, GFP_KERNEL);			\
+	if (!valbuf) {							\
+		ret = -ENOMEM;						\
+		goto free_buf;						\
+	}								\
+									\
+	pathbuf = kmalloc(nbytes + 1, GFP_KERNEL);			\
+	if (!pathbuf) {							\
+		ret = -ENOMEM;						\
+		goto free_val;						\
+	}								\
+									\
+	param_separate(buffer, valbuf, pathbuf, nbytes);		\
+									\
+	err = strict_strtoul(valbuf, 10, &new_val);			\
+	if ((err) || ((new_val < (MIN)) || (new_val > (MAX)))) {	\
+		ret = -EINVAL;						\
+		goto free_path;						\
+	}								\
+									\
+	sn = strlen(pathbuf);						\
+									\
+	p = rb_first(&cfqc->sibling_tree);				\
+	while (p) {							\
+		struct cfq_data *__cfqd;				\
+		const char *namep;					\
+									\
+		__cfqd = rb_entry(p, struct cfq_data, group_node);	\
+		namep = __cfqd->cfqdd->queue->kobj.parent->name;	\
+									\
+		if (sn == 0) {						\
+			__cfqd->__VAR = new_val;			\
+		} else if ((sn == strlen(namep)) &&			\
+			 (strncmp(pathbuf, namep, sn) == 0)) {		\
+			__cfqd->__VAR = new_val;			\
+			break;						\
+		}							\
+									\
+		p = rb_next(p);						\
+	}								\
+									\
+	if ((sn == 0) ||						\
+	    ((sn == 7) && (strncmp(pathbuf, "default", 7) == 0)))	\
+		cfqc->__VAR = new_val;					\
+									\
+	ret = nbytes;							\
+									\
+free_path:								\
+	kfree(pathbuf);							\
+free_val:								\
+	kfree(valbuf);							\
+free_buf:								\
+	kfree(buffer);							\
+out:									\
+	return ret;							\
 }
+WRITE_FUNCTION(cfq_cgroup_ioprio_write, ioprio, 0, CFQ_CGROUP_MAX_IOPRIO);
+WRITE_FUNCTION(cfq_cgroup_ioprio_class_write, ioprio_class, 0,
+							IOPRIO_CLASS_IDLE);
+#undef WRITE_FUNCTION
+
+#define CFQ_CGROUP_CTYPE_ATTR(_name)			\
+	{						\
+		.name = (__stringify(_name)),		\
+		.read = cfq_cgroup_##_name##_read,	\
+		.write = cfq_cgroup_##_name##_write,	\
+	}
 
 static struct cftype files[] = {
-	{
-		.name = "ioprio",
-		.read = cfq_cgroup_read,
-		.write = cfq_cgroup_write,
-	},
+	CFQ_CGROUP_CTYPE_ATTR(ioprio),
+	CFQ_CGROUP_CTYPE_ATTR(ioprio_class),
 };
 
 static int cfq_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index 920bcb5..ca04ebd 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -102,6 +102,7 @@ struct cfq_data {
 
 #ifdef CONFIG_IOSCHED_CFQ_CGROUP
 	unsigned int ioprio;
+	unsigned short ioprio_class;
 
 	/* sibling_tree member for cfq_meta_data */
 	struct rb_node sib_node;
-- 
1.5.6.5
