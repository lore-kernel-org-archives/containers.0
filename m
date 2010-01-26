From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] restart: --mntns option restarts in a private mounts namespace
Date: Mon, 25 Jan 2010 23:38:38 -0500
Message-ID: <1264480718-30462-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

When this new switch is specified, the coordinator will unshare the
mounts namespace and restart will occur inside a private namespace.
Without it the restarting tasks will share the current mounts
namespace.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/restart.c b/restart.c
index 9d1c1d1..f3d33de 100644
--- a/restart.c
+++ b/restart.c
@@ -51,6 +51,7 @@ static char usage_str[] =
 "  -r,--root=ROOT        restart under the directory ROOT instead of current\n"
 "     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
 "                        to container root, SIGINT otherwise)\n"
+"     --mntns            restart under a private mounts namespace\n"
 "  -w,--wait             wait for root task to termiate (default)\n"
 "     --show-status      show exit status of root task (implies -w)\n"
 "     --copy-status      imitate exit status of root task (implies -w)\n"
@@ -337,6 +338,7 @@ struct args {
 	int inspect;
 	char *root;
 	int wait;
+	int mntns;
 	int show_status;
 	int copy_status;
 	char *freezer;
@@ -417,6 +419,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "logfile",	required_argument,	NULL, 'l' },
 		{ "logfile-fd",	required_argument,	NULL, 8 },
 		{ "root",	required_argument,	NULL, 'r' },
+		{ "mntns",	no_argument,		NULL, 11 },
 		{ "wait",	no_argument,		NULL, 'w' },
 		{ "show-status",	no_argument,	NULL, 1 },
 		{ "copy-status",	no_argument,	NULL, 2 },
@@ -529,6 +532,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 10:
 			args->fail |= cond_to_mask(&opts[optind].name[5]);
 			break;
+		case 11:
+			args->mntns = 1;
+			break;
 		default:
 			usage(usage_str);
 		}
@@ -764,6 +770,12 @@ int main(int argc, char *argv[])
 	if (args.freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
 
+	/* private mounts namespace ? */
+	if (args.mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
+		perror("unshare");
+		exit(1);
+	}
+
 	/* chroot ? */
 	if (args.root && chroot(args.root) < 0) {
 		perror("chroot");
@@ -1011,8 +1023,8 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 
 	/*
 	 * The coordinator report restart susccess/failure via pipe.
-	 * (It cannot use return value, because the in the default
-	 * --wait --copy-status case it is already used to report the
+	 * (It cannot use return value, because in the default case
+	 * of --wait --copy-status it is already used to report the
 	 * root-task's return value).
 	 */
 	if (pipe(ctx->pipe_coord) < 0) {
-- 
1.6.3.3
