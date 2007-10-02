From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch -mm 5/5] mqueue namespace : make sysctl work per namespace
Date: Tue, 02 Oct 2007 10:46:13 +0200
Message-ID: <31591.9734574438$1191315553@news.gmane.org>
References: <20071002084608.149781400@fr.ibm.com>>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=mq_namespace-fix-sysctl.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

Largely inspired from ipc/ipc_sysctl.c

Todo: 
      - check CONFIG_* options
      - move code to ipc/mqueue_sysctl.c ?

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 ipc/mqueue.c |   40 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 37 insertions(+), 3 deletions(-)

Index: 2.6.23-rc8-mm2/ipc/mqueue.c
===================================================================
--- 2.6.23-rc8-mm2.orig/ipc/mqueue.c
+++ 2.6.23-rc8-mm2/ipc/mqueue.c
@@ -1260,6 +1260,40 @@ static struct file_system_type mqueue_fs
 	.kill_sb = kill_litter_super,
 };
 
+static void *get_mq(ctl_table *table)
+{
+	char *which = table->data;
+	struct mq_namespace *mq_ns = current->nsproxy->mq_ns;
+	which = (which - (char *)&init_mq_ns) + (char *)mq_ns;
+	return which;
+}
+
+#ifdef CONFIG_PROC_FS
+static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
+	void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table mq_table;
+	memcpy(&mq_table, table, sizeof(mq_table));
+	mq_table.data = get_mq(table);
+
+	return proc_dointvec(&mq_table, write, filp, buffer, lenp, ppos);
+}
+
+static int proc_mq_dointvec_minmax(ctl_table *table, int write,
+	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table mq_table;
+	memcpy(&mq_table, table, sizeof(mq_table));
+	mq_table.data = get_mq(table);
+
+	return proc_dointvec_minmax(&mq_table, write, filp, buffer,
+					lenp, ppos);
+}
+#else
+#define proc_mq_dointvec_minmax NULL
+#define proc_mq_dointvec	NULL
+#endif
+
 static int msg_max_limit_min = DFLT_MSGMAX;
 static int msg_max_limit_max = HARD_MSGMAX;
 
@@ -1272,14 +1306,14 @@ static ctl_table mq_sysctls[] = {
 		.data		= &init_mq_ns.queues_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_mq_dointvec,
 	},
 	{
 		.procname	= "msg_max",
 		.data		= &init_mq_ns.msg_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
+		.proc_handler	= &proc_mq_dointvec_minmax,
 		.extra1		= &msg_max_limit_min,
 		.extra2		= &msg_max_limit_max,
 	},
@@ -1288,7 +1322,7 @@ static ctl_table mq_sysctls[] = {
 		.data		= &init_mq_ns.msgsize_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
+		.proc_handler	= &proc_mq_dointvec_minmax,
 		.extra1		= &msg_maxsize_limit_min,
 		.extra2		= &msg_maxsize_limit_max,
 	},

-- 
