From: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] coredump: run the coredump helper using the same namespace
	as the dead process
Date: Mon, 5 Nov 2012 11:38:11 -0500
Message-ID: <20121105163810.GJ14789@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

/proc/sys/kernel/core_pattern can be used to specify a userspace helper
to handle core files and it currently runs in the root namespace.
This patch allows the helper to run in the same namespace in a step
towards letting containers setting their own helpers.

Cc: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

diff --git a/fs/coredump.c b/fs/coredump.c
index ce47379..fa14ea1 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -455,6 +455,19 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 	/* and disallow core files too */
 	current->signal->rlim[RLIMIT_CORE] = (struct rlimit){1, 1};
 
+	/*
+	 * We want to run the helper within the same namespace. Since we
+	 * already forked, current here is using init_nsproxy and the usage
+	 * was already accounted. switch_task_namespace() will revert that
+	 * but we need to bump the dead process' nsproxy before calling the
+	 * the helper. Once it exits, the dead process' nsproxy usage will be
+	 * decremented as part of normal process exit.
+	 */
+	if (current->nsproxy != cp->nsproxy) {
+		get_nsproxy(cp->nsproxy);
+		switch_task_namespaces(current, cp->nsproxy);
+	}
+
 	return err;
 }
 
@@ -482,6 +495,8 @@ void do_coredump(siginfo_t *siginfo, struct pt_regs *regs)
 		 * by any locks.
 		 */
 		.mm_flags = mm->flags,
+		/* we run the helper in the same namespace */
+		.nsproxy = current->nsproxy,
 	};
 
 	audit_core_dumps(siginfo->si_signo);
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index cfcc6bf..45113e6 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -63,6 +63,7 @@ struct coredump_params {
 	struct file *file;
 	unsigned long limit;
 	unsigned long mm_flags;
+	struct nsproxy *nsproxy;
 };
 
 /*
