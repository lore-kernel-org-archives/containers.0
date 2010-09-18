From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH][RFC] v2 exec: move core_pattern pipe helper into the crashing
	namespace
Date: Fri, 17 Sep 2010 22:13:49 -0500
Message-ID: <1284779629-15273-1-git-send-email-wad__14075.718393042$1284779869$gmane$org@chromium.org>
References: <20100918012939.GA25046@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100918012939.GA25046-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Presently, a core_pattern pipe endpoint will be run in the init
namespace.  It will receive the virtual pid (task_tgid_vnr->%p) of the
core dumping process but will have no access to that processes /proc
without walking the init namespace /proc looking through all the global
pids until it finds the one it thinks matches.

One option for fixing this is to change the reported pid:
  https://patchwork.kernel.org/patch/185912/
However, it's unclear if it is desirable for the core_pattern to run
outside the namespace.  In particular, it can easily access the mounts
via /proc/[pid_nr]/root, but if there is a net namespace, it will not
have access.  (Originally introduced in 2007 in commit
b488893a390edfe027bae7a46e9af8083e740668 )

Instead, this change implements the more complex option two.  It
migrates the ____call_usermodehelper() thread into the same namespaces
as the dumping process.  It does not assign a pid in that namespace so
the collector will appear to be pid 0 in the namespace.

Signed-off-by: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

---
v2: dropped patch 1/2
    removed use of new copy_namespaces_unattached (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)
    moved pipe_params into coredump_params (nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org)

 fs/exec.c               |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/binfmts.h |    9 +++++++++
 2 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 828dd24..4cbb735 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -51,6 +51,7 @@
 #include <linux/audit.h>
 #include <linux/tracehook.h>
 #include <linux/kmod.h>
+#include <linux/nsproxy.h>
 #include <linux/fsnotify.h>
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
@@ -1820,7 +1821,32 @@ static int umh_pipe_setup(struct subprocess_info *info)
 	struct file *rp, *wp;
 	struct fdtable *fdt;
 	struct coredump_params *cp = (struct coredump_params *)info->data;
-	struct files_struct *cf = current->files;
+	struct coredump_pipe_params *pipe_params = &cp->pipe_params;
+	struct task_struct *tsk = current;
+	struct files_struct *cf = tsk->files;
+	struct fs_struct *cfs = tsk->fs;
+
+	/* Migrate this thread into the crashing namespaces, but
+	 * don't change its pid struct to avoid breaking any other
+	 * dependencies.  This will mean the process is pid=0 if it
+	 * was migrated into a pid namespace.
+	 */
+	if (pipe_params->nsproxy && pipe_params->fs) {
+		int kill;
+		switch_task_namespaces(tsk, pipe_params->nsproxy);
+		pipe_params->nsproxy = NULL;
+
+		task_lock(tsk);
+		tsk->fs = pipe_params->fs;
+		task_unlock(tsk);
+		pipe_params->fs = NULL;
+		/* Clean up the previous fs struct */
+		write_lock(&cfs->lock);
+		kill = !--cfs->users;
+		write_unlock(&cfs->lock);
+		if (kill)
+			free_fs_struct(cfs);
+	}
 
 	wp = create_write_pipe(0);
 	if (IS_ERR(wp))
@@ -1950,10 +1976,28 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
 			goto fail_dropcount;
 		}
 
+		/* Run the core_collector in the crashing namespaces */
+		cprm.pipe_params.fs = copy_fs_struct(current->fs);
+		if (!cprm.pipe_params.fs) {
+			printk(KERN_WARNING "%s failed to copy fs\n",
+				__func__);
+			argv_free(helper_argv);
+			goto fail_dropcount;
+		}
+		get_nsproxy(current->nsproxy);
+		cprm.pipe_params.nsproxy = current->nsproxy;
+
 		retval = call_usermodehelper_fns(helper_argv[0], helper_argv,
 					NULL, UMH_WAIT_EXEC, umh_pipe_setup,
 					NULL, &cprm);
 		argv_free(helper_argv);
+		/* nsproxy and fs will survive if call_usermodehelper_fns hits
+		 * ENOMEM prior to creating a new thread.
+		 */
+		if (cprm.pipe_params.nsproxy)
+			put_nsproxy(cprm.pipe_params.nsproxy);
+		if (cprm.pipe_params.fs)  /* not in use by anything else */
+			free_fs_struct(cprm.pipe_params.fs);
 		if (retval) {
  			printk(KERN_INFO "Core dump to %s pipe failed\n",
 			       corename);
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index a065612..2629603 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -68,6 +68,12 @@ struct linux_binprm{
 
 #define BINPRM_MAX_RECURSION 4
 
+/* Parameters to be passed to a pipe target during coredump */
+struct coredump_pipe_params {
+	struct nsproxy *nsproxy;
+	struct fs_struct *fs;
+};
+
 /* Function parameter for binfmt->coredump */
 struct coredump_params {
 	long signr;
@@ -75,6 +81,9 @@ struct coredump_params {
 	struct file *file;
 	unsigned long limit;
 	unsigned long mm_flags;
+	union {
+		struct coredump_pipe_params pipe_params;
+	};
 };
 
 /*
-- 
1.7.0.4
