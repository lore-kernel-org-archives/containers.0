From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][05/12] Introduce cgroups structure with ioprio
	entry.
Date: Wed, 12 Nov 2008 17:26:56 +0900
Message-ID: <001201c944a0$6cb11310$46133930$__40500.6668567241$1226480091$gmane$org@jp.nec.com>
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

From 471798eeeea0d3cdc4c556ec3d663d4a91fd2e05 Mon Sep 17 00:00:00 2001
From: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Date: Wed, 29 Oct 2008 18:12:51 +0900
Subject: [PATCH][cfq-cgroups] Introduce cgroups structure with ioprio entry.

  This patch introcude cfq_cgroup structure which is type for
  group control within expanded CFQ scheduler.
  In addition, the cfq_cgroup structure has "ioprio" entry which 
  is preference of group for I/O.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c            |  148 +++++++++++++++++++++++++++++++++++++++++
 include/linux/cgroup_subsys.h |    6 ++
 2 files changed, 154 insertions(+), 0 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index aaa00ef..733980d 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -15,6 +15,154 @@
 #include <linux/cgroup.h>
 #include <linux/cfq-iosched.h>
 
+#define CFQ_CGROUP_MAX_IOPRIO		(7)
+
+
+struct cfq_cgroup {
+	struct cgroup_subsys_state css;
+	unsigned int ioprio;
+};
+
+static inline struct cfq_cgroup *cgroup_to_cfq_cgroup(struct cgroup *cont)
+{
+	return container_of(cgroup_subsys_state(cont, cfq_subsys_id),
+			    struct cfq_cgroup, css);
+}
+
+static inline struct cfq_cgroup *task_to_cfq_cgroup(struct task_struct *tsk)
+{
+	return container_of(task_subsys_state(tsk, cfq_subsys_id),
+			    struct cfq_cgroup, css);
+}
+
+
+static struct cgroup_subsys_state *
+cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	struct cfq_cgroup *cfqc;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	if (!cgroup_is_descendant(cont))
+		return ERR_PTR(-EPERM);
+
+	cfqc = kzalloc(sizeof(struct cfq_cgroup), GFP_KERNEL);
+	if (unlikely(!cfqc))
+		return ERR_PTR(-ENOMEM);
+
+	cfqc->ioprio = 3;
+
+	return &cfqc->css;
+}
+
+static void cfq_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	kfree(cgroup_to_cfq_cgroup(cont));
+}
+
+static ssize_t cfq_cgroup_read(struct cgroup *cont, struct cftype *cft,
+			       struct file *file, char __user *userbuf,
+			       size_t nbytes, loff_t *ppos)
+{
+	struct cfq_cgroup *cfqc;
+	char *page;
+	ssize_t ret;
+
+	page = (char *)__get_free_page(GFP_TEMPORARY);
+	if (!page)
+		return -ENOMEM;
+
+	cgroup_lock();
+	if (cgroup_is_removed(cont)) {
+		cgroup_unlock();
+		ret = -ENODEV;
+		goto out;
+	}
+
+	cfqc = cgroup_to_cfq_cgroup(cont);
+
+	cgroup_unlock();
+
+	/* print priority */
+	ret = snprintf(page, PAGE_SIZE, "%d \n", cfqc->ioprio);
+
+	ret = simple_read_from_buffer(userbuf, nbytes, ppos, page, ret);
+
+out:
+	free_page((unsigned long)page);
+	return ret;
+}
+
+static ssize_t cfq_cgroup_write(struct cgroup *cont, struct cftype *cft,
+				struct file *file, const char __user *userbuf,
+				size_t nbytes, loff_t *ppos)
+{
+	struct cfq_cgroup *cfqc;
+	ssize_t ret;
+	long new_prio;
+	int err;
+	char *buffer = NULL;
+
+	cgroup_lock();
+	if (cgroup_is_removed(cont)) {
+		cgroup_unlock();
+		ret = -ENODEV;
+		goto out;
+	}
+
+	cfqc = cgroup_to_cfq_cgroup(cont);
+	cgroup_unlock();
+
+	/* set priority */
+	buffer = kmalloc(nbytes + 1, GFP_KERNEL);
+	if (buffer == NULL)
+		return -ENOMEM;
+
+	if (copy_from_user(buffer, userbuf, nbytes)) {
+		ret = -EFAULT;
+		goto out;
+	}
+	buffer[nbytes] = 0;
+
+	err = strict_strtoul(buffer, 10, &new_prio);
+	if ((err) || ((new_prio < 0) || (new_prio > CFQ_CGROUP_MAX_IOPRIO))) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	cfqc->ioprio = new_prio;
+
+	ret = nbytes;
+
+out:
+	kfree(buffer);
+
+	return ret;
+}
+
+static struct cftype files[] = {
+	{
+		.name = "ioprio",
+		.read = cfq_cgroup_read,
+		.write = cfq_cgroup_write,
+	},
+};
+
+static int cfq_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	return cgroup_add_files(cont, ss, files, ARRAY_SIZE(files));
+}
+
+struct cgroup_subsys cfq_subsys = {
+	.name = "cfq",
+	.create = cfq_cgroup_create,
+	.destroy = cfq_cgroup_destroy,
+	.populate = cfq_cgroup_populate,
+	.subsys_id = cfq_subsys_id,
+};
+
+
 /*
  * sysfs parts below -->
  */
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c22396..a9482aa 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -54,3 +54,9 @@ SUBSYS(freezer)
 #endif
 
 /* */
+
+#ifdef CONFIG_IOSCHED_CFQ_CGROUP
+SUBSYS(cfq)
+#endif
+
+/* */
-- 
1.5.6.5
