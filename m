From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH user-cr] restart: accept the lsm_name field in header and add
	-k flag (v2)
Date: Wed, 11 Nov 2009 09:58:49 -0600
Message-ID: <1257955132-8398-3-git-send-email-serue@us.ibm.com>
References: <1257955132-8398-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257955132-8398-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

The checkpoint file header now has an 11-character string
containing the name of the active LSM, following the uts
info, and a variable length buffer type conaining LSM-specific
version information (for instance a sha1sum of policy).
Handle these.

Also add a -k (--keeplsm) flag to tell restart to set the
RESTART_KEEP_LSM flag to sys_restart().

Changelog:
nov 11: rebase
oct 15: separate out from container config section patch
oct 05: 1. move keep_lsm into arg struct
	2. read a separate container config section
	3. use CHECKPOINT_LSM_NAME_MAX

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   39 +++++++++++++++++++++++++++++++++++++--
 1 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/restart.c b/restart.c
index 35c54ea..86196c7 100644
--- a/restart.c
+++ b/restart.c
@@ -68,6 +68,7 @@ static char usage_str[] =
 "     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
 "                        to container root, SIGINT otherwise)\n"
 "  -w,--wait             wait for root task to termiate (default)\n"
+"  -k,--keeplsm          Try to recreate original LSM labels on all objects\n"
 "     --show-status      show exit status of root task (implies -w)\n"
 "     --copy-status      imitate exit status of root task (implies -w)\n"
 "  -W,--no-wait          do not wait for root task to terminate\n"
@@ -359,6 +360,7 @@ struct args {
 	int infd;
 	char *logfile;
 	int logfd;
+	int keep_lsm;
 };
 
 static void usage(char *str)
@@ -389,6 +391,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "self",	no_argument,		NULL, 6},
 		{ "signal",	required_argument,	NULL, 4 },
 		{ "inspect",	no_argument,		NULL, 5 },
+		{ "keeplsm",	no_argument,		NULL, 'k' },
 		{ "input",	required_argument,	NULL, 'i' },
 		{ "input-fd",	required_argument,	NULL, 7 },
 		{ "logfile",	required_argument,	NULL, 'l' },
@@ -403,7 +406,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdvpPwWF:r:i:l:";
+	static char optc[] = "hdvpkPwWF:r:i:l:";
 
 	int sig;
 
@@ -477,6 +480,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'w':
 			args->wait = 1;
 			break;
+		case 'k':
+			args->keep_lsm = RESTART_KEEP_LSM;
+			break;
 		case 'W':
 			args->wait = 0;
 			break;
@@ -1020,6 +1026,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->freezer)
 		flags |= RESTART_FROZEN;
 
+	flags |= ctx->args->keep_lsm;
 	ret = restart(root_pid, STDIN_FILENO, flags, ctx->args->logfd);
 
 	if (ret < 0) {
@@ -1688,6 +1695,8 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	if (task->flags & (TASK_GHOST | TASK_DEAD))
 		flags |= RESTART_GHOST;
 
+	flags |= ctx->args->keep_lsm;
+
 	/* on success this doesn't return */
 	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
 	ret = restart(0, STDIN_FILENO, flags, CHECKPOINT_FD_NONE);
@@ -2265,10 +2274,23 @@ static int ckpt_read_header_arch(struct ckpt_ctx *ctx)
 
 static int ckpt_read_container(struct ckpt_ctx *ctx)
 {
+	int ret;
 	struct ckpt_hdr_container *h;
+	char *ptr;
 
 	h = (struct ckpt_hdr_container *) ctx->container;
-	return ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_CONTAINER);
+	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (ret < 0)
+		return ret;
+
+	ptr = (char *) h;
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_read_obj_buffer(ctx, ptr, CHECKPOINT_LSM_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	return ckpt_read_obj_type(ctx, ptr, 200, CKPT_HDR_LSM_INFO);
 }
 
 static int ckpt_read_tree(struct ckpt_ctx *ctx)
@@ -2346,9 +2368,22 @@ static int ckpt_write_header_arch(struct ckpt_ctx *ctx)
 static int ckpt_write_container(struct ckpt_ctx *ctx)
 {
 	char *ptr;
+	int ret;
 
 	ptr = (char *) ctx->container;
 	/* write the container info section */
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	if (ret < 0)
+		return ret;
+
+	/* write the lsm name buffer */
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	if (ret < 0)
+		return ret;
+
+	/* write the lsm policy section */
+	ptr += ((struct ckpt_hdr *) ptr)->len;
 	return ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
 }
 
-- 
1.6.1.1
