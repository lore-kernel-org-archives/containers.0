From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH cr-tests] test chroot and chdir restoration
Date: Tue, 29 Dec 2009 14:46:11 -0600
Message-ID: <20091229204611.GA17192@us.ibm.com>
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

One testcase ensures that cwd is restore and chroot is not
wrongly set.  The second ensure that a container with a
child task which is chrooted, when restored, is restored
with the child task chrooted.

The third testcase tries to restore a container which was
itself chrooted.  This fails, as it is up to userspace to
make sure that the container is restarted in the right
place.  One way to do this is with the
	restart -r chroot_dir < ckpt
option.

(The third testcase does not by default run)

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile             |    2 +-
 runall.sh            |    6 ++
 taskfs/Makefile      |   16 +++++
 taskfs/README        |    1 +
 taskfs/chrootsleep.c |   55 ++++++++++++++++
 taskfs/cwdsleep.c    |   43 +++++++++++++
 taskfs/runtest.sh    |  170 ++++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 292 insertions(+), 1 deletions(-)
 create mode 100644 taskfs/Makefile
 create mode 100644 taskfs/README
 create mode 100644 taskfs/chrootsleep.c
 create mode 100644 taskfs/cwdsleep.c
 create mode 100755 taskfs/runtest.sh

diff --git a/Makefile b/Makefile
index 3463f31..95f8b6e 100644
--- a/Makefile
+++ b/Makefile
@@ -1,5 +1,5 @@
 SUBDIRS = libcrtest counterloop fileio simple userns ipc sleep \
-	  process-tree futex epoll
+	  process-tree futex epoll taskfs
 
 targets = ns_exec mysu
 
diff --git a/runall.sh b/runall.sh
index d15dc25..1eddd74 100644
--- a/runall.sh
+++ b/runall.sh
@@ -97,5 +97,11 @@ bash runtests.sh
 update_totals $?
 popd
 
+echo Running cwd/chroot tests
+pushd taskfs
+bash runtest.sh
+update_totals $?
+popd
+
 echo $passed out of $total test groups passed.
 exit 0
diff --git a/taskfs/Makefile b/taskfs/Makefile
new file mode 100644
index 0000000..ab13816
--- /dev/null
+++ b/taskfs/Makefile
@@ -0,0 +1,16 @@
+targets = cwdsleep chrootsleep
+
+all: $(targets)
+
+SLIBS = ../libcrtest/libcrtest.a
+LIBCMD = -I../libcrtest -L../libcrtest $(SLIBS)
+
+cwdsleep: cwdsleep.c $(SLIBS)
+	gcc -static -o cwdsleep cwdsleep.c $(LIBCMD)
+
+chrootsleep: chrootsleep.c $(SLIBS)
+	gcc -static -o chrootsleep chrootsleep.c $(LIBCMD)
+
+clean:
+	rm -f $(targets)
+	rm -rf cr_taskfs*
diff --git a/taskfs/README b/taskfs/README
new file mode 100644
index 0000000..546b462
--- /dev/null
+++ b/taskfs/README
@@ -0,0 +1 @@
+test cwd and chroot
diff --git a/taskfs/chrootsleep.c b/taskfs/chrootsleep.c
new file mode 100644
index 0000000..686717c
--- /dev/null
+++ b/taskfs/chrootsleep.c
@@ -0,0 +1,55 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Serge Hallyn
+ */
+
+#include <unistd.h>
+#include <stdio.h>
+#include <libcrtest.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <sched.h>
+
+int child(void *data)
+{
+	int ret;
+
+	ret = chroot(".");
+	if (ret < 0)
+		return 1;
+	ret = creat("./ready", 0755);
+	if (ret < 0)
+		return 1;
+	close(ret);
+	sleep(300);
+}
+
+int main(int argc, char *argv[])
+{
+	int ret, pid;
+	int status;
+	int stack;
+	char *freezer = "1";
+
+	if (argc > 1)
+		freezer = argv[1];
+
+	if (!move_to_cgroup("freezer", freezer, getpid())) {
+		printf("Failed to move myself to cgroup %s\n", freezer);
+		return 1;
+	}
+
+	close(0);
+	close(1);
+	close(2);
+	close(3);
+
+	pid = fork();
+	if (pid < 0)
+		return pid;
+	if (pid == 0)
+		child(NULL);
+	ret = waitpid(pid, &status, 0);
+	return ret;
+}
diff --git a/taskfs/cwdsleep.c b/taskfs/cwdsleep.c
new file mode 100644
index 0000000..ecb2254
--- /dev/null
+++ b/taskfs/cwdsleep.c
@@ -0,0 +1,43 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Serge Hallyn
+ */
+
+#include <unistd.h>
+#include <stdio.h>
+#include <libcrtest.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+/*
+ * arg 1: full path of cgroup to enter
+ * arg 2: 'cwd' or 'chroot'
+ * arg 3: path to cd or chroot into
+ */
+
+int main(int argc, char *argv[])
+{
+	int ret;
+	char *freezer = NULL;
+
+	if (argc > 1) {
+		freezer = argv[1];
+		if (!move_to_cgroup("freezer", freezer, getpid())) {
+			printf("Failed to move myself to cgroup %s\n", freezer);
+			return 1;
+		}
+	}
+
+	close(0);
+	close(1);
+	close(2);
+	close(3);
+
+	ret = creat("./ready", 0755);
+	if (ret < 0)
+		return 1;
+	close(ret);
+	sleep(300);
+	return 0;
+}
diff --git a/taskfs/runtest.sh b/taskfs/runtest.sh
new file mode 100755
index 0000000..c964306
--- /dev/null
+++ b/taskfs/runtest.sh
@@ -0,0 +1,170 @@
+#!/bin/bash
+# Copyright 2009 IBM Corp.
+# Author: Serge Hallyn
+
+verify_cwd() {
+	dir=$1
+
+	n=`pidof cwdsleep | wc -w`
+	if [ $n -ne 1 ]; then
+		echo "Fail: $n tasks restarted, not 1"
+		exit 1
+	fi
+	pid=`pidof cwdsleep`
+	cwd=`readlink /proc/$pid/cwd`
+	root=`readlink /proc/$pid/root`
+	if [ $cwd != $dir ]; then
+		echo "Fail: cwd is $cwd should be $dir"
+		exit 1
+	fi
+	if [ $root != '/' ]; then
+		echo "Fail: root is $root should be /"
+		exit 1
+	fi
+	return 0;
+}
+
+# The root testcase has two processes.  The first should have
+# root / and cwd $dir.  The second should have root and cwd both
+# as $dir
+verify_root() {
+	dir=$1
+
+	n=`pidof chrootsleep | wc -w`
+	if [ $n -ne 2 ]; then
+		echo "Fail: $n tasks restarted, not 2"
+		exit 1
+	fi
+	c=0
+	for pid in `pgrep chrootsleep | sort`; do
+		cwd=`readlink /proc/$pid/cwd`
+		root=`readlink /proc/$pid/root`
+		if [ $cwd != $dir ]; then
+			echo "cwd is $cwd should be $dir"
+			exit 1;
+		fi
+		if [ $c -eq 0 ]; then
+			if [ $root != '/' ]; then
+				echo "root is $root should be /"
+				exit 1;
+			fi
+		else
+			if [ $root != $dir ]; then
+				echo "root is $root should be $dir"
+				exit 1;
+			fi
+		fi
+		c=$((c+1))
+	done
+	return 0;
+}
+
+verify_container_chroot() {
+	dir=$1
+
+	n=`pidof cwdsleep | wc -w`
+	if [ $n -ne 1 ]; then
+		echo "Fail: $n tasks restarted, not 1"
+		# exit 1
+		return 0
+	fi
+	pid=`pidof cwdsleep`
+	cwd=`readlink /proc/$pid/cwd`
+	root=`readlink /proc/$pid/root`
+	if [ $cwd != $dir ]; then
+		echo "Fail: cwd is $cwd should be $dir"
+		# exit 1
+		return 0
+	fi
+	if [ $root != $dir ]; then
+		echo "Fail: root is $root should be $dir"
+		# exit 1
+		return 0
+	fi
+	return 0;
+}
+
+runtest() {
+	cmd=$1
+	dir=$2
+	freezerdir=$3
+	freezer=`basename $freezerdir`
+
+	killall -9 cwdsleep chrootsleep
+
+	rm -f $dir/log.$cmd
+
+	rm -f $dir/ready
+	if [ $cmd == "cwd" ]; then
+		(cd $dir; ./cwdsleep $freezer) &
+		name=cwdsleep
+	elif [ $cmd == "containerroot" ]; then
+		(chroot $dir /cwdsleep ) &
+		name=cwdsleep
+	else
+		(cd $dir; ./chrootsleep $freezer) &
+		name=chrootsleep
+	fi
+
+	settimer 5
+	while [ ! -f $dir/ready ]; do : ; done
+	canceltimer
+
+	job=`pgrep $name | sort | head -1`
+	if [ $cmd == "containerroot" ]; then
+		# rather than bind-mount /cgroup into chroot,
+		# just special-case the cgroup entering
+		echo $job >> $freezerdir/tasks
+		cat $freezerdir/tasks > /dev/null
+	fi
+
+	freeze
+	echo "Checkpointing job $job"
+	echo $CHECKPOINT -l $dir/log.$cmd $job > $dir/ckpt.$cmd
+	$CHECKPOINT -l $dir/log.$cmd $job > $dir/ckpt.$cmd
+
+	killall -9 cwdsleep chrootsleep
+	thaw
+
+	echo "Restarting job"
+	$RESTART -W --pids < $dir/ckpt.$cmd &
+	settimer 5
+	job=`pidof $name`
+	ret=$?
+	if [ $cmd == containerroot ]; then ret=0; fi
+	while [ $ret -ne 0 ]; do
+		job=`pidof $name`
+		ret=$?
+	done
+	canceltimer
+	if [ $cmd == "cwd" ]; then
+		verify_cwd $dir
+	elif [ $cmd == "container_chroot" ]; then
+		verify_container_chroot $dir
+	else # root
+		verify_root $dir
+	fi
+	killall -9 cwdsleep chrootsleep
+
+	echo "Test $cmd PASS"
+	return 1
+}
+
+source ../common.sh
+cwd=`pwd`
+dir=`mktemp -p $cwd -d -t cr_taskfs_XXXXXXX` || (echo "mktemp failed"; exit 1)
+echo "Using output dir $dir"
+chmod go+rx $dir
+cp cwdsleep chrootsleep $dir/
+
+echo "Test 1: testing cwd"
+runtest cwd $dir $freezerdir
+
+echo "Test 2: chroot"
+runtest root $dir $freezerdir
+
+#echo "Test 3: (expected to fail)"
+#runtest containerroot $dir $freezerdir
+
+echo PASS
+exit 0
-- 
1.6.4.4
