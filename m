From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add --nonetns switch to user-cr checkpoint
Date: Wed, 31 Mar 2010 08:12:20 -0700
Message-ID: <87634ced9n.fsf@caffeine.danplanet.com>
References: <1270046482-16053-1-git-send-email-danms@us.ibm.com>
	<20100331145740.GA11124@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100331145740.GA11124-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed\, 31 Mar 2010 09\:57\:40 -0500")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> Also, args does get memset to 0 before parse_args() gets called so
SH> you don't need to set args->flag to 0 there.

I wanted it to be really, really zeroed.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

Add --nonetns switch to user-cr checkpoint (v2)

This allows the caller to set the CHECKPOINT_NONETNS flag on the checkpoint
operation, thus skipping the checkpointing of network namespaces entirely.

Changes in v2:
 - Allow -N for --nonetns
 - Remove extra flags initialization

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

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
index f6faa32..85b4133 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -30,6 +30,7 @@ static char usage_str[] =
 "  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
 "     --logile-fd=FD     write error and debug data to file descriptor FD\n"
 "  -c,--container        require the PID is a container-init\n"
+"  -N,--nonetns          do not checkpoint network namespace(s)\n"
 "  -v,--verbose          verbose output\n"
 "";
 
@@ -61,9 +62,10 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 		{ "logfile-fd",	required_argument,	NULL, 2 },
 		{ "container",	no_argument,		NULL, 'c' },
 		{ "verbose",	no_argument,		NULL, 'v' },
+		{ "nonetns",	no_argument,		NULL, 'N' },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hvco:l:";
+	static char optc[] = "hvco:l:N";
 	char *output;
 	char *logfile;
 
@@ -109,6 +111,9 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 		case 'v':
 			args->verbose = 1;
 			break;
+		case 'N':
+			args->flags |= CHECKPOINT_NONETNS;
+			break;
 		default:
 			usage(usage_str);
 		}
@@ -164,6 +169,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	flags = args.flags;
 	if (!args.container)
 		flags |= CHECKPOINT_SUBTREE;
