From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] restart: accept the lsm_name field in header and add
	-k flag (v2)
Date: Mon, 5 Oct 2009 16:58:52 -0500
Message-ID: <20091005215852.GD26081@us.ibm.com>
References: <20091005215114.GA26052@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091005215114.GA26052-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

[ Oren: I added your ack since you sent it to the previous
patch, but this patch changed quite a bit - maybe I shouldn't
have put the ack in after all, but please take another look ]

The checkpoint file header now has an 11-character string
containing the name of the active LSM, following the uts
info, and a variable length buffer type conaining LSM-specific
version information (for instance a sha1sum of policy).
Handle these.

Also add a -k (--keeplsm) flag to tell restart to set the
RESTART_KEEP_LSM flag to sys_restart().

Changelog:
	oct 05: 1. move keep_lsm into arg struct
		2. read a separate container config section
		3. use CHECKPOINT_LSM_NAME_MAX

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/restart.c b/restart.c
index c3f4349..d8409c4 100644
--- a/restart.c
+++ b/restart.c
@@ -34,7 +34,6 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-
 /* this really belongs to some kernel header ! */
 struct pid_set {
 	int num_pids;
@@ -68,6 +67,7 @@ static char usage_str[] =
 "     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
 "                        to container root, SIGINT otherwise)\n"
 "  -w,--wait             wait for root task to termiate (default)\n"
+"  -k,--keeplsm          Try to recreate original LSM labels on all objects\n"
 "     --show-status      show exit status of root task (implies -w)\n"
 "     --copy-status      imitate exit status of root task (implies -w)\n"
 "  -W,--no-wait          do not wait for root task to terminate\n"
@@ -264,6 +264,7 @@ struct ckpt_ctx {
 	
 	char header[BUFSIZE];
 	char header_arch[BUFSIZE];
+	char container[BUFSIZE];
 	char tree[BUFSIZE];
 	char buf[BUFSIZE];
 	struct args *args;
@@ -303,6 +304,7 @@ static int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
 
 static int ckpt_write_header(struct ckpt_ctx *ctx);
 static int ckpt_write_header_arch(struct ckpt_ctx *ctx);
+static int ckpt_write_container(struct ckpt_ctx *ctx);
 static int ckpt_write_tree(struct ckpt_ctx *ctx);
 
 static int _ckpt_read(int fd, void *buf, int count);
@@ -313,6 +315,7 @@ static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *b, int n, int type);
 
 static int ckpt_read_header(struct ckpt_ctx *ctx);
 static int ckpt_read_header_arch(struct ckpt_ctx *ctx);
+static int ckpt_read_container(struct ckpt_ctx *ctx);
 static int ckpt_read_tree(struct ckpt_ctx *ctx);
 
 static int hash_init(struct ckpt_ctx *ctx);
@@ -347,6 +350,7 @@ struct args {
 	int copy_status;
 	char *freezer;
 	char *input;
+	int keep_lsm;
 };
 
 static void usage(char *str)
@@ -377,6 +381,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "self",	no_argument,		NULL, 6},
 		{ "signal",	required_argument,	NULL, 4 },
 		{ "inspect",	no_argument,		NULL, 5 },
+		{ "keeplsm",	no_argument,		NULL, 'k' },
 		{ "input",	required_argument,	NULL, 'i' },
 		{ "root",	required_argument,	NULL, 'r' },
 		{ "wait",	no_argument,		NULL, 'w' },
@@ -388,7 +393,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdvpPwWF:r:i:";
+	static char optc[] = "hdvpkPwWF:r:i:";
 
 	int sig;
 
@@ -443,6 +448,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'w':
 			args->wait = 1;
 			break;
+		case 'k':
+			args->keep_lsm = RESTART_KEEP_LSM;
+			break;
 		case 'W':
 			args->wait = 0;
 			break;
@@ -693,6 +701,12 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	ret = ckpt_read_container(&ctx);
+	if (ret < 0) {
+		perror("read c/r container section");
+		exit(1);
+	}
+
 	ret = ckpt_read_tree(&ctx);
 	if (ret < 0) {
 		perror("read c/r tree");
@@ -927,6 +941,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->freezer)
 		flags |= RESTART_FROZEN;
 
+	flags |= ctx->args->keep_lsm;
 	ret = restart(root_pid, STDIN_FILENO, flags);
 
 	if (ret < 0) {
@@ -1575,6 +1590,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	if (task->flags & (TASK_GHOST | TASK_DEAD))
 		flags |= RESTART_GHOST;
 
+	flags |= ctx->args->keep_lsm;
 	/* on success this doesn't return */
 	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
 	ret = restart(0, STDIN_FILENO, flags);
@@ -1850,6 +1866,9 @@ static int ckpt_do_feeder(void *data)
 	if (ckpt_write_header_arch(ctx) < 0)
 		ckpt_abort(ctx, "write c/r header arch");
 
+	if (ckpt_write_container(ctx) < 0)
+		ckpt_abort(ctx, "write container section");
+
 	if (ckpt_write_tree(ctx) < 0)
 		ckpt_abort(ctx, "write c/r tree");
 
@@ -2102,6 +2121,27 @@ static int ckpt_read_header_arch(struct ckpt_ctx *ctx)
 	return 0;
 }
 
+static int ckpt_read_container(struct ckpt_ctx *ctx)
+{
+	int ret;
+	struct ckpt_hdr_container *h;
+	char *ptr;
+
+	h = (struct ckpt_hdr_container *) ctx->container;
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
+}
+
 static int ckpt_read_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
@@ -2174,6 +2214,28 @@ static int ckpt_write_header_arch(struct ckpt_ctx *ctx)
 	return ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 }
 
+static int ckpt_write_container(struct ckpt_ctx *ctx)
+{
+	char *ptr;
+	int ret;
+
+	ptr = (char *) ctx->container;
+	/* write the container info section */
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
+	return ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+}
+
 static int ckpt_write_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
-- 
1.6.1.1
