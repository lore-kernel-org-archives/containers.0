From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [RFC PATCH] core_pattern: set core helpers root and namespace to
	crashing process
Date: Tue,  4 Dec 2012 16:11:51 -0500
Message-ID: <1354655511-11701-1-git-send-email-nhorman__26039.0181596906$1354655587$gmane$org@tuxdriver.com>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Id: containers.vger.kernel.org

As its currently implemented, redirection of core dumps to a pipe reader should
be executed such that the reader runs in the namespace of the crashing process,
and it currently does not. This is the only sane way to deal with namespaces
properly it seems to me, and this patch implements that functionality.

Theres one problem I currently see with it, and that is that I'm not sure we can
change the current behavior of how the root fs is set for the pipe reader, lest
we break some user space expectations. As such, I've added a sysctl in this
patch to allow administrators to globally select if a core reader specified via
/proc/sys/kernel/core_pattern should use the global rootfs, or the (possibly)
chrooted fs of the crashing process.

I've tested this using both settings for the new sysctl, and it works well.

For the sake of history, this was discussed before:
http://www.spinics.net/lists/linux-containers/msg21531.html

It seems there was some modicum of consensus as to how this should work, but
there was no action taken on it.

Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Reported-by: Daniel Berrange <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
CC: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
CC: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 fs/coredump.c           | 11 +++++++++++
 include/linux/binfmts.h |  1 +
 kernel/sysctl.c         |  8 ++++++++
 3 files changed, 20 insertions(+)

diff --git a/fs/coredump.c b/fs/coredump.c
index ce47379..e7d8ca2 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -47,6 +47,7 @@
 int core_uses_pid;
 char core_pattern[CORENAME_MAX_SIZE] = "core";
 unsigned int core_pipe_limit;
+unsigned int core_pipe_global_root;
 
 struct core_name {
 	char *corename;
@@ -443,6 +444,7 @@ static void wait_for_dump_helpers(struct file *file)
 static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 {
 	struct file *files[2];
+	struct path root;
 	struct coredump_params *cp = (struct coredump_params *)info->data;
 	int err = create_pipe_files(files, 0);
 	if (err)
@@ -455,6 +457,14 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 	/* and disallow core files too */
 	current->signal->rlim[RLIMIT_CORE] = (struct rlimit){1, 1};
 
+
+	if (!core_pipe_global_root) {
+		get_fs_root(cp->cprocess->fs, &root);
+		set_fs_root(current->fs, &root);
+	}
+
+	switch_task_namespaces(current, cp->cprocess->nsproxy);
+
 	return err;
 }
 
@@ -476,6 +486,7 @@ void do_coredump(siginfo_t *siginfo, struct pt_regs *regs)
 		.siginfo = siginfo,
 		.regs = regs,
 		.limit = rlimit(RLIMIT_CORE),
+		.cprocess = current,
 		/*
 		 * We must use the same mm->flags while dumping core to avoid
 		 * inconsistency of bit flags, since this flag is not protected
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index cfcc6bf..08e7bcb 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -61,6 +61,7 @@ struct coredump_params {
 	siginfo_t *siginfo;
 	struct pt_regs *regs;
 	struct file *file;
+	struct task_struct *cprocess;
 	unsigned long limit;
 	unsigned long mm_flags;
 };
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26f65ea..be7b69d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -102,6 +102,7 @@ extern int suid_dumpable;
 extern int core_uses_pid;
 extern char core_pattern[];
 extern unsigned int core_pipe_limit;
+extern unsigned int core_pipe_global_root;
 #endif
 extern int pid_max;
 extern int min_free_kbytes;
@@ -430,6 +431,13 @@ static struct ctl_table kern_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "core_pipe_global_root",
+		.data		= &core_pipe_global_root,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #ifdef CONFIG_PROC_SYSCTL
 	{
-- 
1.7.11.7
