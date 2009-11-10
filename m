From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/3] restart: add --warn-* and --fail-* command line switches
Date: Tue, 10 Nov 2009 17:04:51 -0500
Message-ID: <1257890692-28046-2-git-send-email-orenl@librato.com>
References: <1257890692-28046-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257890692-28046-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   74 ++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 64 insertions(+), 10 deletions(-)

diff --git a/restart.c b/restart.c
index 5871bbf..2efe879 100644
--- a/restart.c
+++ b/restart.c
@@ -79,6 +79,10 @@ static char usage_str[] =
 "     --inspect          inspect image on-the-fly for error records\n"
 "  -v,--verbose          verbose output\n"
 "  -d,--debug            debugging output\n"
+"     --warn-COND        warn on condition COND, but proceed anyways\n"
+"     --fail-COND        warn on condition COND, and abort operation\n"
+"  	  COND=any:        any condition\n"
+"  	  COND=pidzero:    task with sid/pgid zero in a --no-pidns restart\n"
 "";
 
 /*
@@ -359,8 +363,13 @@ struct args {
 	int infd;
 	char *logfile;
 	int logfd;
+	long warn;
+	long fail;
 };
 
+#define CKPT_COND_PIDZERO  0x1
+#define CKPT_COND_ANY      ULONG_MAX
+
 static void usage(char *str)
 {
 	fprintf(stderr, "%s", str);
@@ -379,6 +388,37 @@ static int str2num(char *str)
 	return num;
 }
 
+static long cond_to_mask(const char *cond)
+{
+	static struct {
+		char *cond;
+		long mask;
+	} conditions[] = {
+		{"pidzero", CKPT_COND_PIDZERO},
+		{"any", CKPT_COND_ANY},
+		{NULL, 0}
+	};
+
+	int i;
+
+	for (i = 0; conditions[i].cond; i++)
+		if (!strcmp(cond, conditions[i].cond))
+			return conditions[i].mask;
+
+	printf("restart: invalid warn/fail condition '%s'\n", cond);
+	exit(1);
+}
+
+static inline int ckpt_cond_warn(struct ckpt_ctx *ctx, long mask)
+{
+	return (ctx->args->warn & mask);
+}
+		
+static inline int ckpt_cond_fail(struct ckpt_ctx *ctx, long mask)
+{
+	return (ctx->args->fail & mask);
+}
+
 static void parse_args(struct args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
@@ -401,10 +441,13 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "freezer",	required_argument,	NULL, 'F' },
 		{ "verbose",	no_argument,		NULL, 'v' },
 		{ "debug",	no_argument,		NULL, 'd' },
+		{ "warn-pidzero",	no_argument,	NULL, 9 },
+		{ "fail-pidzero",	no_argument,	NULL, 10 },
 		{ NULL,		0,			NULL, 0 }
 	};
 	static char optc[] = "hdvpPwWF:r:i:l:";
 
+	int optind;
 	int sig;
 
 	/* defaults */
@@ -414,7 +457,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	args->logfd = -1;
 
 	while (1) {
-		int c = getopt_long(argc, argv, optc, opts, NULL);
+		int c = getopt_long(argc, argv, optc, opts, &optind);
 		if (c == -1)
 			break;
 		switch (c) {
@@ -494,6 +537,12 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'F':
 			args->freezer = optarg;
 			break;
+		case 9:
+			args->warn |= cond_to_mask(&opts[optind].name[5]);
+			break;
+		case 10:
+			args->fail |= cond_to_mask(&opts[optind].name[5]);
+			break;
 		default:
 			usage(usage_str);
 		}
@@ -1171,15 +1220,21 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 	return 0;
 }
 
-static inline int ckpt_valid_pid(pid_t pid, int pidns, char *which, int i)
+static int ckpt_valid_pid(struct ckpt_ctx *ctx, pid_t pid, char *which, int i)
 {
 	if (pid < 0) {
 		ckpt_err("Invalid %s %d (for task#%d)\n", which, pid, i);
 		return 0;
 	}
-	if (!pidns && pid == 0) {
-		ckpt_err("Zero %s (task#%d) requires pid-ns\n", which, i + 1);
-		return 0;
+	if (!ctx->args->pidns && pid == 0) {
+		if (ckpt_cond_fail(ctx, CKPT_COND_PIDZERO)) {
+			ckpt_err("[err] task # %d with %s zero"
+				 " (requires --pidns)\n", i + 1, which);
+			return 0;
+		} else if (ckpt_cond_warn(ctx, CKPT_COND_PIDZERO)) {
+			ckpt_err("[warn] task # %d with %s zero"
+				 " (consider --pidns)\n", i + 1, which);
+		}
 	}
 	return 1;
 }
@@ -1188,7 +1243,6 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_pids *pids_arr = ctx->pids_arr;
 	int pids_nr = ctx->pids_nr;
-	int pidns = ctx->args->pidns;
 	struct task *task;
 	pid_t root_pid;
 	pid_t root_sid;
@@ -1225,13 +1279,13 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 		task->flags = 0;
 
-		if (!ckpt_valid_pid(pids_arr[i].vpid, pidns, "pid", i))
+		if (!ckpt_valid_pid(ctx, pids_arr[i].vpid, "pid", i))
 			return -1;
-		else if (!ckpt_valid_pid(pids_arr[i].vtgid, pidns, "tgid", i))
+		else if (!ckpt_valid_pid(ctx, pids_arr[i].vtgid, "tgid", i))
 			return -1;
-		else if (!ckpt_valid_pid(pids_arr[i].vsid, pidns, "sid", i))
+		else if (!ckpt_valid_pid(ctx, pids_arr[i].vsid, "sid", i))
 			return -1;
-		else if (!ckpt_valid_pid(pids_arr[i].vpgid, pidns, "pgid", i))
+		else if (!ckpt_valid_pid(ctx, pids_arr[i].vpgid, "pgid", i))
 			return -1;
 
 		/* zero references to root_sid (root_sid != root_pid) */
-- 
1.6.0.4
