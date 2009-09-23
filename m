From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] restart: rename and cleanup switch to indicate
	signal-on-interrupt
Date: Tue, 22 Sep 2009 20:17:42 -0400
Message-ID: <1253665062-3711-1-git-send-email-orenl@librato.com>
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

When restartinig in --wait mode, an interrupt to the coordinator
translates to a signal to the root task. This patch fixes and
imrpoves the interface and logic of sending such signals.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |  132 ++++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 109 insertions(+), 23 deletions(-)

diff --git a/restart.c b/restart.c
index fbcc299..a25aaa9 100644
--- a/restart.c
+++ b/restart.c
@@ -58,21 +58,22 @@ static char usage_str[] =
 "usage: restart [opts]\n"
 "  restart restores from a checkpoint image by first creating in userspace\n"
 "  the original tasks tree, and then calling sys_restart by each task.\n"
-"\tOptions:\n"
-"\t -h,--help             print this help message\n"
-"\t -p,--pidns            create a new pid namspace (default with --pids)\n"
-"\t -P,--no-pidns         do not create a new pid namspace (default)\n"
-"\t    --pidns-intr=SIG   send SIG to root task on SIGINT (default: SIGKILL)\n"
-"\t    --pids             restore original pids (default with --pidns)\n"
-"\t -i,--inspect          inspect image on-the-fly for error records\n"
-"\t -r,--root=ROOT        restart under the directory ROOT instead of current\n"
-"\t -w,--wait             wait for (root) task to termiate (default)\n"
-"\t    --show-status      show exit status of (root) task (implies -w)\n"
-"\t    --copy-status      imitate exit status of (root) task (implies -w)\n"
-"\t -W,--no-wait          do not wait for (root) task to terminate\n"
-"\t -F,--freezer=CGROUP   freeze tasks in freezer group CGROUP on success\n"
-"\t -v,--verbose          verbose output\n"
-"\t -d,--debug            debugging output\n"
+"Options:\n"
+"  -h,--help             print this help message\n"
+"  -p,--pidns            create a new pid namspace (default with --pids)\n"
+"  -P,--no-pidns         do not create a new pid namespace (default)\n"
+"     --pids             restore original pids (default with --pidns)\n"
+"  -i,--inspect          inspect image on-the-fly for error records\n"
+"  -r,--root=ROOT        restart under the directory ROOT instead of current\n"
+"     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
+"                        to container root, SIGINT otherwise)\n"
+"  -w,--wait             wait for root task to termiate (default)\n"
+"     --show-status      show exit status of root task (implies -w)\n"
+"     --copy-status      imitate exit status of root task (implies -w)\n"
+"  -W,--no-wait          do not wait for root task to terminate\n"
+"  -F,--freezer=CGROUP   freeze tasks in freezer group CGROUP on success\n"
+"  -v,--verbose          verbose output\n"
+"  -d,--debug            debugging output\n"
 "";
 
 /*
@@ -128,6 +129,69 @@ static char usage_str[] =
 			printf(__VA_ARGS__);	\
 	} while(0)
 
+#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
+
+struct {
+	int signum;
+	char *sigstr;
+} signal_array[] = {
+	{ 0, "NONE" },
+	SIGNAL_ENTRY(ALRM),
+	SIGNAL_ENTRY(HUP),
+	SIGNAL_ENTRY(INT),
+	SIGNAL_ENTRY(KILL),
+	SIGNAL_ENTRY(PIPE),
+	SIGNAL_ENTRY(POLL),
+	SIGNAL_ENTRY(PROF),
+	SIGNAL_ENTRY(TERM),
+	SIGNAL_ENTRY(USR1),
+	SIGNAL_ENTRY(USR2),
+	SIGNAL_ENTRY(VTALRM),
+	SIGNAL_ENTRY(STKFLT),
+	SIGNAL_ENTRY(PWR),
+	SIGNAL_ENTRY(WINCH),
+	SIGNAL_ENTRY(CHLD),
+	SIGNAL_ENTRY(URG),
+	SIGNAL_ENTRY(TTIN),
+	SIGNAL_ENTRY(TTOU),
+	SIGNAL_ENTRY(STOP),
+	SIGNAL_ENTRY(CONT),
+	SIGNAL_ENTRY(ABRT),
+	SIGNAL_ENTRY(FPE),
+	SIGNAL_ENTRY(ILL),
+	SIGNAL_ENTRY(QUIT),
+	SIGNAL_ENTRY(SEGV),
+	SIGNAL_ENTRY(TRAP),
+	SIGNAL_ENTRY(SYS),
+	SIGNAL_ENTRY(BUS),
+	SIGNAL_ENTRY(XCPU),
+	SIGNAL_ENTRY(XFSZ),
+	{ -1, "LAST" },
+};
+
+static char *sig2str(int sig)
+{
+	int i = 0;
+
+	do {
+		if (signal_array[i].signum == sig)
+			return signal_array[i].sigstr;
+	} while (signal_array[++i].signum >= 0);
+	return "UNKNOWN SIGNAL";
+}
+
+static int str2sig(char *str)
+{
+	int sig = 0;
+
+	do {
+		if (!strcmp(signal_array[sig].sigstr, str))
+			return signal_array[sig].signum;
+	} while (signal_array[++sig].signum >= 0);
+
+	return -1;
+}
+
 inline static int restart(pid_t pid, int fd, unsigned long flags)
 {
 	return syscall(__NR_restart, pid, fd, flags);
@@ -287,14 +351,26 @@ static void usage(char *str)
 	exit(1);
 }
 
+/* negative retval means error */
+static int str2num(char *str)
+{
+	char *nptr;
+	int num;
+
+	num = strtol(str, &nptr, 10);
+	if (nptr - str != strlen(str))
+		num = -1;
+	return num;
+}
+
 static void parse_args(struct args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
 		{ "pidns",	no_argument,		NULL, 'p' },
-		{ "pidns-signal",	required_argument,	NULL, '4' },
 		{ "no-pidns",	no_argument,		NULL, 'P' },
 		{ "pids",	no_argument,		NULL, 3 },
+		{ "signal",	required_argument,	NULL, 4 },
 		{ "inspect",	no_argument,		NULL, 'i' },
 		{ "root",	required_argument,		NULL, 'r' },
 		{ "wait",	no_argument,		NULL, 'w' },
@@ -336,9 +412,11 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			args->no_pidns = 1;
 			break;
 		case 4:
-			sig = atoi(optarg);
+			sig = str2sig(optarg);
+			if (sig < 0)
+				sig = str2num(optarg);
 			if (sig < 0 || sig >= NSIG) {
-				printf("restart: invalid signal number\n");
+				printf("restart: invalid signal\n");
 				exit(1);
 			}
 			global_send_sigint = sig;
@@ -461,13 +539,21 @@ static void sigint_handler(int sig)
 {
 	pid_t pid = global_child_pid;
 
-	ckpt_verbose("SIGINT sent to restarted tasks\n");
+	sig = global_send_sigint;
+	if (!sig) {
+		ckpt_verbose("Interrupt attempt .. ignored.\n");
+		return;
+	}
+
+	ckpt_verbose("Interrupted: sent SIG%s to "
+		     "restarted tasks\n", sig2str(sig));
 
 	if (pid) {
-		ckpt_dbg("delegating SIGINT to child %d "
-			 "(coordinator or root task)\n", pid);
-		kill(-pid, SIGINT);
-		kill(pid, SIGINT);
+		ckpt_dbg("delegating SIG%s to child %d "
+			 "(coordinator/root task)\n",
+			 sig2str(sig), pid);
+		kill(-pid, sig);
+		kill(pid, sig);
 	}
 }
 
-- 
1.6.0.4
