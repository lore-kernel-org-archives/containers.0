From: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Subject: [RFC][PATCH v2 7/7] Do not recompute msgmni anymore if explicitely
	set by user
Date: Thu, 31 Jan 2008 14:40:25 +0100
Message-ID: <20080131135357.082657000@bull.net>
References: <20080131134018.273154000@bull.net>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=ipc_unregister_callback_on_msgmni_manual_change.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

[PATCH 07/07]

This patch makes msgmni not recomputed anymore upon ipc namespace creation /
removal or memory add/remove, as soon as it has been set from userland.

As soon as msgmni is explicitely set via procfs or sysctl(), the associated
callback routine is unregistered from the ipc namespace notifier chain.


Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>

---
 ipc/ipc_sysctl.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 41 insertions(+), 2 deletions(-)

Index: linux-2.6.24/ipc/ipc_sysctl.c
===================================================================
--- linux-2.6.24.orig/ipc/ipc_sysctl.c	2008-01-29 16:55:04.000000000 +0100
+++ linux-2.6.24/ipc/ipc_sysctl.c	2008-01-31 13:13:14.000000000 +0100
@@ -34,6 +34,24 @@ static int proc_ipc_dointvec(ctl_table *
 	return proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
 }
 
+static int proc_ipc_callback_dointvec(ctl_table *table, int write,
+	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	size_t lenp_bef = *lenp;
+	int rc;
+
+	rc = proc_ipc_dointvec(table, write, filp, buffer, lenp, ppos);
+
+	if (write && !rc && lenp_bef == *lenp)
+		/*
+		 * Tunable has successfully been changed from userland:
+		 * disable its automatic recomputing.
+		 */
+		unregister_ipcns_notifier(current->nsproxy->ipc_ns);
+
+	return rc;
+}
+
 static int proc_ipc_doulongvec_minmax(ctl_table *table, int write,
 	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -48,6 +66,7 @@ static int proc_ipc_doulongvec_minmax(ct
 #else
 #define proc_ipc_doulongvec_minmax NULL
 #define proc_ipc_dointvec	   NULL
+#define proc_ipc_callback_dointvec NULL
 #endif
 
 #ifdef CONFIG_SYSCTL_SYSCALL
@@ -89,8 +108,28 @@ static int sysctl_ipc_data(ctl_table *ta
 	}
 	return 1;
 }
+
+static int sysctl_ipc_registered_data(ctl_table *table, int __user *name,
+		int nlen, void __user *oldval, size_t __user *oldlenp,
+		void __user *newval, size_t newlen)
+{
+	int rc;
+
+	rc = sysctl_ipc_data(table, name, nlen, oldval, oldlenp, newval,
+		newlen);
+
+	if (newval && newlen && rc > 0)
+		/*
+		 * Tunable has successfully been changed from userland:
+		 * disable its automatic recomputing.
+		 */
+		unregister_ipcns_notifier(current->nsproxy->ipc_ns);
+
+	return rc;
+}
 #else
 #define sysctl_ipc_data NULL
+#define sysctl_ipc_registered_data NULL
 #endif
 
 static struct ctl_table ipc_kern_table[] = {
@@ -136,8 +175,8 @@ static struct ctl_table ipc_kern_table[]
 		.data		= &init_ipc_ns.msg_ctlmni,
 		.maxlen		= sizeof (init_ipc_ns.msg_ctlmni),
 		.mode		= 0644,
-		.proc_handler	= proc_ipc_dointvec,
-		.strategy	= sysctl_ipc_data,
+		.proc_handler	= proc_ipc_callback_dointvec,
+		.strategy	= sysctl_ipc_registered_data,
 	},
 	{
 		.ctl_name	= KERN_MSGMNB,

--
