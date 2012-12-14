From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH v2] core_pattern: set core helpers root and namespace to
	crashing process
Date: Fri, 14 Dec 2012 16:04:08 -0500
Message-ID: <1355519048-28473-1-git-send-email-nhorman__46759.2030451216$1355519117$gmane$org@tuxdriver.com>
References: <1355255996-25953-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355255996-25953-1-git-send-email-nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

As its currently implemented, redirection of core dumps to a pipe reader should
be executed such that the reader runs in the namespace of the crashing process,
and it currently does not. This is the only sane way to deal with namespaces
properly it seems to me, and this patch implements that functionality.

Theres one problem I currently see with it, and that is that I'm not sure we can
change the current behavior of how the root fs is set for the pipe reader, lest
we break some user space expectations.  As such I've made the switching of
namespaces configurable based on the addition of an extra '|' token in the
core_pattern sysctl.  1 '|' indicates a pipe using the global namespace, while
2 '|' indicates that the namespace and root of the crashing process should be
used.

I've tested this using both settings for the new sysctl, and it works well.

For the sake of history, this was discussed before:
http://www.spinics.net/lists/linux-containers/msg21531.html

It seems there was some modicum of consensus as to how this should work, but
there was no action taken on it.

Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Reported-by: Daniel Berrange <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Daniel Berrange <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
CC: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
CC: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 Documentation/sysctl/kernel.txt |  7 ++++++-
 fs/coredump.c                   | 23 +++++++++++++++++++++++
 include/linux/binfmts.h         |  2 ++
 3 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 2907ba6..f853fca 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -191,7 +191,12 @@ core_pattern is used to specify a core dumpfile pattern name.
 	%<OTHER> both are dropped
 . If the first character of the pattern is a '|', the kernel will treat
   the rest of the pattern as a command to run.  The core dump will be
-  written to the standard input of that program instead of to a file.
+  written to the standard input of that program instead of to a file.  Note that
+  when using |, the core pipe reader that is executed will be run in the global
+  namespace and root filesystem.  If two | tokens (i.e. ||) are supplied as the
+  first two characters of the core_pattern sysctl, the kernel will preform the
+  same pipe operation, but the core pipe reader will be executed using the
+  namespace and root fs of the crashing process.
 
 ==============================================================
 
diff --git a/fs/coredump.c b/fs/coredump.c
index ce47379..d4b71c0 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -164,6 +164,18 @@ static int format_corename(struct core_name *cn, struct coredump_params *cprm)
 	if (!cn->corename)
 		return -ENOMEM;
 
+	if (ispipe) {
+		/*
+ 		 * If we have 2 | tokens at the head of core_pattern, it
+ 		 * indicates we are a pipe and the reader should inherit the
+ 		 * namespaces of the crashing process
+ 		 */
+		cprm->switch_ns = (*(pat_ptr+1) == '|') ? true : false;
+		if (cprm->switch_ns)
+			/* Advance pat_ptr so as not to mess up corename */
+			pat_ptr++;
+	}
+
 	/* Repeat as long as we have more pattern to process and more output
 	   space */
 	while (*pat_ptr) {
@@ -443,6 +455,7 @@ static void wait_for_dump_helpers(struct file *file)
 static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 {
 	struct file *files[2];
+	struct path root;
 	struct coredump_params *cp = (struct coredump_params *)info->data;
 	int err = create_pipe_files(files, 0);
 	if (err)
@@ -455,6 +468,14 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 	/* and disallow core files too */
 	current->signal->rlim[RLIMIT_CORE] = (struct rlimit){1, 1};
 
+
+	if (cp->switch_ns) {
+		get_fs_root(cp->cprocess->fs, &root);
+		set_fs_root(current->fs, &root);
+		switch_task_namespaces(current, cp->cprocess->nsproxy);
+	}
+
+
 	return err;
 }
 
@@ -476,6 +497,8 @@ void do_coredump(siginfo_t *siginfo, struct pt_regs *regs)
 		.siginfo = siginfo,
 		.regs = regs,
 		.limit = rlimit(RLIMIT_CORE),
+		.cprocess = current,
+		.switch_ns = false,
 		/*
 		 * We must use the same mm->flags while dumping core to avoid
 		 * inconsistency of bit flags, since this flag is not protected
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index cfcc6bf..3f06261 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -61,6 +61,8 @@ struct coredump_params {
 	siginfo_t *siginfo;
 	struct pt_regs *regs;
 	struct file *file;
+	struct task_struct *cprocess;
+	bool switch_ns;
 	unsigned long limit;
 	unsigned long mm_flags;
 };
-- 
1.7.11.7
