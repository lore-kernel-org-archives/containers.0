From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] add -t option to mount new devpts
Date: Thu, 3 Dec 2009 19:43:47 -0600
Message-ID: <20091204014347.GA17304@us.ibm.com>
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

Trivial patch, and I'm not sure whether we want this or want to
do it this way.  But it saves me having to do it during my restart.sh
wrapper shell-script.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index 063e973..03c1850 100644
--- a/restart.c
+++ b/restart.c
@@ -30,6 +30,7 @@
 #include <asm/unistd.h>
 #include <sys/syscall.h>
 #include <sys/prctl.h>
+#include <sys/mount.h>
 
 #include <linux/sched.h>
 #include <linux/checkpoint.h>
@@ -79,6 +80,7 @@ static char usage_str[] =
 "  -l,--logfile=FILE     write error and debug data to FILE (default=none)\n"
 "     --logfile-fd=FD    write error and debug data to file desctiptor FD\n"
 "     --inspect          inspect image on-the-fly for error records\n"
+"  -t,--pty		 start in a new devpts namespace to support ptys\n"
 "  -v,--verbose          verbose output\n"
 "  -d,--debug            debugging output\n"
 "     --warn-COND        warn on condition COND, but proceed anyways\n"
@@ -365,6 +367,7 @@ struct args {
 	long warn;
 	long fail;
 	int keep_lsm;
+	int pty;
 };
 
 #define CKPT_COND_PIDZERO  0x1
@@ -444,9 +447,10 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "debug",	no_argument,		NULL, 'd' },
 		{ "warn-pidzero",	no_argument,	NULL, 9 },
 		{ "fail-pidzero",	no_argument,	NULL, 10 },
+		{ "pty", no_argument,			NULL, 't'},
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hdvkpPwWF:r:i:l:";
+	static char optc[] = "hdvkpPwWF:r:i:l:t";
 
 	int optind;
 	int sig;
@@ -456,6 +460,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	args->wait = 1;
 	args->infd = -1;
 	args->logfd = -1;
+	args->pty = 0;
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, &optind);
@@ -469,6 +474,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		case 'v':
 			global_verbose = 1;
 			break;
+		case 't':
+			args->pty = 1;
+			break;
 		case 5:  /* --inspect */
 			args->inspect = 1;
 			break;
@@ -786,6 +794,31 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	/* private devpts namespace? */
+	if (args.pty) {
+		struct stat ptystat;
+		/* make sure /dev/ptmx is a link else we'll just break */
+		ret = lstat("/dev/ptmx", &ptystat);
+		if (ret) {
+			perror("stat /dev/ptmx");
+			exit(1);
+		}
+		if ((ptystat.st_mode & S_IFMT) != S_IFLNK) {
+			printf("Error: /dev/ptmx must be a link to /dev/pts/ptmx\n");
+			exit(1);
+		}
+		ret = unshare(CLONE_NEWNS);
+		if (ret) {
+			perror("unshare mounts ns (for -pty)");
+			exit(1);
+		}
+		ret = mount("pts", "/dev/pts", "devpts", 0, "newinstance");
+		if (ret) {
+			perror("mount -t devpts -o newinstance");
+			exit(1);
+		}
+	}
+
 	/* self-restart ends here: */
 	if (args.self) {
 		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.logfd);
-- 
1.6.1.1
