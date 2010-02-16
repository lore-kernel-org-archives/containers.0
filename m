From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH cr_tests] Use nsexec from user-cr
Date: Tue, 16 Feb 2010 12:41:53 -0600
Message-ID: <20100216184153.GA19610@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Have common.sh find nsexec (should be installed in /bin by user-cr)
and call it $NSEXEC.  Have all tests use $NSEXEC.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile                      |    2 +-
 bashckpt/bash-cr.sh           |    2 +-
 common.sh                     |    5 +
 counterloop/cloop_once.sh     |    2 +-
 counterloop/cloop_parallel.sh |    2 +-
 counterloop/cloop_serial.sh   |    2 +-
 fileio/run-fcntltests.sh      |    7 +-
 fileio/run-fileio1.sh         |    9 +-
 ipc/test-mq.sh                |    6 +-
 ipc/test-sem.sh               |    8 +-
 ipc/test-shm.sh               |    8 +-
 ns_exec.c                     |  318 -----------------------------------------
 process-tree/run-pthread1.sh  |    7 +-
 process-tree/run-pthread2.sh  |    7 +-
 process-tree/run-pthread3.sh  |    7 +-
 process-tree/run-ptree1.sh    |    7 +-
 simple/runtests.sh            |    3 +-
 17 files changed, 42 insertions(+), 360 deletions(-)
 delete mode 100644 ns_exec.c

diff --git a/Makefile b/Makefile
index 0f3ff68..e8eb048 100644
--- a/Makefile
+++ b/Makefile
@@ -25,7 +25,7 @@ all:
 
 include $(addsuffix /module.mk,$(modules))
 
-progs += ns_exec mysu
+progs += mysu
 
 .PHONY: all
 all: $(progs)
diff --git a/bashckpt/bash-cr.sh b/bashckpt/bash-cr.sh
index 725466c..3b7ee4b 100755
--- a/bashckpt/bash-cr.sh
+++ b/bashckpt/bash-cr.sh
@@ -30,7 +30,7 @@ echo results in $tmpdir ' EXIT
 echo "Running ./bash-simple.sh in background."
 ./bash-simple.sh $$ $tmpdir &
 
-# note: $! is the pid of ns_exec, not the command, so we need to be a
+# note: $! is the pid of nsexec, not the command, so we need to be a
 # little more clever to derive the pid to pass to ip link set netns
 
 echo -n "Waiting for background script to start... "
diff --git a/common.sh b/common.sh
index 99a7968..28b87f1 100644
--- a/common.sh
+++ b/common.sh
@@ -110,3 +110,8 @@ if [ $? -ne 0 ]; then
 	echo "BROK: restart not found in your path"
 	exit 1
 fi
+NSEXEC=`which nsexec`
+if [ $? -ne 0 ]; then
+	echo "BROK: nsexec not found in your path"
+	exit 1
+fi
diff --git a/counterloop/cloop_once.sh b/counterloop/cloop_once.sh
index 89c4d13..18e8b15 100644
--- a/counterloop/cloop_once.sh
+++ b/counterloop/cloop_once.sh
@@ -21,7 +21,7 @@ my_debug()
 killall crcounter
 
 echo BAD > $dir/counter_out
-../ns_exec -m ./crcounter $dir &
+$NSEXEC -m ./crcounter $dir &
 while [ "`cat $dir/counter_out`" == "BAD" ]; do : ; done
 pid=`pidof crcounter`
 
diff --git a/counterloop/cloop_parallel.sh b/counterloop/cloop_parallel.sh
index 996fcaa..ce664b7 100644
--- a/counterloop/cloop_parallel.sh
+++ b/counterloop/cloop_parallel.sh
@@ -83,7 +83,7 @@ while [ $kidsdone -eq 0 ]; do checkchildren counter_out; done
 echo "... all jobs started"
 canceltimer
 
-pids=`ps -ef | grep crcounter | grep -v grep | grep -v ns_exec | awk -F\  '{ print $2 '}`
+pids=`ps -ef | grep crcounter | grep -v grep | grep -v nsexec | awk -F\  '{ print $2 '}`
 
 cnt=1
 
diff --git a/counterloop/cloop_serial.sh b/counterloop/cloop_serial.sh
index 8945395..cc94db4 100644
--- a/counterloop/cloop_serial.sh
+++ b/counterloop/cloop_serial.sh
@@ -63,7 +63,7 @@ if [ $fail -ne 0 ]; then
 	echo "WARN there were $fail restart failures"
 fi
 
-numjobs=`ps -ef | grep crcounter | grep -v grep | grep -v ns_exec | wc -l`
+numjobs=`ps -ef | grep crcounter | grep -v grep | grep -v nsexec | wc -l`
 killall crcounter
 
 if [ $numjobs -ne 1 ]; then
diff --git a/fileio/run-fcntltests.sh b/fileio/run-fcntltests.sh
index 2a5f628..aafc040 100755
--- a/fileio/run-fcntltests.sh
+++ b/fileio/run-fcntltests.sh
@@ -41,8 +41,7 @@ CHECKPOINT_DONE="checkpoint-done"
 LOGS_DIR="logs.d"
 DATA_DIR="data.d"
 
-NS_EXEC="../../ns_exec"
-NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+NSEXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 checkpoint()
 {
@@ -95,7 +94,7 @@ function create_container()
 {
 	local pid;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $TEST_CMD $TEST_ARGS"
+	cmdline="$NSEXEC $NSEXEC_ARGS -- $TEST_CMD $TEST_ARGS"
 
 	$ECHO "\t- Creating container:"
 	$ECHO "\t- $cmdline"
@@ -224,7 +223,7 @@ while [ $cnt -lt 20 ]; do
 	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
-	# ns_exec pid is parent-pid of restarted-container-init
+	# nsexec pid is parent-pid of restarted-container-init
 	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
diff --git a/fileio/run-fileio1.sh b/fileio/run-fileio1.sh
index c7179ab..36528e8 100755
--- a/fileio/run-fileio1.sh
+++ b/fileio/run-fileio1.sh
@@ -23,7 +23,6 @@ TEST_LOG_SNAP="$dir/log.${test_case}.snap"
 
 LOG_FILE="$dir/f1-loop.log"
 TEST_CMD="./$test_case"
-NS_EXEC="../ns_exec"
 
 # Make sure no stray TEST_CMD from another run is still going
 killall $TEST_CMD
@@ -46,7 +45,7 @@ for testnum in `seq 1 $NUMTESTS`; do
 	# Remove CKPT_READY file, start the application and let app tell
 	# us when it is ready
 	rm -f $CKPT_READY;
-	$NS_EXEC -m $TEST_CMD -d $dir -c $SRC_FILE $DEST_FILE &
+	$NSEXEC -m $TEST_CMD -d $dir -c $SRC_FILE $DEST_FILE &
 	while [ ! -f $CKPT_READY ]; do
 		sleep 1;
 	done;
@@ -94,7 +93,7 @@ for testnum in `seq 1 $NUMTESTS`; do
 	rm -f $COPY_DONE;
 
 	# Restart.
-	$NS_EXEC -m rstrsh $CKPT_FILE &
+	$NSEXEC -m rstrsh $CKPT_FILE &
 	ret=$?
 
 	if [ $ret -ne 0 ]; then
@@ -112,9 +111,9 @@ for testnum in `seq 1 $NUMTESTS`; do
 		exit 1
 	fi
 
-	nspid=`pidof $NS_EXEC`
+	nspid=`pidof $NSEXEC`
 	if [ "x$nspid" == "x" ]; then
-		echo "Can't find pid of $NS_EXEC"
+		echo "Can't find pid of $NSEXEC"
 		exit 1
 	fi
 
diff --git a/ipc/test-mq.sh b/ipc/test-mq.sh
index 957ec91..fc5343e 100644
--- a/ipc/test-mq.sh
+++ b/ipc/test-mq.sh
@@ -33,7 +33,7 @@ do_checkpoint() {
 
 echo "XXX Test 1: simple restart with SYSVIPC msq"
 clean_all
-../../ns_exec -ci ../check-mq &
+$NSEXEC -ci ../check-mq &
 do_checkpoint
 # Restart it.  If it finds the msq it created, it creates msq-ok
 $RESTART --pids < ckpt.msq
@@ -45,7 +45,7 @@ echo "PASS"
 
 echo "XXX Test 2: re-create root-owned msq as non-root user"
 clean_all
-../../ns_exec -ci ../check-mq -u 501 &
+$NSEXEC -ci ../check-mq -u 501 &
 do_checkpoint
 # restart should fail to create msq
 $RESTART --pids --copy-status < ckpt.msq
@@ -58,7 +58,7 @@ echo "PASS"
 # Create msq as non-root user
 echo "XXX Test 3: create msq as non-root user and restart"
 clean_all
-../../ns_exec -ci ../check-mq -e -u 501 &
+$NSEXEC -ci ../check-mq -e -u 501 &
 do_checkpoint
 # restart should be able to create msq
 $RESTART --pids --copy-status < ckpt.msq
diff --git a/ipc/test-sem.sh b/ipc/test-sem.sh
index 52c96a3..0144c8b 100644
--- a/ipc/test-sem.sh
+++ b/ipc/test-sem.sh
@@ -33,7 +33,7 @@ do_checkpoint() {
 
 echo "XXX Test 1: simple restart with SYSVIPC semaphores"
 clean_all
-../../ns_exec -ci ../create-sem &
+$NSEXEC -ci ../create-sem &
 do_checkpoint
 # Restart it.  If it finds the sem it created, it creates sem-ok
 $RESTART --pids < ckpt.sem
@@ -45,7 +45,7 @@ echo "PASS"
 
 echo "XXX Test 2: re-create root-owned semaphores as non-root user"
 clean_all
-../../ns_exec -ci ../create-sem -u 501 &
+$NSEXEC -ci ../create-sem -u 501 &
 do_checkpoint
 # restart should fail to create sems
 $RESTART --pids < ckpt.sem
@@ -58,7 +58,7 @@ echo "PASS"
 # Create semaphores as non-root user
 echo "XXX Test 3: create semaphores as non-root user and restart"
 clean_all
-../../ns_exec -ci ../create-sem -e -u 501 &
+$NSEXEC -ci ../create-sem -e -u 501 &
 do_checkpoint
 # restart should be able to create sems
 $RESTART --pids  --copy-status < ckpt.sem
@@ -74,7 +74,7 @@ if [ $uid -eq -1 ]; then
 	echo "not running ltp-uid test"
 	exit 0
 fi
-../../ns_exec -ci ../create-sem -r -u $uid &
+$NSEXEC -ci ../create-sem -r -u $uid &
 do_checkpoint
 chown $uid ckpt.sem
 setcap cap_sys_admin+pe $RESTART
diff --git a/ipc/test-shm.sh b/ipc/test-shm.sh
index 4bd79df..06f1add 100644
--- a/ipc/test-shm.sh
+++ b/ipc/test-shm.sh
@@ -33,7 +33,7 @@ do_checkpoint() {
 
 echo "XXX Test 1: simple restart with SYSVIPC shm"
 clean_all
-../../ns_exec -ci ../create-shm &
+$NSEXEC -ci ../create-shm &
 do_checkpoint
 # Restart it.  If it finds the shm it created, it creates shm-ok
 $RESTART --pids --copy-status < ckpt.shm
@@ -45,7 +45,7 @@ echo "PASS"
 
 echo "XXX Test 2: re-create root-owned shm as non-root user"
 clean_all
-../../ns_exec -ci ../create-shm -u 501 &
+$NSEXEC -ci ../create-shm -u 501 &
 do_checkpoint
 # restart should fail to create shm
 $RESTART --pids --copy-status < ckpt.shm
@@ -58,7 +58,7 @@ echo "PASS"
 # Create shm as non-root user
 echo "XXX Test 3: create shm as non-root user and restart"
 clean_all
-../../ns_exec -ci ../create-shm -e -u 501 &
+$NSEXEC -ci ../create-shm -e -u 501 &
 do_checkpoint
 # restart should be able to create shm
 $RESTART --pids --copy-status < ckpt.shm
@@ -74,7 +74,7 @@ if [ $uid -eq -1 ]; then
 	echo "not running ltp-uid test"
 	exit 0
 fi
-../../ns_exec -ci ../create-shm -r -u $uid &
+$NSEXEC -ci ../create-shm -r -u $uid &
 do_checkpoint
 chown $uid ckpt.shm
 setcap cap_sys_admin+pe $RESTART
diff --git a/ns_exec.c b/ns_exec.c
deleted file mode 100644
index f1951c4..0000000
--- a/ns_exec.c
+++ /dev/null
@@ -1,318 +0,0 @@
-/*
- * Copyright 2008 IBM Corp.
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <sched.h>
-#include <sys/syscall.h>
-#include <unistd.h>
-#include <signal.h>
-#include <string.h>
-#include <errno.h>
-#include <libgen.h>
-#include <fcntl.h>
-#include <sys/stat.h>
-#include <sys/types.h>
-#include <sys/wait.h>
-
-#include "clone.h"
-
-extern pid_t getpgid(pid_t pid);
-extern pid_t getsid(pid_t pid);
-
-static const char* procname;
-
-static void usage(const char *name)
-{
-	printf("usage: %s [-h] [-c] [-mnuUip] [-P <pid-file>]"
-			"[command [arg ..]]\n", name);
-	printf("\n");
-	printf("  -h		this message\n");
-	printf("\n");
-	printf("  -c		use 'clone' rather than 'unshare' system call\n");
-	printf("  -g		launch in new cgroup\n");
-	printf("  -m		mount namespace\n");
-	printf("  -n		network namespace\n");
-	printf("  -u		utsname namespace\n");
-	printf("  -U		userid namespace\n");
-	printf("  -i		ipc namespace\n");
-	printf("  -P <pid-file>	File in which to write global pid of cinit\n");
-	printf("  -p		pid namespace\n");
-	printf("  -f <flag>	extra clone flags\n");
-	printf("\n");
-	printf("(C) Copyright IBM Corp. 2006\n");
-	printf("\n");
-	exit(1);
-}
-
-#if 0
-static void print_my_info(const char *procname, char *ttyname)
-{
-	printf("procname %s, ttyname %s, pid %d, ppid %d, pgid %d, sid %d\n",
-			procname, ttyname, getpid(), getppid(), getpgid(0),
-			getsid(0));
-}
-#endif
-
-static int string_to_ul(const char *str, unsigned long int *res)
-{
-	char *tail;
-	long long int r;
-
-	if (!*str)
-		return -1;
-
-	errno = 0;
-
-	r = strtol(str, &tail, 16);
-
-	/*
-	 * according to strtol(3), if errno is set or tail does no point
-	 * to the ending '\0', the conversion failed.
-	 */
-	if (errno || *tail)
-		return -1;
-
-	*res = r;
-	return 0;
-}
-
-/*
- * Copied following opentty() from Fedora's util-linux rpm
- * I just changed the "FATAL" message below from syslog()
- * to printf
- */
-static void
-opentty(const char * tty) {
-        int i, fd, flags;
-
-        fd = open(tty, O_RDWR | O_NONBLOCK);
-        if (fd == -1) {
-		printf("FATAL: can't reopen tty: %s", strerror(errno));
-                sleep(1);
-                exit(1);
-        }
-
-        flags = fcntl(fd, F_GETFL);
-        flags &= ~O_NONBLOCK;
-        fcntl(fd, F_SETFL, flags);
-
-        for (i = 0; i < fd; i++)
-                close(i);
-        for (i = 0; i < 3; i++)
-                if (fd != i)
-                        dup2(fd, i);
-        if (fd >= 3)
-                close(fd);
-}
-// Code copy end
-
-int do_newcgrp = 0;
-
-int load_cgroup_dir(char *dest, int len)
-{
-	FILE *f = fopen("/proc/mounts", "r");
-	char buf[200];
-	char *name, *path, *fsname, *options, *p1, *p2, *s;
-	if (!f)
-		return 0;
-	while (fgets(buf, 200, f)) {
-		name = strtok_r(buf, " ", &p1);
-		path = strtok_r(NULL, " ", &p1);
-		fsname = strtok_r(NULL, " ", &p1);
-		options = strtok_r(NULL, " ", &p1);
-		if (strcmp(fsname, "cgroup") != 0)
-			continue;
-
-		/* make sure the freezer is composed */
-		s = strtok_r(options, ",", &p2);
-		while (s && strcmp(s, "freezer") != 0)
-			s = strtok_r(NULL, ",", &p2);
-		if (!s)
-			continue;
-		strncpy(dest, path, len);
-		fclose(f);
-		return 1;
-	}
-	fclose(f);
-	printf("Freezer not mounted\n");
-	return 0;
-}
-
-int move_to_new_cgroup(int newcgroup)
-{
-	char cgroupname[150], cgroupbase[100], tasksfname[200];
-	FILE *fout;
-	int ret;
-
-	if (!load_cgroup_dir(cgroupbase, 100))
-		return 0;
-
-	snprintf(cgroupname, 150, "%s/%d", cgroupbase, newcgroup);
-	ret = mkdir(cgroupname, 0755);
-	if (ret && errno != EEXIST)
-		return 0;
-	snprintf(tasksfname, 200, "%s/tasks", cgroupname);
-	fout = fopen(tasksfname, "w");
-	if (!fout)
-		return 0;
-	fprintf(fout, "%d\n", getpid());
-	fclose(fout);
-	return 1;
-}
-
-int pipefd[2];
-
-/* gah. opentty will close the pipefd */
-int check_newcgrp(void)
-{
-	int ret, newgroup;
-	char buf[20];
-
-	if (!do_newcgrp)
-		return 0;
-
-	close(pipefd[1]);
-	ret = read(pipefd[0], buf, 20);
-	close(pipefd[0]);
-	if (ret == -1) {
-		perror("read");
-		return 1;
-	}
-	newgroup = atoi(buf);
-	if (!move_to_new_cgroup(newgroup))
-		return 1;
-	do_newcgrp = 0;
-	return 0;
-}
-
-int do_child(void *vargv)
-{
-	char **argv = (char **)vargv;
-
-	if (check_newcgrp())
-		return 1;
-
-	execve(argv[0], argv, __environ);
-	perror("execve");
-	return 1;
-}
-
-void write_pid(char *pid_file, int pid)
-{
-	FILE *fp;
-
-	if (!pid_file)
-		return;
-
-	fp = fopen(pid_file, "w");
-	if (!fp) {
-		perror("fopen, pid_file");
-		exit(1);
-	}
-	fprintf(fp, "%d", pid);
-	fflush(fp);
-	fclose(fp);
-}
-
-int main(int argc, char *argv[])
-{	
-	int c;
-	unsigned long flags = 0, eflags = 0;
-	char ttyname[256];
-	int status;
-	int ret, use_clone = 0;
-	int pid;
-	char *pid_file = NULL;
-
-	procname = basename(argv[0]);
-
-	memset(ttyname, '\0', sizeof(ttyname));
-	readlink("/proc/self/fd/0", ttyname, sizeof(ttyname));
-
-	while ((c = getopt(argc, argv, "+mguUiphcnf:P:")) != EOF) {
-		switch (c) {
-		case 'g': do_newcgrp = getpid();		break;
-		case 'm': flags |= CLONE_NEWNS;			break;
-		case 'c': use_clone = 1;			break;
-		case 'P': pid_file = optarg; 			break;
-		case 'u': flags |= CLONE_NEWUTS;		break;
-		case 'i': flags |= CLONE_NEWIPC;		break;
-		case 'U': flags |= CLONE_NEWUSER;		break;
-		case 'n': flags |= CLONE_NEWNET;		break;
-		case 'p': flags |= CLONE_NEWNS|CLONE_NEWPID;	break;
-		case 'f': if (!string_to_ul(optarg, &eflags)) {
-				flags |= eflags;
-				break;
-			}
-		case 'h':
-		default:
-			usage(procname);
-		}
-	};
-
-	argv = &argv[optind];
-	argc = argc - optind;	
-	
-	if (do_newcgrp) {
-		ret = pipe(pipefd);
-		if (ret) {
-			perror("pipe");
-			return -1;
-		}
-		do_newcgrp = pipefd[0];
-	}
-
-	if (use_clone) {
-		int stacksize = 4*getpagesize();
-		void *childstack, *stack = malloc(stacksize);
-
-		if (!stack) {
-			perror("malloc");
-			return -1;
-		}
-		childstack = stack + stacksize - 1;
-
-		printf("about to clone with %lx\n", flags);
-		flags |= SIGCHLD;
-		pid = clone(do_child, childstack, flags, (void *)argv);
-		if (pid == -1) {
-			perror("clone");
-			return -1;
-		}
-	} else {
-		if ((pid = fork()) == 0) {
-			// Child.
-			//print_my_info(procname, ttyname);
-
-			if (check_newcgrp())
-				return 1;
-			opentty(ttyname);
-
-			printf("about to unshare with %lx\n", flags);
-			ret = unshare(flags);
-			if (ret < 0) {
-				perror("unshare");
-				return 1;
-			}		
-			
-			return do_child((void*)argv);
-		}
-
-	}
-	if (pid != -1 && do_newcgrp) {
-		char buf[20];
-		snprintf(buf, 20, "%d", pid);
-		close(pipefd[0]);
-		write(pipefd[1], buf, strlen(buf)+1);
-		close(pipefd[1]);
-	}
-
-	write_pid(pid_file, pid);
-
-	if ((ret = waitpid(pid, &status, __WALL)) < 0)
-		printf("waitpid() returns %d, errno %d\n", ret, errno);
-
-	exit(0);
-}
diff --git a/process-tree/run-pthread1.sh b/process-tree/run-pthread1.sh
index e616753..64747e1 100755
--- a/process-tree/run-pthread1.sh
+++ b/process-tree/run-pthread1.sh
@@ -28,8 +28,7 @@ CHECKPOINT_DONE="checkpoint-done"
 
 LOGS_DIR="logs.d"
 
-NS_EXEC="../../ns_exec"
-NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+NSEXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 checkpoint()
 {
@@ -49,7 +48,7 @@ function create_container()
 {
 	local pid;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $TEST_CMD $TEST_ARGS"
+	cmdline="$NSEXEC $NSEXEC_ARGS -- $TEST_CMD $TEST_ARGS"
 
 	$ECHO "\t- Creating container:"
 	$ECHO "\t- $cmdline"
@@ -193,7 +192,7 @@ while [ $cnt -lt 15 ]; do
 	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
-	# ns_exec pid is parent-pid of restarted-container-init
+	# nsexec pid is parent-pid of restarted-container-init
 	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
diff --git a/process-tree/run-pthread2.sh b/process-tree/run-pthread2.sh
index ff7f0ac..8fe6607 100755
--- a/process-tree/run-pthread2.sh
+++ b/process-tree/run-pthread2.sh
@@ -29,8 +29,7 @@ CHECKPOINT_DONE="checkpoint-done"
 
 LOGS_DIR="logs.d"
 
-NS_EXEC="../../ns_exec"
-NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+NSEXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 checkpoint()
 {
@@ -59,7 +58,7 @@ function create_container()
 {
 	local pid;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $TEST_CMD $TEST_ARGS"
+	cmdline="$NSEXEC $NSEXEC_ARGS -- $TEST_CMD $TEST_ARGS"
 
 	$ECHO "\t- Creating container:"
 	$ECHO "\t- $cmdline"
@@ -184,7 +183,7 @@ while [ $cnt -lt 15 ]; do
 	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
-	# ns_exec pid is parent-pid of restarted-container-init
+	# nsexec pid is parent-pid of restarted-container-init
 	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
diff --git a/process-tree/run-pthread3.sh b/process-tree/run-pthread3.sh
index 0cffe44..af88aed 100755
--- a/process-tree/run-pthread3.sh
+++ b/process-tree/run-pthread3.sh
@@ -29,8 +29,7 @@ CHECKPOINT_DONE="checkpoint-done"
 
 LOGS_DIR="logs.d"
 
-NS_EXEC="../../ns_exec"
-NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+NSEXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 checkpoint()
 {
@@ -59,7 +58,7 @@ function create_container()
 {
 	local pid;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $TEST_CMD $TEST_ARGS"
+	cmdline="$NSEXEC $NSEXEC_ARGS -- $TEST_CMD $TEST_ARGS"
 
 	$ECHO "\t- Creating container:"
 	$ECHO "\t- $cmdline"
@@ -184,7 +183,7 @@ while [ $cnt -lt 15 ]; do
 	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
-	# ns_exec pid is parent-pid of restarted-container-init
+	# nsexec pid is parent-pid of restarted-container-init
 	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
diff --git a/process-tree/run-ptree1.sh b/process-tree/run-ptree1.sh
index 2b1e8c5..65b9fba 100755
--- a/process-tree/run-ptree1.sh
+++ b/process-tree/run-ptree1.sh
@@ -29,8 +29,7 @@ CHECKPOINT_READY="checkpoint-ready"
 CHECKPOINT_DONE="checkpoint-done"
 INPUT_DATA="input.data";
 
-NS_EXEC="$BASE_DIR/ns_exec"
-NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+NSEXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 
 checkpoint()
@@ -52,7 +51,7 @@ function create_container()
 {
 	local pid;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $TEST_CMD $TEST_ARGS"
+	cmdline="$NSEXEC $NSEXEC_ARGS -- $TEST_CMD $TEST_ARGS"
 
 	$ECHO "\t- Creating container:"
 	$ECHO "\t- $cmdline"
@@ -208,7 +207,7 @@ while [ $cnt -lt 15 ]; do
 	ps aux |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
-	# ns_exec pid is parent-pid of restarted-container-init
+	# nsexec pid is parent-pid of restarted-container-init
 	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
diff --git a/simple/runtests.sh b/simple/runtests.sh
index d10c388..34ef9a8 100755
--- a/simple/runtests.sh
+++ b/simple/runtests.sh
@@ -3,12 +3,13 @@
 # Author: Serge Hallyn
 
 RESTART=`which restart`
+NSEXEC=`which nsexec`
 
 dir=`mktemp -p . -d -t cr_simple_XXXXXXX` || (echo "mktemp failed"; exit 1)
 
 echo "Using output dir $dir"
 
-../ns_exec -cp ./ckpt  $dir
+$NSEXEC -cp ./ckpt  $dir
 if [ ! -f $dir/cr-test.out ]; then
 	echo "FAIL - ckpt did not create $dir/cr-test.out"
 	exit 1
-- 
1.6.1.1
