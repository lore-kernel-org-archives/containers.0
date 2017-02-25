From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [PATCH RFC] coredump: virtualize core dump path configuration
Date: Sat, 25 Feb 2017 15:56:13 +0300
Message-ID: <148802737321.604836.9948660933476794784.stgit__17464.1871978112$1488027826$gmane$org@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds per-mount-namespace core dump pattern.

Kernel writes coredump in chroot/container where application is
executed or starts pipe helper in the same chroot according to
pattern set by sysctl "kernel.core_pattern". This configuration is
global and this sysctl couldn't be extended without breaking anything.

This patch adds second sysctl "kernel.core_pattern_ns" which overrides
global configuration for tasks in current mount namespace.
Resetting it to empty string reverts core dumps back to global pattern.

New namespace gets a copy of this configuration from parent.

Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
---
 Documentation/sysctl/kernel.txt |    9 +++++++++
 fs/coredump.c                   |   27 ++++++++++++++++++++++++++-
 fs/mount.h                      |    1 +
 fs/namespace.c                  |   12 ++++++++++++
 kernel/sysctl.c                 |   26 +++++++++++++++++++++++++-
 5 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index a32b4b748644..769aa00df898 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -26,6 +26,7 @@ show up in /proc/sys/kernel:
 - callhome		     [ S390 only ]
 - cap_last_cap
 - core_pattern
+- core_pattern_ns
 - core_pipe_limit
 - core_uses_pid
 - ctrl-alt-del
@@ -219,6 +220,14 @@ core_pattern is used to specify a core dumpfile pattern name.
 
 ==============================================================
 
+core_pattern_ns:
+
+This sysctl has the same format as core_pattern. Any non-empty string
+set here overrides core_pattern for tasks in current mount namespace.
+New mount namespace gets a copy of this configuration from parent.
+
+==============================================================
+
 core_pipe_limit:
 
 This sysctl is only applicable when core_pattern is configured to pipe
diff --git a/fs/coredump.c b/fs/coredump.c
index ae6b05629ca1..9c789496d4c6 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -45,6 +45,7 @@
 
 #include <trace/events/task.h>
 #include "internal.h"
+#include "mount.h"
 
 #include <trace/events/sched.h>
 
@@ -180,6 +181,30 @@ static int cn_print_exe_file(struct core_name *cn)
 	return ret;
 }
 
+char *namespace_core_pattern(bool alloc)
+{
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+
+	if (!ns->core_pattern && alloc) {
+		char *new = kzalloc(CORENAME_MAX_SIZE, GFP_KERNEL);
+
+		if (new && cmpxchg(&ns->core_pattern, NULL, new))
+			kfree(new);
+	}
+
+	return ns->core_pattern;
+}
+
+static char *current_core_pattern(void)
+{
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+
+	if (ns->core_pattern && ns->core_pattern[0])
+		return ns->core_pattern;
+
+	return core_pattern;
+}
+
 /* format_corename will inspect the pattern parameter, and output a
  * name into corename, which must have space for at least
  * CORENAME_MAX_SIZE bytes plus one byte for the zero terminator.
@@ -187,7 +212,7 @@ static int cn_print_exe_file(struct core_name *cn)
 static int format_corename(struct core_name *cn, struct coredump_params *cprm)
 {
 	const struct cred *cred = current_cred();
-	const char *pat_ptr = core_pattern;
+	const char *pat_ptr = current_core_pattern();
 	int ispipe = (*pat_ptr == '|');
 	int pid_in_pattern = 0;
 	int err = 0;
diff --git a/fs/mount.h b/fs/mount.h
index 2c856fc47ae3..894bca887104 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -16,6 +16,7 @@ struct mnt_namespace {
 	u64 event;
 	unsigned int		mounts; /* # of mounts in the namespace */
 	unsigned int		pending_mounts;
+	char			*core_pattern;
 };
 
 struct mnt_pcp {
diff --git a/fs/namespace.c b/fs/namespace.c
index 487ba30bb5c6..a8dd58eb10da 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -24,6 +24,7 @@
 #include <linux/magic.h>
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
+#include <linux/binfmts.h>	/* CORENAME_MAX_SIZE */
 #include "pnode.h"
 #include "internal.h"
 
@@ -2828,6 +2829,7 @@ static void free_mnt_ns(struct mnt_namespace *ns)
 	ns_free_inum(&ns->ns);
 	dec_mnt_namespaces(ns->ucounts);
 	put_user_ns(ns->user_ns);
+	kfree(ns->core_pattern);
 	kfree(ns);
 }
 
@@ -2872,6 +2874,7 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
 	new_ns->ucounts = ucounts;
 	new_ns->mounts = 0;
 	new_ns->pending_mounts = 0;
+	new_ns->core_pattern = NULL;
 	return new_ns;
 }
 
@@ -2899,6 +2902,15 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	if (IS_ERR(new_ns))
 		return new_ns;
 
+	if (ns->core_pattern) {
+		new_ns->core_pattern = kmemdup(ns->core_pattern,
+					       CORENAME_MAX_SIZE, GFP_KERNEL);
+		if (!new_ns->core_pattern) {
+			free_mnt_ns(new_ns);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
+
 	namespace_lock();
 	/* First pass: copy the tree topology */
 	copy_flags = CL_COPY_UNBINDABLE | CL_EXPIRE;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 1aea594a54db..9e66daf1e236 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -483,6 +483,13 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dostring_coredump,
 	},
 	{
+		.procname	= "core_pattern_ns",
+		.data		= NULL,
+		.maxlen		= CORENAME_MAX_SIZE,
+		.mode		= 0644,
+		.proc_handler	= proc_dostring_coredump,
+	},
+	{
 		.procname	= "core_pipe_limit",
 		.data		= &core_pipe_limit,
 		.maxlen		= sizeof(unsigned int),
@@ -2408,10 +2415,27 @@ static int proc_dointvec_minmax_coredump(struct ctl_table *table, int write,
 }
 
 #ifdef CONFIG_COREDUMP
+extern char *namespace_core_pattern(bool alloc);
+
 static int proc_dostring_coredump(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	int error = proc_dostring(table, write, buffer, lenp, ppos);
+	struct ctl_table tmp_table;
+	char empty[] = "";
+	int error;
+
+	if (!table->data) {
+		tmp_table = *table;
+		table = &tmp_table;
+		table->data = namespace_core_pattern(write);
+		if (!table->data) {
+			if (write)
+				return -ENOMEM;
+			table->data = empty;
+		}
+	}
+
+	error = proc_dostring(table, write, buffer, lenp, ppos);
 	if (!error)
 		validate_coredump_safety();
 	return error;
