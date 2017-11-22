From: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH_v4.1 3/3] Make core_pattern support namespace
Date: Wed, 22 Nov 2017 11:24:18 +0800
Message-ID: <1511321058-6089-4-git-send-email-caosf.fnst__33408.6834373467$1511321065$gmane$org@cn.fujitsu.com>
References: <1501655849-9149-1-git-send-email-caosf.fnst@cn.fujitsu.com>
	<1511321058-6089-1-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1511321058-6089-1-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, fnstml-container-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, each container shared one copy of coredump setting
with the host system, if host system changed the setting, each
running containers will be affected.
Same story happened when container changed core_pattern, both
host and other container will be affected.

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
---
 fs/coredump.c                 | 25 ++++++++++++++++------
 include/linux/pid_namespace.h |  3 +++
 kernel/pid.c                  |  2 ++
 kernel/pid_namespace.c        |  2 ++
 kernel/sysctl.c               | 50 ++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 70 insertions(+), 12 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 41448bd..cf08c65 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -53,7 +53,6 @@
 
 int core_uses_pid;
 unsigned int core_pipe_limit;
-char core_pattern[CORENAME_MAX_SIZE] = "core";
 static int core_name_size = CORENAME_MAX_SIZE;
 
 struct core_name {
@@ -61,8 +60,6 @@ struct core_name {
 	int used, size;
 };
 
-/* The maximal length of core_pattern is also specified in sysctl.c */
-
 static int expand_corename(struct core_name *cn, int size)
 {
 	char *corename = krealloc(cn->corename, size, GFP_KERNEL);
@@ -187,10 +184,10 @@ static int cn_print_exe_file(struct core_name *cn)
  * name into corename, which must have space for at least
  * CORENAME_MAX_SIZE bytes plus one byte for the zero terminator.
  */
-static int format_corename(struct core_name *cn, struct coredump_params *cprm)
+static int format_corename(struct core_name *cn, const char *pat_ptr,
+			   struct coredump_params *cprm)
 {
 	const struct cred *cred = current_cred();
-	const char *pat_ptr = core_pattern;
 	int ispipe = (*pat_ptr == '|');
 	int pid_in_pattern = 0;
 	int err = 0;
@@ -669,6 +666,8 @@ void do_coredump(const siginfo_t *siginfo)
 		 */
 		.mm_flags = mm->flags,
 	};
+	struct pid_namespace *pid_ns;
+	char core_pattern[CORENAME_MAX_SIZE];
 
 	audit_core_dumps(siginfo->si_signo);
 
@@ -678,6 +677,18 @@ void do_coredump(const siginfo_t *siginfo)
 	if (!__get_dumpable(cprm.mm_flags))
 		goto fail;
 
+	pid_ns = task_active_pid_ns(current);
+	spin_lock(&pid_ns->core_pattern_lock);
+	while (pid_ns != &init_pid_ns) {
+		if (pid_ns->core_pattern[0])
+			break;
+		spin_unlock(&pid_ns->core_pattern_lock);
+		pid_ns = pid_ns->parent,
+		spin_lock(&pid_ns->core_pattern_lock);
+	}
+	strcpy(core_pattern, pid_ns->core_pattern);
+	spin_unlock(&pid_ns->core_pattern_lock);
+
 	cred = prepare_creds();
 	if (!cred)
 		goto fail;
@@ -699,7 +710,7 @@ void do_coredump(const siginfo_t *siginfo)
 
 	old_cred = override_creds(cred);
 
-	ispipe = format_corename(&cn, &cprm);
+	ispipe = format_corename(&cn, core_pattern, &cprm);
 
 	if (ispipe) {
 		int dump_count;
@@ -746,7 +757,7 @@ void do_coredump(const siginfo_t *siginfo)
 		}
 
 		rcu_read_lock();
-		vinit_task = find_task_by_vpid(1);
+		vinit_task = find_task_by_pid_ns(1, pid_ns);
 		rcu_read_unlock();
 		if (!vinit_task) {
 			printk(KERN_WARNING "failed getting init task info, skipping core dump\n");
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index c78af60..a384b4a 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -10,6 +10,7 @@
 #include <linux/nsproxy.h>
 #include <linux/kref.h>
 #include <linux/ns_common.h>
+#include <linux/binfmts.h>
 
 struct pidmap {
        atomic_t nr_free;
@@ -53,6 +54,8 @@ struct pid_namespace {
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
 	struct ns_common ns;
+	spinlock_t core_pattern_lock;
+	char core_pattern[CORENAME_MAX_SIZE];
 } __randomize_layout;
 
 extern struct pid_namespace init_pid_ns;
diff --git a/kernel/pid.c b/kernel/pid.c
index 020dedb..32e1cff 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -82,6 +82,8 @@ struct pid_namespace init_pid_ns = {
 #ifdef CONFIG_PID_NS
 	.ns.ops = &pidns_operations,
 #endif
+	.core_pattern_lock = __SPIN_LOCK_UNLOCKED(init_pid_ns.core_pattern_lock),
+	.core_pattern = "core",
 };
 EXPORT_SYMBOL_GPL(init_pid_ns);
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 4918314..a3d18c2 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -144,6 +144,8 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
+	spin_lock_init(&ns->core_pattern_lock);
+
 	return ns;
 
 out_free_map:
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9576bd5..d091212 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -500,7 +500,7 @@ static struct ctl_table kern_table[] = {
 	},
 	{
 		.procname	= "core_pattern",
-		.data		= core_pattern,
+		.data		= NULL,
 		.maxlen		= CORENAME_MAX_SIZE,
 		.mode		= 0644,
 		.proc_handler	= proc_dostring_coredump,
@@ -2624,6 +2624,12 @@ int proc_douintvec_minmax(struct ctl_table *table, int write,
 static void validate_coredump_safety(void)
 {
 #ifdef CONFIG_COREDUMP
+	struct pid_namespace *pid_ns = task_active_pid_ns(current);
+	const char *core_pattern;
+
+	spin_lock(&pid_ns->core_pattern_lock);
+	core_pattern = pid_ns->core_pattern;
+
 	if (suid_dumpable == SUID_DUMP_ROOT &&
 	    core_pattern[0] != '/' && core_pattern[0] != '|') {
 		printk(KERN_WARNING
@@ -2632,6 +2638,8 @@ static void validate_coredump_safety(void)
 "Set kernel.core_pattern before fs.suid_dumpable.\n"
 		);
 	}
+
+	spin_unlock(&pid_ns->core_pattern_lock);
 #endif
 }
 
@@ -2648,10 +2656,42 @@ static int proc_dointvec_minmax_coredump(struct ctl_table *table, int write,
 static int proc_dostring_coredump(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	int error = proc_dostring(table, write, buffer, lenp, ppos);
-	if (!error)
-		validate_coredump_safety();
-	return error;
+	int ret;
+	char core_pattern[CORENAME_MAX_SIZE];
+	struct pid_namespace *pid_ns = task_active_pid_ns(current);
+
+	if (write) {
+		if (*ppos && sysctl_writes_strict == SYSCTL_WRITES_WARN)
+			warn_sysctl_write(table);
+
+		ret = _proc_do_string(core_pattern, table->maxlen, write,
+				      (char __user *)buffer, lenp, ppos);
+		if (ret)
+			return ret;
+
+		spin_lock(&pid_ns->core_pattern_lock);
+		strcpy(pid_ns->core_pattern, core_pattern);
+		spin_unlock(&pid_ns->core_pattern_lock);
+	} else {
+		spin_lock(&pid_ns->core_pattern_lock);
+		while (pid_ns != &init_pid_ns) {
+			if (pid_ns->core_pattern[0])
+				break;
+			spin_unlock(&pid_ns->core_pattern_lock);
+			pid_ns = pid_ns->parent,
+			spin_lock(&pid_ns->core_pattern_lock);
+		}
+		strcpy(core_pattern, pid_ns->core_pattern);
+		spin_unlock(&pid_ns->core_pattern_lock);
+
+		ret = _proc_do_string(core_pattern, table->maxlen, write,
+				      (char __user *)buffer, lenp, ppos);
+		if (ret)
+			return ret;
+	}
+
+	validate_coredump_safety();
+	return 0;
 }
 #endif
 
-- 
2.1.0
