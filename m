From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][08/12] Interface to new cfq data structure in
	cfq_cgroup module.
Date: Wed, 12 Nov 2008 17:29:02 +0900
Message-ID: <001501c944a0$b78e1d10$26aa5730$__42376.8946122893$1226480638$gmane$org@jp.nec.com>
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


  This patch modified interfaces to new cfq_data structure in cfq_cgroup
  module.  By this patch, interfaces can have two parameter and can set
  a cfq data for particular device and particular group.
  In cgroupfs,
    if the number of argument is one,
        a parameter means value which is set for all device, and
    if the number of argument is two,
        first parameter means value which is set and
        second parameter means name which is setting device.
        when second parameter is "defaults", default parameter of group
        is set by first parameter.
  In sysfs,
    if the number of argument is one,
        a parameter means value which is set for all group, and
    if the number of argument is two,
        first parameter means value which is set and
        second parameter means name which is setting group .


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |  192 +++++++++++++++++++++++++++++++++++++++---
 include/linux/cfq-iosched.h |    2 +
 2 files changed, 180 insertions(+), 14 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index 25da08e..99f3d94 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -123,6 +123,7 @@ static void *cfq_cgroup_init_cfq_data(struct cfq_cgroup *cfqc,
 	if (!cfqc) {
 		cfqc = cgroup_to_cfq_cgroup(get_root_subsys(&cfq_subsys));
 		cfq_cgroup_sibling_tree_add(cfqc, cfqd);
+		cfqd->ioprio = cfqc->ioprio;
 	} else {
 		struct cfq_data *__cfqd;
 		__cfqd = __cfq_cgroup_init_queue(cfqd->cfqdd->queue,
@@ -130,6 +131,7 @@ static void *cfq_cgroup_init_cfq_data(struct cfq_cgroup *cfqc,
 		if (!__cfqd)
 			return NULL;
 		cfq_cgroup_sibling_tree_add(cfqc, __cfqd);
+		__cfqd->ioprio = cfqc->ioprio;
 	}
 
 	/* check and create cfq_data for children */
@@ -294,6 +296,35 @@ static void cfq_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
 /*
  * cgroupfs parts below -->
  */
+static void
+param_separate(const char *master, char *valbuf, char *pathbuf,  int size)
+{
+	int i;
+	char *pc1 = (char *) master, *pc2;
+
+	pc2 = valbuf;
+	for (i = 0 ; i < (size - 1) && (*pc1 != ' ') &&
+		     (*pc1 != '\n') && (*pc1 != '\0') ; i++) {
+		*pc2 = *pc1;
+		pc2++;
+		pc1++;
+	}
+	*pc2 = '\n'; pc2++;  *pc2 = '\0';
+
+	for ( ; (i < (PAGE_SIZE - 1)) && (*pc1 == ' ') &&
+		(*pc1 != '\n') && (*pc1 != '\0') ; i++)
+		pc1++;
+
+	pc2 = pathbuf;
+	for ( ; i < (PAGE_SIZE - 1) && (*pc1 != ' ') &&
+		     (*pc1 != '\n') && (*pc1 != '\0') ; i++) {
+		*pc2 = *pc1;
+		pc2++;
+		pc1++;
+	}
+	*pc2 = '\0';
+}
+
 static ssize_t cfq_cgroup_read(struct cgroup *cont, struct cftype *cft,
 			       struct file *file, char __user *userbuf,
 			       size_t nbytes, loff_t *ppos)
@@ -301,6 +332,7 @@ static ssize_t cfq_cgroup_read(struct cgroup *cont, struct cftype *cft,
 	struct cfq_cgroup *cfqc;
 	char *page;
 	ssize_t ret;
+	struct rb_node *p;
 
 	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
@@ -318,7 +350,20 @@ static ssize_t cfq_cgroup_read(struct cgroup *cont, struct cftype *cft,
 	cgroup_unlock();
 
 	/* print priority */
-	ret = snprintf(page, PAGE_SIZE, "%d \n", cfqc->ioprio);
+	ret = snprintf(page, PAGE_SIZE, "default priority: %d\n", cfqc->ioprio);
+
+	p = rb_first(&cfqc->sibling_tree);
+	while (p) {
+		struct cfq_data *__cfqd;
+
+		__cfqd = rb_entry(p, struct cfq_data, group_node);
+
+		ret += snprintf(page + ret, PAGE_SIZE - ret, " %s %d\n",
+			       __cfqd->cfqdd->queue->kobj.parent->name,
+			       __cfqd->ioprio);
+
+		p = rb_next(p);
+	}
 
 	ret = simple_read_from_buffer(userbuf, nbytes, ppos, page, ret);
 
@@ -334,8 +379,10 @@ static ssize_t cfq_cgroup_write(struct cgroup *cont, struct cftype *cft,
 	struct cfq_cgroup *cfqc;
 	ssize_t ret;
 	long new_prio;
-	int err;
+	int err, sn;
 	char *buffer = NULL;
+	char *valbuf = NULL, *pathbuf = NULL;
+	struct rb_node *p;
 
 	cgroup_lock();
 	if (cgroup_is_removed(cont)) {
@@ -354,23 +401,64 @@ static ssize_t cfq_cgroup_write(struct cgroup *cont, struct cftype *cft,
 
 	if (copy_from_user(buffer, userbuf, nbytes)) {
 		ret = -EFAULT;
-		goto out;
+		goto free_buf;
 	}
 	buffer[nbytes] = 0;
 
-	err = strict_strtoul(buffer, 10, &new_prio);
+	valbuf = kmalloc(nbytes + 1, GFP_KERNEL);
+	if (!valbuf) {
+		ret = -ENOMEM;
+		goto free_buf;
+	}
+
+	pathbuf = kmalloc(nbytes + 1, GFP_KERNEL);
+	if (!pathbuf) {
+		ret = -ENOMEM;
+		goto free_val;
+	}
+
+	param_separate(buffer, valbuf, pathbuf, nbytes);
+
+	err = strict_strtoul(valbuf, 10, &new_prio);
 	if ((err) || ((new_prio < 0) || (new_prio > CFQ_CGROUP_MAX_IOPRIO))) {
 		ret = -EINVAL;
-		goto out;
+		goto free_path;
 	}
 
-	cfqc->ioprio = new_prio;
+	sn = strlen(pathbuf);
+
+	p = rb_first(&cfqc->sibling_tree);
+	while (p) {
+		struct cfq_data *__cfqd;
+		const char *namep;
+
+		__cfqd = rb_entry(p, struct cfq_data, group_node);
+		namep = __cfqd->cfqdd->queue->kobj.parent->name;
+
+		if (sn == 0) {
+			__cfqd->ioprio = new_prio;
+		} else if ((sn == strlen(namep)) &&
+			 (strncmp(pathbuf, namep, sn) == 0)) {
+			__cfqd->ioprio = new_prio;
+			break;
+		}
+
+		p = rb_next(p);
+	}
+
+	if ((sn == 0) ||
+	    ((sn == 7) && (strncmp(pathbuf, "default", 7) == 0)))
+		cfqc->ioprio = new_prio;
 
 	ret = nbytes;
 
-out:
+free_path:
+	kfree(pathbuf);
+free_val:
+	kfree(valbuf);
+free_buf:
 	kfree(buffer);
-
+out:
 	return ret;
 }
 
@@ -404,11 +492,33 @@ static ssize_t
 cfq_cgroup_var_show(char *page, struct cfq_data *cfqd,
 		    int (func)(struct cfq_data *))
 {
-	int val, retval = 0;
+	int err, val, retval = 0;
+	char *pathbuf = NULL;
+	struct rb_node *p;
+
+	pathbuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!pathbuf)
+		return 0;
+
+	p = rb_first(&cfqd->cfqdd->sibling_tree);
+	while (p) {
+		struct cfq_data *__cfqd;
+		struct cgroup *cgrp;
 
-	val = func(cfqd);
+		__cfqd = rb_entry(p, struct cfq_data, sib_node);
+		cgrp = __cfqd->cfqc->css.cgroup;
 
-	retval = snprintf(page, PAGE_SIZE, "%d\n", val);
+		err = cgroup_path(cgrp, pathbuf, PAGE_SIZE);
+		if (err)
+			break;
+		val = func(__cfqd);
+
+		retval += snprintf(page + retval, PAGE_SIZE - retval,
+				  "%s %d\n", pathbuf, val);
+		p = rb_next(p);
+	}
+
+	kfree(pathbuf);
 
 	return retval;
 }
@@ -437,21 +547,73 @@ SHOW_FUNCTION(cfq_cgroup_slice_idle_show, cfq_slice_idle, 1);
 SHOW_FUNCTION(cfq_cgroup_slice_sync_show, cfq_slice[1], 1);
 SHOW_FUNCTION(cfq_cgroup_slice_async_show, cfq_slice[0], 1);
 SHOW_FUNCTION(cfq_cgroup_slice_async_rq_show, cfq_slice_async_rq, 0);
+SHOW_FUNCTION(cfq_cgroup_ioprio_show, ioprio, 0);
 #undef SHOW_FUNCTION
 
 static ssize_t
 cfq_cgroup_var_store(const char *page, size_t count, struct cfq_data *cfqd,
 		     void (func)(struct cfq_data *, unsigned int))
 {
-	int err;
+	int err, sn;
 	unsigned long val;
+	char *valbuf = NULL, *setpathbuf = NULL, *pathbuf = NULL;
+	struct rb_node *p;
+
+	valbuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!valbuf) {
+		count = 0;
+		goto out;
+	}
 
-	err = strict_strtoul(page, 10, &val);
+	setpathbuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!setpathbuf) {
+		count = 0;
+		goto free_val;
+	}
+
+	pathbuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!pathbuf) {
+		count = 0;
+		goto free_setpath;
+	}
+
+	param_separate(page, valbuf, setpathbuf, PAGE_SIZE);
+
+	err = strict_strtoul(valbuf, 10, &val);
 	if (err)
 		return 0;
 
-	func(cfqd, val);
+	sn = strlen(setpathbuf);
+
+	p = rb_first(&cfqd->cfqdd->sibling_tree);
+	while (p) {
+		struct cfq_data *__cfqd;
+		struct cgroup *cgrp;
 
+		__cfqd = rb_entry(p, struct cfq_data, sib_node);
+		cgrp = __cfqd->cfqc->css.cgroup;
+
+		err = cgroup_path(cgrp, pathbuf, PAGE_SIZE);
+		if (err)
+			break;
+
+		if (sn == 0) {
+			func(__cfqd, val);
+		} else if ((sn == strlen(pathbuf)) &&
+			 (strncmp(setpathbuf, pathbuf, sn) == 0)) {
+			func(__cfqd, val);
+			break;
+		}
+
+		p = rb_next(p);
+	}
+
+	kfree(pathbuf);
+free_setpath:
+	kfree(setpathbuf);
+free_val:
+	kfree(valbuf);
+out:
 	return count;
 }
 
@@ -489,6 +651,7 @@ STORE_FUNCTION(cfq_cgroup_slice_sync_store, cfq_slice[1], 1, UINT_MAX, 1);
 STORE_FUNCTION(cfq_cgroup_slice_async_store, cfq_slice[0], 1, UINT_MAX, 1);
 STORE_FUNCTION(cfq_cgroup_slice_async_rq_store, cfq_slice_async_rq, 1,
 		UINT_MAX, 0);
+STORE_FUNCTION(cfq_cgroup_ioprio_store, ioprio, 0, CFQ_CGROUP_MAX_IOPRIO, 0);
 #undef STORE_FUNCTION
 
 #define CFQ_CGROUP_ATTR(name)					\
@@ -505,6 +668,7 @@ static struct elv_fs_entry cfq_cgroup_attrs[] = {
 	CFQ_CGROUP_ATTR(slice_async),
 	CFQ_CGROUP_ATTR(slice_async_rq),
 	CFQ_CGROUP_ATTR(slice_idle),
+	CFQ_CGROUP_ATTR(ioprio),
 	__ATTR_NULL
 };
 
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index 382fc0a..b58d476 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -91,6 +91,8 @@ struct cfq_data {
 	struct cfq_driver_data *cfqdd;
 
 #ifdef CONFIG_IOSCHED_CFQ_CGROUP
+	unsigned int ioprio;
+
 	/* sibling_tree member for cfq_meta_data */
 	struct rb_node sib_node;
 
-- 
1.5.6.5
