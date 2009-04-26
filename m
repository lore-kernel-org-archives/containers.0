From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [C/R] sleepers don't wake up on restart
Date: Sat, 25 Apr 2009 17:56:41 -0700
Message-ID: <20090426005641.GA4376@us.ibm.com>
References: <20090402002005.GA22375@us.ibm.com>
	<49D539B5.7060305@cs.columbia.edu>
	<20090402224342.GA7613@us.ibm.com>
	<49DB4B6C.3050500@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49DB4B6C.3050500-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| I just posted v14-rc3 which includes the c/r of restart-blocks.
| That should improve the situation.
| 
| However, depending on which syscalls one uses, process may still
| seem "stuck" after restart because the current code still does
| not save signals nor task timers; If a signal was pending (SIGALRM
| for example) after freezing but before checkpoint, it will be lost.
| If a timer was set at checkpoint, it will not be restored.
| 
| So depending on your program, you may still experience issues
| until I add patches to handle that.

Ok, Just an fyi, the original program seemed to work fine, but when
I try to restart a small process tree, I get stuck on restart again.

I am running on v14-rc3 branch. Has this got anything to do with
pending SIGCHLD ? Seems to be easier to repro with larger process
trees (2 children per process, 4 or more levels deep).

Test programs (attached) (they need some cleanup though)

	ptree2.c
	p2.loop

--------- Processes after restart:

$ ps -ef|grep ptree

root     10461 10459  0 22:07 pts/0    00:00:00 ./ptree2 -n 1 -d 2
root     10465 10461  0 22:07 pts/0    00:00:00 ./ptree2 -n 1 -d 2
root     10466 10465  0 22:07 pts/0    00:00:00 [ptree2] <defunct>
root     10479  8220  0 22:09 pts/1    00:00:00 grep ptree

---------- Process stacks

tree2        S f6270a90     0 10461  10459
 f5e59380 00000082 08048a86 f6270a90 f6270bfc c2b32260 00000000 0000d9d3
 f5f423b0 00000000 ffffffff 00000000 00000000 00000001 00000000 f6270a88
 00000000 f6270a90 00000000 c02243aa 00000004 00000003 0000000c 00000006
Call Trace:
 [<c02243aa>] do_wait+0x1dd/0x2f6
 [<c021cd14>] default_wake_function+0x0/0x8
 [<c0224542>] sys_wait4+0x7f/0x92
 [<c0224568>] sys_waitpid+0x13/0x17
 [<c0202ce5>] sysenter_do_call+0x12/0x25
 [<c0510000>] rtl8139_init_one+0x5ae/0x887
ptree2        S f5f423b0     0 10465  10461
 f6002180 00000082 c2b265c8 f5f423b0 f5f4251c c2b29260 f67b1f44 e06d0177
 00000282 c023363c c2b265c8 00000000 00000282 0000c350 00000001 0000c350
 00000001 f67b1f44 0000c350 c051be99 00000000 00000001 0000c350 bf9d0e04
Call Trace:
 [<c023363c>] hrtimer_start_range_ns+0x105/0x111
 [<c051be99>] do_nanosleep+0x54/0x8c
 [<c02336d7>] hrtimer_nanosleep+0x8f/0xee
 [<c02332b8>] hrtimer_wakeup+0x0/0x18
 [<c051be7f>] do_nanosleep+0x3a/0x8c
 [<c0233777>] sys_nanosleep+0x41/0x51
 [<c0202ce5>] sysenter_do_call+0x12/0x25
ptree2        ? f6bee040     0 10466  10465
 f638cb80 00000046 00200200 f6bee040 f6bee1ac c2b17260 f6bee038 0000dd77
 00000000 c022f576 ffffffff 00000303 00000000 00000001 00000000 00000012
 f5a61e84 f6bee040 f6bee038 c0224c29 f6270a90 00000001 f6bee038 f5a61f88
Call Trace:
 [<c022f576>] wakeme_after_rcu+0x0/0x8
 [<c0224c29>] do_exit+0x638/0x63c
 [<c0224c87>] do_group_exit+0x5a/0x83
 [<c0224cbd>] sys_exit_group+0xd/0x10
 [<c0202ce5>] sysenter_do_call+0x12/0x25

--2fHTh5uZTiUOsy+g
Content-Type: text/x-csrc; charset=us-ascii
Content-Description: ptree2.c
Content-Disposition: attachment; filename="ptree2.c"

#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <errno.h>
#include <string.h>

int max_depth = 3;
int num_children = 3;

#define CKPT_READY		"checkpoint-ready"
#define CKPT_DONE		"checkpoint-done"
#define TEST_DONE		"test-done"
#define LOG_FILE		"log-ptree2"

#undef SYS_GETGPID

#ifdef SYS_GETGPID
static inline int sys_getgpid()
{
#define	__NR_getgpid	335
        return syscall(__NR_getgpid);
}
#else
#define	sys_getgpid	getpid
#endif

FILE *logfp;

void do_exit(int status)
{
	if (logfp) {
		fflush(logfp);
		fclose(logfp);
	}
	_Exit(status);
}

int test_done()
{
	int rc;

	rc = access(TEST_DONE, F_OK);
	if (rc == 0)
		return 1;
	else if (errno == ENOENT)
		return 0;

	fprintf(logfp, "access(%s) failed, %s\n", TEST_DONE, strerror(errno));
	do_exit(1);
}

int checkpoint_done()
{
	int rc;

	rc = access(CKPT_DONE, F_OK);
	if (rc == 0)
		return 1;
	else if (errno == ENOENT)
		return 0;

	fprintf(logfp, "access(%s) failed, %s\n", CKPT_DONE, strerror(errno));
	do_exit(1);
}

void checkpoint_ready()
{
	int fd;

	fd = creat(CKPT_READY, 0666, 0);
	if (fd < 0) {
		fprintf(logfp, "creat(%s) failed, %s\n", CKPT_READY,
				strerror(errno));
		do_exit(1);
	}
	close(fd);
}

print_exit_status(int pid, int status)
{
	fprintf(logfp, "Pid %d unexpected exit - ", pid);
	if (WIFEXITED(status)) {
		fprintf(logfp, "exit status %d\n", WEXITSTATUS(status));
	} else if (WIFSIGNALED(status)) {
		fprintf(logfp, "got signal %d\n", WTERMSIG(status));
	} else {
		fprintf(logfp, "stopped/continued ?\n");
	}
}

void do_wait()
{
	int rc;
	int n;
	int status;

	n = 0;
	while(1) {
		rc = waitpid(-1, &status, 0);
		if (rc < 0)
			break;

		n++;
		if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
			print_exit_status(rc, status);	
	}

	if (errno != ECHILD) {
		fprintf(logfp, "waitpid(%d) failed, error %s\n",
					rc, strerror(errno));
		do_exit(1);
	}

	if (getpid() == 1 && n != num_children * max_depth) {
		fprintf(logfp, "Only %d of %d children exited ?\n",
			num_children, num_children * max_depth);
		do_exit(1);
	}

	do_exit(0);
}

static do_child(int depth, char *suffix);

create_children(int depth, char *parent_suffix)
{
	int i;
	int child_pid;
	char suffix[1024];

	for (i = 0; i < num_children; i++) {
		sprintf(suffix, "%s-%d", parent_suffix, i);

		child_pid = fork();
		if (child_pid == 0)
			do_child(depth, suffix);
		else if (child_pid < 0) {
			fprintf(logfp, "fork() failed, depth %d, "
				"child %d, error %s\n", depth, i,
				strerror(errno));
			do_exit(1);
		}
	}
}

do_child(int depth, char *suffix)
{
	int i;
	FILE *cfp;
	char cfile[256];
	char *mode = "w";

	/*
	 * Recursively calls do_child() and both parent and child
	 * execute the code below
	 */
	if (depth < max_depth)
		create_children(depth+1, suffix);

	sprintf(cfile, "%s%s", LOG_FILE, suffix);

	i = 0;
	while (!test_done()) {
		/* truncate the first time, append after that */
		cfp = fopen(cfile, mode);
		mode = "a";
		if (!cfp) {
			fprintf(logfp, "fopen(%s) failed, error %s\n", cfile,
					strerror(errno));
			do_exit(1);
		}
		fprintf(cfp, "gpid %d, pid %d: i %d\n", sys_getgpid(),
				getpid(), i++);
		fflush(cfp);
		sleep(1);
		fprintf(cfp, "gpid %d: woke up from sleep(1)\n", sys_getgpid());
		fflush(cfp);
		fclose(cfp);
	}

	/* Wait for any children that pre-deceased us */
	do_wait();

	do_exit(0);
}

static void usage(char *argv[])
{
	printf("%s [h] [-d max-depth] [-n max-children]\n", argv[0]);
	printf("\t <max-depth> max depth of process tree, default 3\n");
	printf("\t <num-children> # of children per process, default 3\n");
	do_exit(1);
}

main(int argc, char *argv[])
{
	int c;
	int i;
	int status;

	if (test_done()) {
		printf("Remove %s before running test\n", TEST_DONE);
		do_exit(1);
	}

	while ((c = getopt(argc, argv, "hd:n:")) != EOF) {
		switch (c) {
		case 'd': max_depth = atoi(optarg); break;
		case 'n': num_children = atoi(optarg); break;
		case 'h':
		default:
			usage(argv);
		}
	};

	logfp = fopen(LOG_FILE, "w");
	if (!logfp) {
		fprintf(stderr, "fopen(%s) failed, %s\n", LOG_FILE,
					strerror(errno));
		fflush(stderr);
		do_exit(1);
	}
	close(0);close(1);close(2);

	create_children(1, "");

	/*
 	 * Now that we closed the special files and created process tree
	 * tell any wrapper scripts, we are ready for checkpoint
	 */
	checkpoint_ready();

#if 0
	while(!checkpoint_done())
		sleep(1);
#endif

	do_wait();
}

--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p2.loop"

#!/bin/bash

freezermountpoint=/cgroups
CHECKPOINT=".."
NS_EXEC="$CHECKPOINT/bin/ns_exec"
CR="$CHECKPOINT/bin/cr"
RSTR="$CHECKPOINT/bin/rstr"
MKTREE="$CHECKPOINT/bin/mktree"
ECHO="/bin/echo -e"

TEST_CMD="./ptree2"
TEST_ARGS="-n 1 -d 2"	# -n: children per process, -d: depth of process tree
SCRIPT_LOG="log-p2-loop"
TEST_PID_FILE="pid.ptree2";

LOG_FILE="loop-ptree2.log"
SNAPSHOT_DIR="snap1"

TEST_DONE="test-done"
CHECKPOINT_FILE="checkpoint-ptree2";
CHECKPOINT_READY="checkpoint-ready"
CHECKPOINT_DONE="checkpoint-done"
TEST_LOG_PREFIX="log-ptree2"
TEST_LOG_SNAP="${TEST_LOG_PREFIX}.snap"

freeze()
{
	$ECHO "\t - Freezing $1"
	$ECHO FROZEN > ${freezermountpoint}/$1/freezer.state
	ret=$?
	if [ $ret -ne 0 ]; then
		$ECHO "***** FAIL: \'echo FROZEN \> $state\' returned $ret"
	fi
}

unfreeze()
{
	$ECHO "\t - Unfreezing $1"
	$ECHO THAWED > ${freezermountpoint}/$1/freezer.state
	ret=$?
	if [ $ret -ne 0 ]; then
		$ECHO "***** FAIL: \'echo THAWED \> $state\' returned $ret"
	fi
}

cleancgroup()
{
	$ECHO "\t - Clean cgroup of $1"
	rmdir ${freezermountpoint}/$1
	if [ -d ${freezermountpoint}/$1 ]; then
		$ECHO ***** WARNING ${freezermountpoint}/$1 remains
	fi
}

checkpoint()
{
	local pid=$1

	$ECHO "Checkpoint: $CR $pid $CHECKPOINT_FILE"
	$CR $pid $CHECKPOINT_FILE
	ret=$?
	if [ $ret -ne 0 ]; then
		$ECHO "***** FAIL: Checkpoint of $pid failed"
		ps aux |grep $TEST_CMD >> $SCRIPT_LOG
		exit 1;
	fi
}


function create_container
{
	local pid;

	$ECHO "\t - $NS_EXEC -cpmP $TEST_PID_FILE -- $TEST_CMD $TEST_ARGS"
	$NS_EXEC -cpmP $TEST_PID_FILE -- $TEST_CMD $TEST_ARGS &

	# Wait for test to finish setup
	while [ ! -f $CHECKPOINT_READY ]; do
		/bin/$ECHO -e "\t - Waiting for $CHECKPOINT_READY"
		sleep 1;
	done;

	# Find global pid of container-init
	pid=`cat $TEST_PID_FILE`;
	if [  "x$pid" == "x" ]; then
		$ECHO "***** FAIL: Invalid container-init pid $pid"
		ps -ef |grep $TEST_CMD >> $SCRIPT_LOG
		exit 1
	fi
	$ECHO "Created container with pid $pid" >> $SCRIPT_LOG
	echo $pid
}

function restart_container
{
	local ret;

	$ECHO "\t - Exec $NS_EXEC -cpuim -- $MKTREE --no-pids < $CHECKPOINT_FILE"

	sleep 1

	$NS_EXEC -cpuim -- $MKTREE --no-pids < $CHECKPOINT_FILE >> $SCRIPT_LOG 2>&1 &
	ret=$?

	if [ $ret -ne 0 ]; then
		$ECHO "***** FAIL: Restart of $pid failed"
		ps aux |grep $TEST_CMD >> $SCRIPT_LOG
		exit 1;
	fi
}


# Check freezer mount point
line=`grep freezer /proc/mounts`
$ECHO $line | grep "\<ns\>"
if [ $? -ne 0 ]; then
	$ECHO "please mount freezer and ns cgroups"
	$ECHO "  mkdir /cgroups"
	$ECHO "  mount -t cgroup -o freezer,ns cgroup /cgroups"
	exit 1
fi
#freezermountpoint=`$ECHO $line | awk '{ print $2 '}`

# Make sure no stray e2 from another run is still going
killall $TEST_CMD > $SCRIPT_LOG 2>&1

cnt=1
while [ 1 ]; do
	> $SCRIPT_LOG;
	dmesg -c > /dev/null

	$ECHO "===== Iteration $cnt"

	# Remove any 'state' files, start the app and let it tell us
	# when it is ready
	rm -f $CHECKPOINT_READY $TEST_DONE $TEST_PID_FILE

	$NS_EXEC -cpumP $TEST_PID_FILE -- $TEST_CMD $TEST_ARGS&
	$ECHO "\t - $NS_EXEC -cpumP $TEST_PID_FILE -- $TEST_CMD $TEST_ARGS"

	# Wait for test to finish setup
	while [ ! -f $CHECKPOINT_READY ]; do
		$ECHO "\t - Waiting for $CHECKPOINT_READY"
		sleep 1;
	done;

	ps -ef |grep ptree2 >> $SCRIPT_LOG

	# Find global pid of container-init
	pid=`cat $TEST_PID_FILE`;
	if [  "x$pid" == "x" ]; then
		$ECHO "***** FAIL: Invalid container-init pid $pid"
		ps -ef |grep $TEST_CMD
		exit 1
	fi
	$ECHO $pid
	#pid=`create_container`
	$ECHO "\t - Done creating container"

	# Prepare for snapshot
	if [ -d $SNAPSHOT_DIR ]; then
		rm -rf ${SNAPSHOT_DIR}.prev
		mv $SNAPSHOT_DIR ${SNAPSHOT_DIR}.prev
		mkdir $SNAPSHOT_DIR
	fi

	freeze $pid

	num_pids1=`ps -ef |grep $TEST_CMD | wc -l`

	checkpoint $pid

	#$ECHO t > /proc/sysrq-trigger
	#dmesg > dmesg-1.out

	# Snapshot the log files
	cp ${TEST_LOG_PREFIX}* $SNAPSHOT_DIR
	touch $CHECKPOINT_DONE

	killall -9 `basename $TEST_CMD`

	unfreeze $pid

	sleep 3

	cleancgroup $pid

	# Restore the snapshot after the main process has been killed
	/bin/cp ${SNAPSHOT_DIR}/* .

	# Restart.
	restart_container

	sleep 3;
	num_pids2=`ps -ef |grep $TEST_CMD | wc -l`

	ps -ef |grep ptree2 >> $SCRIPT_LOG

	$ECHO "\t - num_pids1 $num_pids1, num_pids2 $num_pids2"; 

	# Find global-pid of container-init
	nspid=`pidof $NS_EXEC`
	if [ "x$nspid" == "x" ]; then
		$ECHO "***** FAIL: Can't find pid of $NS_EXEC"
		exit 1;
	fi
	
	# End test gracefully
	touch $TEST_DONE

	$ECHO "\t - Restart: Waiting for container-init (gloabl-pid $nspid) to exit"
	wait $nspid;
	ret=$?

	$ECHO "Container-init (global-pid $nspid) exited, status $ret"

	if [ -d /cgroups/$pid ]; then
		cleancgroup $pid
	fi

	cnt=$((cnt+1))
done

--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--2fHTh5uZTiUOsy+g--
