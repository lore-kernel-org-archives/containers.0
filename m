From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [user-cr PATCH] mktree: accept the lsm_name field in header and
	add -k flag
Date: Thu, 6 Aug 2009 11:20:51 -0500
Message-ID: <20090806162051.GB1607@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The checkpoint file header now has an 11-character string
containing the name of the active LSM, following the uts
info.

Also add a -k (--keeplsm) flag to tell mktree to set the
RESTART_KEEP_LSM flag to sys_restart().

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/mktree.c b/mktree.c
index e42407f..652dbb7 100644
--- a/mktree.c
+++ b/mktree.c
@@ -45,6 +45,7 @@ static char usage_str[] =
 "\t -P,--no-pidns         do not create a new pid namspace (default)\n"
 "\t    --pids             restore original pids (default with --pidns)\n"
 "\t -w,--wait             wait for (root) task to termiate (default)\n"
+"\t -k,--keeplsm          Try to recreate original LSM labels on all objects\n"
 "\t    --show-status      show exit status of (root) task (implies -w)\n"
 "\t    --copy-status      imitate exit status of (root) task (implies -w)\n"
 "\t -W,--no-wait          do not wait for (root) task to terminate\n"
@@ -259,6 +260,8 @@ struct args {
 	char *freezer;
 };
 
+int keep_lsm;
+
 static void usage(char *str)
 {
 	fprintf(stderr, "%s", str);
@@ -273,6 +276,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "pidns-signal",	required_argument,	NULL, '4' },
 		{ "no-pidns",	no_argument,		NULL, 'P' },
 		{ "pids",	no_argument,		NULL, 3 },
+		{ "keeplsm",	no_argument,		NULL, 'k' },
 		{ "wait",	no_argument,		NULL, 'w' },
 		{ "show-status",	no_argument,	NULL, 1 },
 		{ "copy-status",	no_argument,	NULL, 2 },
@@ -282,7 +286,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdvpPwWF:";
+	static char optc[] = "hdvpPkwWF:";
 
 	int sig;
 
@@ -320,6 +324,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			args->pids = 1;
 			args->pidns = 1;  /* implied */
 			break;
+		case 'k':
+			keep_lsm = RESTART_KEEP_LSM;
+			break;
 		case 'w':
 			args->wait = 1;
 			break;
@@ -750,6 +757,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->freezer)
 		flags |= RESTART_FROZEN;
 
+	flags |= keep_lsm;
 	ret = restart(root_pid, STDIN_FILENO, flags);
 
 	if (ret < 0) {
@@ -1309,7 +1317,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 
 	/* on success this doesn't return */
 	ckpt_dbg("about to call sys_restart()\n");
-	ret = restart(0, STDIN_FILENO, 0);
+	ret = restart(0, STDIN_FILENO, keep_lsm);
 	if (ret < 0)
 		perror("task restore failed");
 	return ret;
@@ -1703,6 +1711,7 @@ static int ckpt_read_obj_buffer(struct ckpt_ctx *ctx, void *buf, int n)
  * read/write the checkpoint image: similar to in-kernel code
  */
 
+#define SECURITY_NAME_MAX 10
 static int ckpt_read_header(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_header *h;
@@ -1736,6 +1745,11 @@ static int ckpt_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_read_obj_buffer(ctx, ptr, SECURITY_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
 	/* FIXME: skip version validation for now */
 
 	return 0;
@@ -1814,6 +1828,10 @@ static int ckpt_write_header(struct ckpt_ctx *ctx)
 		return ret;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	if (ret < 0)
+		return ret;
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
 
 	return ret;
 }
-- 
1.6.1.1
