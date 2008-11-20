From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 5/7] announce tasks moving in bio-cgroup
Date: Thu, 20 Nov 2008 19:14:04 +0800
Message-ID: <4925467C.9000509__5079.47479277409$1227179986$gmane$org@cn.fujitsu.com>
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

Some subsystems may be of interest to task moving in bio-cgroups.
So just announce each task moving.

Signed-of-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/biotrack.h |    9 +++++++++
 mm/biotrack.c            |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
index 371d263..546017c 100644
--- a/include/linux/biotrack.h
+++ b/include/linux/biotrack.h
@@ -7,6 +7,15 @@
 
 #ifdef	CONFIG_CGROUP_BIO
 
+struct tsk_move_msg {
+	int old_id;
+	int new_id;
+	struct task_struct *tsk;
+};
+
+extern int register_biocgroup_notifier(struct notifier_block *nb);
+extern int unregister_biocgroup_notifier(struct notifier_block *nb);
+
 struct io_context;
 struct block_device;
 
diff --git a/mm/biotrack.c b/mm/biotrack.c
index ba6b45b..979efcd 100644
--- a/mm/biotrack.c
+++ b/mm/biotrack.c
@@ -21,6 +21,22 @@
 #include <linux/blkdev.h>
 #include <linux/biotrack.h>
 
+#define MOVETASK 0
+static BLOCKING_NOTIFIER_HEAD(biocgroup_chain);
+
+int register_biocgroup_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&biocgroup_chain, nb);
+}
+EXPORT_SYMBOL(register_biocgroup_notifier);
+
+int unregister_biocgroup_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&biocgroup_chain, nb);
+}
+EXPORT_SYMBOL(unregister_biocgroup_notifier);
+
+
 /*
  * The block I/O tracking mechanism is implemented on the cgroup memory
  * controller framework. It helps to find the the owner of an I/O request 
@@ -299,11 +315,27 @@ static int bio_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return cgroup_add_files(cgrp, ss, bio_files, ARRAY_SIZE(bio_files));
 }
 
+static void bio_cgroup_attach(struct cgroup_subsys *ss,
+			      struct cgroup *cont, struct cgroup *oldcont,
+			      struct task_struct *tsk)
+{
+	struct tsk_move_msg tmm;
+	struct bio_cgroup *old_biog, *new_biog;
+	
+	old_biog = cgroup_bio(oldcont);
+	new_biog = cgroup_bio(cont);
+	tmm.old_id = old_biog->id;
+	tmm.new_id = new_biog->id;
+	tmm.tsk = tsk;
+	blocking_notifier_call_chain(&biocgroup_chain, MOVETASK, &tmm);
+}
+
 struct cgroup_subsys bio_cgroup_subsys = {
 	.name		= "bio",
 	.create		= bio_cgroup_create,
 	.destroy	= bio_cgroup_destroy,
 	.populate	= bio_cgroup_populate,
+	.attach         = bio_cgroup_attach,
 	.subsys_id	= bio_cgroup_subsys_id,
 };
 
-- 1.5.4.rc3 
