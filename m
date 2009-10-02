From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] restart: accept the lsm_name field in header and add
	-k flag
Date: Thu, 1 Oct 2009 22:51:57 -0500
Message-ID: <20091002035157.GA16920@us.ibm.com>
References: <20091002034916.GA16871@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091002034916.GA16871-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The checkpoint file header now has an 11-character string
containing the name of the active LSM, following the uts
info, and a variable length buffer type conaining LSM-specific
version information (for instance a sha1sum of policy).
Handle these.

Also add a -k (--keeplsm) flag to tell restart to set the
RESTART_KEEP_LSM flag to sys_restart().

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   32 +++++++++++++++++++++++++++++++-
 1 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index b810ca9..44ae252 100644
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
@@ -349,6 +350,8 @@ struct args {
 	char *input;
 };
 
+int keep_lsm;
+
 static void usage(char *str)
 {
 	fprintf(stderr, "%s", str);
@@ -377,6 +380,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "self",	no_argument,		NULL, 6},
 		{ "signal",	required_argument,	NULL, 4 },
 		{ "inspect",	no_argument,		NULL, 5 },
+		{ "keeplsm",	no_argument,		NULL, 'k' },
 		{ "input",	required_argument,	NULL, 'i' },
 		{ "root",	required_argument,	NULL, 'r' },
 		{ "wait",	no_argument,		NULL, 'w' },
@@ -388,7 +392,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdvpPwWF:r:i:";
+	static char optc[] = "hdvpkPwWF:r:i:";
 
 	int sig;
 
@@ -443,6 +447,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'w':
 			args->wait = 1;
 			break;
+		case 'k':
+			keep_lsm = RESTART_KEEP_LSM;
+			break;
 		case 'W':
 			args->wait = 0;
 			break;
@@ -927,6 +934,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->freezer)
 		flags |= RESTART_FROZEN;
 
+	flags |= keep_lsm;
 	ret = restart(root_pid, STDIN_FILENO, flags);
 
 	if (ret < 0) {
@@ -1581,6 +1589,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	if (task->flags & (TASK_GHOST | TASK_DEAD))
 		flags |= RESTART_GHOST;
 
+	flags |= keep_lsm;
 	/* on success this doesn't return */
 	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
 	ret = restart(0, STDIN_FILENO, flags);
@@ -2057,6 +2066,7 @@ static int ckpt_read_obj_buffer(struct ckpt_ctx *ctx, void *buf, int n)
  * read/write the checkpoint image: similar to in-kernel code
  */
 
+#define SECURITY_NAME_MAX 20
 static int ckpt_read_header(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_header *h;
@@ -2090,6 +2100,16 @@ static int ckpt_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_read_obj_buffer(ctx, ptr, SECURITY_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_read_obj_type(ctx, ptr, 200, CKPT_HDR_LSM_INFO);
+	if (ret < 0)
+		return ret;
+
 	/* FIXME: skip version validation for now */
 
 	return 0;
@@ -2169,6 +2189,16 @@ static int ckpt_write_header(struct ckpt_ctx *ctx)
 	ptr += ((struct ckpt_hdr *) ptr)->len;
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
 
+	if (ret < 0)
+		return ret;
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	if (ret < 0)
+		return ret;
+
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+
 	return ret;
 }
 
-- 
1.6.1.1
