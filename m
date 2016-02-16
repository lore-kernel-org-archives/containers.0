From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] Make core_pattern support namespace
Date: Tue, 16 Feb 2016 19:33:39 +0800
Message-ID: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei__24929.539502091$1455622565$gmane$org@cn.fujitsu.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, each container shared one copy of coredump setting
with the host system, if host system changed the setting, each
running containers will be affected.

Moreover, it is not easy to let each container keeping their own
coredump setting.

We can use some workaround as pipe program to make the second
requirement possible, but it is not simple, and both host and
container are limited to set to fixed pipe program.
In one word, for host running contailer, we can't change core_pattern
anymore.
To make the problem more hard, if a host running more than one
container product, each product will try to snatch the global
coredump setting to fit their own requirement.

For container based on namespace design, it is good to allow
each container keeping their own coredump setting.

It will bring us following benefit:
1: Each container can change their own coredump setting
   based on operation on /proc/sys/kernel/core_pattern
2: Coredump setting changed in host will not affect
   running containers.
3: Support both case of "putting coredump in guest" and
   "putting curedump in host".

Each namespace-based software(lxc, docker, ..) can use this function
to custom their dump setting.

And this function makes each continer working as separate system,
it fit for design goal of namespace.

Test(in lxc):
 # In the host
 # ----------------
 # echo host_core >/proc/sys/kernel/core_pattern
 # cat /proc/sys/kernel/core_pattern
 host_core
 # ulimit -c 1024000
 # ./make_dump
 Segmentation fault (core dumped)
 # ls -l
 -rw------- 1 root root 331776 Feb  4 18:02 host_core.2175
 -rwxr-xr-x 1 root root 759731 Feb  4 18:01 make_dump
 #

 # In the container
 # ----------------
 # cat /proc/sys/kernel/core_pattern
 host_core
 # echo container_core >/proc/sys/kernel/core_pattern
 # ./make_dump
 Segmentation fault (core dumped)
 # ls -l
 -rwxr-xr-x    1 root     root       759731 Feb  4 10:45 make_dump
 -rw-------    1 root     root       331776 Feb  4 10:45 container_core.16
 #

 # Return to host
 # ----------------
 # cat /proc/sys/kernel/core_pattern
 host_core
 # ls
 host_core.2175  make_dump  make_dump.c
 # rm -f host_core.2175
 # ./make_dump
 Segmentation fault (core dumped)
 # ls -l
 -rw------- 1 root root 331776 Feb  4 18:49 host_core.2351
 -rwxr-xr-x 1 root root 759731 Feb  4 18:01 make_dump
 #

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c                 |  3 +--
 include/linux/pid_namespace.h |  2 ++
 kernel/pid.c                  |  1 +
 kernel/pid_namespace.c        |  3 +++
 kernel/sysctl.c               | 22 ++++++++++++++++------
 5 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 9ea87e9..8a7ef9b 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -46,7 +46,6 @@
 
 int core_uses_pid;
 unsigned int core_pipe_limit;
-char core_pattern[CORENAME_MAX_SIZE] = "core";
 static int core_name_size = CORENAME_MAX_SIZE;
 
 struct core_name {
@@ -183,7 +182,7 @@ put_exe_file:
 static int format_corename(struct core_name *cn, struct coredump_params *cprm)
 {
 	const struct cred *cred = current_cred();
-	const char *pat_ptr = core_pattern;
+	const char *pat_ptr = current->nsproxy->pid_ns_for_children->core_pattern;
 	int ispipe = (*pat_ptr == '|');
 	int pid_in_pattern = 0;
 	int err = 0;
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 918b117..a5af1e9 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/kref.h>
 #include <linux/ns_common.h>
+#include <linux/binfmts.h>
 
 struct pidmap {
        atomic_t nr_free;
@@ -45,6 +46,7 @@ struct pid_namespace {
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
 	struct ns_common ns;
+	char core_pattern[CORENAME_MAX_SIZE];
 };
 
 extern struct pid_namespace init_pid_ns;
diff --git a/kernel/pid.c b/kernel/pid.c
index 4d73a83..c79c1d5 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -83,6 +83,7 @@ struct pid_namespace init_pid_ns = {
 #ifdef CONFIG_PID_NS
 	.ns.ops = &pidns_operations,
 #endif
+	.core_pattern = "core",
 };
 EXPORT_SYMBOL_GPL(init_pid_ns);
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a65ba13..16d6d21 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -123,6 +123,9 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
+	strncpy(ns->core_pattern, parent_pid_ns->core_pattern,
+		sizeof(ns->core_pattern));
+
 	return ns;
 
 out_free_map:
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 97715fd..70f8af5 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -100,7 +100,6 @@
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
 extern int core_uses_pid;
-extern char core_pattern[];
 extern unsigned int core_pipe_limit;
 #endif
 extern int pid_max;
@@ -469,7 +468,7 @@ static struct ctl_table kern_table[] = {
 	},
 	{
 		.procname	= "core_pattern",
-		.data		= core_pattern,
+		.data		= NULL,
 		.maxlen		= CORENAME_MAX_SIZE,
 		.mode		= 0644,
 		.proc_handler	= proc_dostring_coredump,
@@ -2301,6 +2300,8 @@ int proc_dointvec_minmax(struct ctl_table *table, int write,
 static void validate_coredump_safety(void)
 {
 #ifdef CONFIG_COREDUMP
+	char *core_pattern = current->nsproxy->pid_ns_for_children->core_pattern;
+
 	if (suid_dumpable == SUID_DUMP_ROOT &&
 	    core_pattern[0] != '/' && core_pattern[0] != '|') {
 		printk(KERN_WARNING "Unsafe core_pattern used with "\
@@ -2323,10 +2324,19 @@ static int proc_dointvec_minmax_coredump(struct ctl_table *table, int write,
 static int proc_dostring_coredump(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	int error = proc_dostring(table, write, buffer, lenp, ppos);
-	if (!error)
-		validate_coredump_safety();
-	return error;
+	int ret;
+
+	if (write && *ppos && sysctl_writes_strict == SYSCTL_WRITES_WARN)
+		warn_sysctl_write(table);
+
+	ret = _proc_do_string(current->nsproxy->pid_ns_for_children->core_pattern,
+			      table->maxlen, write,
+			      (char __user *)buffer, lenp, ppos);
+	if (ret)
+		return ret;
+
+	validate_coredump_safety();
+	return 0;
 }
 #endif
 
-- 
1.8.5.1
