From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] nsexec: remount proc and devpts
Date: Mon, 15 Feb 2010 16:58:16 -0600
Message-ID: <1266274696-23018-4-git-send-email-serue@us.ibm.com>
References: <1266274696-23018-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266274696-23018-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Add -t as an nsexec option to request new devpts.

Automatically remount /proc if we are starting a new pidns.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 nsexec.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/nsexec.c b/nsexec.c
index 8b96bc9..3a825f1 100644
--- a/nsexec.c
+++ b/nsexec.c
@@ -15,6 +15,7 @@
 #include <sys/stat.h>
 #include <sys/types.h>
 #include <sys/wait.h>
+#include <sys/mount.h>
 
 #include "clone.h"
 #include "eclone.h"
@@ -43,6 +44,7 @@ static void usage(const char *name)
 	printf("  -i		ipc namespace\n");
 	printf("  -P <pid-file>	File in which to write global pid of cinit\n");
 	printf("  -p		pid namespace\n");
+	printf("  -t		mount new devpts\n");
 	printf("  -f <flag>	extra clone flags\n");
 	printf("\n");
 	printf("(C) Copyright IBM Corp. 2006\n");
@@ -189,6 +191,38 @@ int do_child(void *vargv)
 	if (check_newcgrp())
 		return 1;
 
+	/* if pid == 1 then remount /proc */
+	/* But if the container has no /proc don't fret */
+	if (getpid() == 1) {
+		umount2("/proc", MNT_DETACH);
+		mount("proc", "/proc", "proc", 0, NULL);
+	}
+
+	/* check if we should remount devpts */
+	if (strcmp(argv[0], "newpts") == 0) {
+		struct stat ptystat;
+		argv++;
+		if (lstat("/dev/ptmx", &ptystat) < 0) {
+			perror("stat /dev/ptmx");
+			return -1;
+		}
+		if ((ptystat.st_mode & S_IFMT) != S_IFLNK) {
+			printf("Error: /dev/ptmx must be a link to /dev/pts/ptmx\n");
+			printf("       do: chmod 666 /dev/pts/ptmx\n");
+			printf("           rm /dev/ptmx\n");
+			printf("           ln -s /dev/pts/ptmx /dev/ptmx\n");
+			return -1;
+		}
+
+		/* if container had no /dev/pts mounted don't fret */
+		umount2("/dev/pts", MNT_DETACH);
+
+		if (mount("pts", "/dev/pts", "devpts", 0, "ptmxmode=666,newinstance") < 0) {
+			perror("mount -t devpts -o newinstance");
+			return -1;
+		}
+	}
+
 	execve(argv[0], argv, __environ);
 	perror("execve");
 	return 1;
@@ -217,18 +251,19 @@ int main(int argc, char *argv[])
 	unsigned long flags = 0, eflags = 0;
 	char ttyname[256];
 	int status;
-	int ret, use_clone = 0;
+	int ret, use_clone = 0, newpts = 0;
 	int pid;
 	char *pid_file = NULL;
 	size_t nr_pids = 1;
 	pid_t chosen_pid = 0;
+	char **newargv;
 
 	procname = basename(argv[0]);
 
 	memset(ttyname, '\0', sizeof(ttyname));
 	readlink("/proc/self/fd/0", ttyname, sizeof(ttyname));
 
-	while ((c = getopt(argc, argv, "+mguUiphz:cnf:P:")) != EOF) {
+	while ((c = getopt(argc, argv, "+mguUiphz:cntf:P:")) != EOF) {
 		switch (c) {
 		case 'g': do_newcgrp = getpid();		break;
 		case 'm': flags |= CLONE_NEWNS;			break;
@@ -239,6 +274,7 @@ int main(int argc, char *argv[])
 		case 'U': flags |= CLONE_NEWUSER;		break;
 		case 'n': flags |= CLONE_NEWNET;		break;
 		case 'p': flags |= CLONE_NEWNS|CLONE_NEWPID;	break;
+		case 't': newpts = 1; flags |= CLONE_NEWNS;	break;
 		case 'z': chosen_pid = atoi(optarg);		break;
 		case 'f': if (!string_to_ul(optarg, &eflags)) {
 				flags |= eflags;
@@ -259,6 +295,16 @@ int main(int argc, char *argv[])
 	}
 	argv = &argv[optind];
 	argc = argc - optind;
+	if (newpts) {
+		/* tell do_child about newpts through first arg */
+		int i;
+		newargv = (char **) malloc(sizeof(char *) * (argc+2));
+		newargv[0] = "newpts";
+		newargv[argc+1] = NULL;
+		for (i=0; i<argc; i++)
+			newargv[i+1] = argv[i];
+		argv = newargv;
+	}
 
 	if (do_newcgrp) {
 		ret = pipe(pipefd);
-- 
1.6.0.6
