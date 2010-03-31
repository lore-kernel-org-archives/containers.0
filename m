From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add --nonetns switch to user-cr checkpoint
Date: Wed, 31 Mar 2010 07:41:22 -0700
Message-ID: <1270046482-16053-1-git-send-email-danms@us.ibm.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This allows the caller to set the CHECKPOINT_NONETNS flag on the checkpoint
operation, thus skipping the checkpointing of network namespaces entirely.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 app-checkpoint.h  |    1 +
 checkpoint-main.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/app-checkpoint.h b/app-checkpoint.h
index f740085..c078f04 100644
--- a/app-checkpoint.h
+++ b/app-checkpoint.h
@@ -5,6 +5,7 @@ struct app_checkpoint_args {
 	int uerrfd;
 	int container;
 	int verbose;
+	int flags;
 };
 
 struct app_restart_args {
diff --git a/checkpoint-main.c b/checkpoint-main.c
index f6faa32..bef6bfe 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -30,6 +30,7 @@ static char usage_str[] =
 "  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
 "     --logile-fd=FD     write error and debug data to file descriptor FD\n"
 "  -c,--container        require the PID is a container-init\n"
+"     --nonetns          do not checkpoint network namespace(s)\n"
 "  -v,--verbose          verbose output\n"
 "";
 
@@ -61,6 +62,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 		{ "logfile-fd",	required_argument,	NULL, 2 },
 		{ "container",	no_argument,		NULL, 'c' },
 		{ "verbose",	no_argument,		NULL, 'v' },
+		{ "nonetns",	no_argument,		NULL, 3 },
 		{ NULL,		0,			NULL, 0 }
 	};
 	static char optc[] = "hvco:l:";
@@ -71,6 +73,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 	args->outfd = -1;
 	args->logfd = -1;
 	args->uerrfd = fileno(stderr);
+	args->flags = 0;
 	output = NULL;
 	logfile = NULL;
 
@@ -109,6 +112,9 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 		case 'v':
 			args->verbose = 1;
 			break;
+		case 3:
+			args->flags |= CHECKPOINT_NONETNS;
+			break;
 		default:
 			usage(usage_str);
 		}
@@ -164,6 +170,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	flags = args.flags;
 	if (!args.container)
 		flags |= CHECKPOINT_SUBTREE;
 
-- 
1.6.3.3
