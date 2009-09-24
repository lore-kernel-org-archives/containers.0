From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][cr_tests PATCH] checkpoint/restart: define selinux tests
Date: Thu, 24 Sep 2009 01:19:37 -0500
Message-ID: <20090924061936.GA19095@us.ibm.com>
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
To: SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

[This is a test for the selinux context restoration behavior
of the application checkpoint/restart kernel feature.]

Define a policy module which defines three domains,
ckpt_test_{1,2,3}_t.  We run a self-checkpoint program
under ckpt_test_1_t to create a labeled checkpoint file.
ckpt_test_2_t is allowed to restore a task with
ckpt_test_1_t labels, while ckpt_test_3_t may not.  We
try:
	1. restarting ckpt from context ckpt_test_2_t,
	   without --keeplsm, meaning task label at restart
	   should be ckpt_test_2_t.
	2. restarting ckpt from context ckpt_test_3_t,
	   with --keeplsm, meaning task label at restart
	   should be ckpt_test_1_t.  But that isn't allowed,
	   so restart should fail.
	3. restarting ckpt from context ckpt_test_2_t,
	   with --keeplsm, meaning task label at restart
	   should be ckpt_test_2_t.

After doing self-checkpoint, ckpt copies the content of
/proc/self/attr/current to ./context.  We use the
contents of that file to verify that the task was restarted
with the proper task label.

Eventually tests should be written to test ipc labels.

This is a part of the c/r tests at
	git://git.sr71.net/~hallyn/cr_tests.git
The lsm c/r patches are so far not integrated in the main
checkpoint/restart patchset, but can be seen at

	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=ckpt-v18.lsm.1

This set has been tested on RHEL5.3 running with refpolicy.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile           |    9 ++
 README             |   23 +++++++
 ckpt.c             |   76 ++++++++++++++++++++++++
 cr-tests-policy.fc |    5 +
 cr-tests-policy.if |   42 +++++++++++++
 cr-tests-policy.te |   62 ++++++++++++++++++++
 runtest.sh         |  163 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 wrap.c             |   22 +++++++
 8 files changed, 402 insertions(+)

diff --git a/selinux/Makefile b/selinux/Makefile
new file mode 100644
index 0000000..2ae8d96
--- /dev/null
+++ b/selinux/Makefile
@@ -0,0 +1,9 @@
+targets = ckpt wrap
+
+all: $(targets)
+
+ckpt: ckpt.c ../cr.h
+	gcc -o ckpt ckpt.c
+
+clean:
+	rm -rf $(targets) out context cr-test.out cr-test-module restart wrap
diff --git a/selinux/README b/selinux/README
new file mode 100644
index 0000000..fc59c3c
--- /dev/null
+++ b/selinux/README
@@ -0,0 +1,23 @@
+Make sure
+	expand-check = 0
+is in /etc/selinux/semanage.conf.
+
+You also need to add 'restore' to the definitions of
+all_file_perms, all_process_perms, all_ipc_perms, and all_msg_perms
+in /usr/share/selinux/devel/include/support/all_perms.spt.  The
+refpolicy source likewise must be updated to know of these perms.
+
+Test sequence:
+
+	1. load policy
+	2. run ckpt as ckpt_test_1_t to create a checkpoint image
+		with tasks etc under that label
+	3. run restart as ckpt_test_2_t without KEEP_LSM, making
+		sure tasks are under ckpt_test_2_t label.
+	4. run restart as ckpt_test_2_t with KEEP_LSM, making
+		sure tasks are under ckpt_test_1_t label.
+	5. run restart as ckpt_test_3_t, which does not have
+		restore rights to ckpt_test_1_t, with KEEP_LSM,
+		making sure we get -EPERM.
+
+Later we may want to also test file and ipc labels.
diff --git a/selinux/ckpt.c b/selinux/ckpt.c
new file mode 100644
index 0000000..d34918d
--- /dev/null
+++ b/selinux/ckpt.c
@@ -0,0 +1,76 @@
+/*
+ * Copyright (C) 2008 Oren Laadan
+ */
+
+#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <asm/unistd.h>
+#include <sys/syscall.h>
+#include "../cr.h"
+
+#define OUTFILE "./cr-test.out"
+
+int main(int argc, char *argv[])
+{
+	pid_t pid = getpid();
+	FILE *file;
+	int ret;
+	int fd, n;
+	char ctx[200];
+
+	fd = open("out", O_RDWR|O_CREAT, 0644);
+	if (fd < 0) {
+		perror("open");
+		exit(1);
+	}
+
+	close(0);
+	close(2);
+
+	unlink(OUTFILE);
+	file = fopen(OUTFILE, "w+");
+	if (!file) {
+		perror("open");
+		exit(1);
+	}
+
+	close(1);
+	dup2(fd, 1);
+
+	if (dup2(0,2) < 0) {
+		perror("dups");
+		exit(1);
+	}
+
+	fprintf(file, "hello, world!\n");
+	fflush(file);
+
+	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, CHECKPOINT_SUBTREE);
+	if (ret < 0) {
+		perror("checkpoint");
+		exit(2);
+	}
+
+	fprintf(file, "world, hello!\n");
+	fprintf(file, "ret = %d\n", ret);
+	fflush(file);
+	file = fopen("/proc/self/attr/current", "r");
+	if (!file)
+		return 3;
+	n = fread(ctx, 1, 200, file);
+	fclose(file);
+	file = fopen("./context", "w");
+	if (!file)
+		return 4;
+	fwrite(ctx, 1, n, file);
+	fclose(file);
+
+	return 0;
+}
+
diff --git a/selinux/cr-tests-policy.fc b/selinux/cr-tests-policy.fc
new file mode 100644
index 0000000..b35d9a7
--- /dev/null
+++ b/selinux/cr-tests-policy.fc
@@ -0,0 +1,5 @@
+# cr_tests/selinux/ckpt executable will have:
+# label: system_u:object_r:ckpt_test_exec_t
+# MLS sensitivity: s0
+# MCS categories: <none>
+
diff --git a/selinux/cr-tests-policy.if b/selinux/cr-tests-policy.if
new file mode 100644
index 0000000..d13d033
--- /dev/null
+++ b/selinux/cr-tests-policy.if
@@ -0,0 +1,42 @@
+########################################
+## <summary>
+##	Execute a domain transition to run myapp.
+## </summary>
+## <param name="domain">
+##	Domain allowed to transition.
+## </param>
+#
+interface(`ckpt_test_domtrans',`
+	gen_require(`
+		type ckpt_test_1_t, ckpt_test_exec_t;
+		type ckpt_test_2_t, ckpt_test_3_t;
+		type ckpt_test_file_t;
+	')
+
+	role $2 types ckpt_test_1_t;
+	role $2 types ckpt_test_2_t;
+	role $2 types ckpt_test_3_t;
+
+	spec_domtrans_pattern($1,ckpt_test_exec_t,ckpt_test_1_t);
+	spec_domtrans_pattern($1,ckpt_test_exec_t,ckpt_test_2_t);
+	spec_domtrans_pattern($1,ckpt_test_exec_t,ckpt_test_3_t);
+
+	allow $1 ckpt_test_1_t:fd use;
+	allow $1 ckpt_test_2_t:fd use;
+	allow $1 ckpt_test_3_t:fd use;
+	allow ckpt_test_1_t $1:fd use;
+	allow ckpt_test_2_t $1:fd use;
+	allow ckpt_test_3_t $1:fd use;
+	allow $1 ckpt_test_1_t:fifo_file rw_file_perms;
+	allow $1 ckpt_test_2_t:fifo_file rw_file_perms;
+	allow $1 ckpt_test_3_t:fifo_file rw_file_perms;
+	allow ckpt_test_1_t $1:process { sigchld };
+	allow ckpt_test_2_t $1:process { sigchld };
+	allow ckpt_test_3_t $1:process { sigchld };
+
+	allow $1 ckpt_test_file_t:file manage_file_perms;
+# need some way to give pty access... is there an automatic
+# way to guess at that type, or do we just assume that
+# caller is in staff_t or unconfined_t?
+')
+
diff --git a/selinux/cr-tests-policy.te b/selinux/cr-tests-policy.te
new file mode 100644
index 0000000..9efd0da
--- /dev/null
+++ b/selinux/cr-tests-policy.te
@@ -0,0 +1,62 @@
+policy_module(cr-tests-policy,1.0.0)
+
+########################################
+#
+# Declarations
+#
+
+attribute ckpt_test_domain;
+type ckpt_test_exec_t;
+files_type(ckpt_test_exec_t);
+
+type ckpt_test_1_t;
+typeattribute ckpt_test_1_t ckpt_test_domain;
+domain_type(ckpt_test_1_t)
+domain_entry_file(ckpt_test_1_t, ckpt_test_exec_t)
+
+type ckpt_test_2_t;
+domain_type(ckpt_test_2_t)
+typeattribute ckpt_test_2_t ckpt_test_domain;
+domain_entry_file(ckpt_test_2_t, ckpt_test_exec_t)
+
+type ckpt_test_3_t;
+domain_type(ckpt_test_3_t)
+typeattribute ckpt_test_3_t ckpt_test_domain;
+domain_entry_file(ckpt_test_3_t, ckpt_test_exec_t)
+
+type ckpt_test_file_t;
+files_type(ckpt_test_file_t);
+
+########################################
+#
+# local policy
+#
+
+
+# Some things all the test domains may do:
+manage_dirs_pattern(ckpt_test_domain, ckpt_test_file_t, ckpt_test_file_t)
+allow ckpt_test_domain { ckpt_test_exec_t ckpt_test_file_t }:file *;
+files_tmp_filetrans(ckpt_test_domain, ckpt_test_file_t, file)
+term_use_all_terms(ckpt_test_domain)
+#allow ckpt_test_domain self:process { fork setexec setfscreate setkeycreate setsockcreate setpgid sigkill setcap execmem };
+allow ckpt_test_domain self:process *;
+allow ckpt_test_domain self:fifo_file *;
+allow ckpt_test_domain self:capability *;
+
+# hardcode perms to unconfined pty
+gen_require(`
+	type unconfined_devpts_t;
+	type local_login_t;
+')
+allow ckpt_test_domain unconfined_devpts_t:chr_file { read write ioctl getattr };
+allow ckpt_test_domain local_login_t:fd *;
+
+allow ckpt_test_2_t ckpt_test_1_t:process { restore setcap };
+allow ckpt_test_2_t ckpt_test_1_t:msg restore;
+allow ckpt_test_2_t ckpt_test_1_t:ipc restore;
+allow ckpt_test_2_t ckpt_test_1_t:file restore;
+allow ckpt_test_2_t ckpt_test_1_t:fd use;
+allow ckpt_test_1_t ckpt_test_2_t:file entrypoint;
+allow ckpt_test_1_t ckpt_test_2_t:fd use;
+allow ckpt_test_1_t ckpt_test_2_t:fifo_file *;
+allow ckpt_test_1_t ckpt_test_2_t:process sigchld;
diff --git a/selinux/runtest.sh b/selinux/runtest.sh
new file mode 100644
index 0000000..65907b2
--- /dev/null
+++ b/selinux/runtest.sh
@@ -0,0 +1,163 @@
+#!/bin/bash
+# Copyright 2009 IBM Corp.
+# Author: Serge Hallyn
+
+selinuxload() {
+	if [ ! -d /usr/share/selinux/devel ]; then
+		echo install selinux-policy-devel
+		exit 1
+	fi
+	rm -rf cr-test-module
+	cp -r /usr/share/selinux/devel cr-test-module
+	rm -f cr-test-module/example.??
+	cp cr-tests-policy.* cr-test-module/
+	# plug our dirname into the file contexts file
+	dn=`pwd`
+	echo "$dn/ckpt -- gen_context(system_u:object_r:ckpt_test_exec_t,s0)" \
+		>> cr-test-module/cr-tests-policy.fc
+	# allow our context to transition to the test dirs
+	myrole=`cat /proc/self/attr/current |awk -F: '{ print $2 '}`
+	myctx=`cat /proc/self/attr/current |awk -F: '{ print $3 '}`
+	dirctx=`attr -qS -g selinux . | awk -F: '{ print $3 '}`
+cat >> cr-test-module/cr-tests-policy.te << EOF
+gen_require(\`
+	role $myrole;
+	type $myctx;
+	type $dirctx;
+')
+ckpt_test_domtrans($myctx,$myrole)
+allow $myctx ckpt_test_file_t:file rw_file_perms;
+EOF
+	dir=`pwd`
+	stop=0
+	while [ $stop -ne 1 ]; do
+		dirctx=`attr -qS -g selinux $dir | awk -F: '{ print $3 '}`
+cat >> cr-test-module/cr-tests-policy.te << EOF
+gen_require(\`
+	type $dirctx;
+')
+list_dirs_pattern(ckpt_test_domain,$dirctx,$dirctx)
+EOF
+		if [ $dir == "/" ]; then
+			stop=1
+		fi
+		dir=`dirname $dir`
+	done
+	(cd cr-test-module; make; semodule -i cr-tests-policy.pp)
+	ret=$?
+	if [ $ret -ne 0 ]; then
+		echo failed to load policy
+	fi
+	echo "policy loaded"
+}
+
+selinuxunload() {
+	semodule -r cr-tests-policy
+}
+
+source ../common.sh
+verify_freezer
+verify_paths
+
+cp `which restart` restart
+selinuxload
+
+rm -f ./cr-test.out out context
+
+dirctx=`attr -qS -g selinux . | awk -F: '{ print $3 '}`
+filctx=`attr -qS -g selinux ckpt.c | awk -F: '{ print $3 '}`
+chcon -t ckpt_test_file_t .
+chcon -t ckpt_test_exec_t ./restart
+chcon -t ckpt_test_file_t ./ckpt
+chcon -t ckpt_test_exec_t ./wrap
+
+trap '\
+setenforce 0; \
+semodule -B; \
+selinuxunload; \
+echo "Unloaded selinux policy, exiting"; \
+chcon -t $dirctx . ; \
+chcon -t $filctx ./ckpt ; \
+chcon -t $filctx ./context ; \
+chcon -t $filctx ./cr-test.out; \
+chcon -t $filctx ./wrap ; \
+chcon -t $filctx ./out ; \
+chcon -t $filctx ./restart ' EXIT
+
+semodule -BD
+setenforce 1
+
+# create a checkpoint image with task as type ckpt_test_1_t
+echo "Creating checkpoint image as ckpt_test_1_t"
+runcon -t ckpt_test_1_t ./wrap ./ckpt
+
+echo ab > context
+chcon -t ckpt_test_file_t context
+
+# restart from image starting as ckpt_test_2_t
+# make sure it was restarted as ckpt_test_2_t
+echo "Test 1: restart without KEEP_LSM and verify original task context"
+runcon -t ckpt_test_2_t -- ./restart < out
+ret=$?
+if [ $ret -ne 0 ]; then
+	echo "Restart failed, returned $ret"
+	exit 1
+fi
+context=`cat context | awk -F: '{ print $3 '}`
+if [ -z "$context" -o "$context" != "ckpt_test_2_t" ]; then
+	echo "Fail, context was $context instead of ckpt_test_2_t"
+	exit 1
+fi
+echo Pass
+
+echo ab > context
+chcon -t ckpt_test_file_t context
+# restart with KEEP_LSM from image as ckpt_test_3_t
+# make sure it fails
+echo "Test 2: restart with KEEP_LSM from unauthorized context"
+runcon -t ckpt_test_3_t -- ./restart -k < out
+if [ $? -ne 1 ]; then
+	echo "Fail"
+	exit 1
+fi
+echo Pass
+
+echo ab > context
+chcon -t ckpt_test_file_t context
+# restart with KEEP_LSM from image as ckpt_test2_t
+# make sure it was restarted as ckpt_test_t
+echo "Test 3: restart with KEEP_LSM and verify restored task context"
+runcon -t ckpt_test_2_t -- ./restart -k < out
+ret=$?
+if [ $ret -ne 0 ]; then
+	echo "Restart failed, returned $ret"
+	exit 1
+fi
+context=`cat context | awk -F: '{ print $3 '}`
+if [ -z "$context" -o "$context" != "ckpt_test_1_t" ]; then
+	echo "Fail"
+	exit 1
+fi
+echo Pass
+
+# END that is it for tests define so far
+echo "REST of tests are not yet implemented in policy, exiting."
+echo "All tests passed."
+exit 0
+
+cg=${freezermountpoint}/1
+mkdir -p $cg
+
+# restart from type ckpt_test3_t which creates files of type ckpt_testf2_t
+# make sure open file is ckpt_testf2_t
+echo "Test 4: restart without KEEP_LSM and verify open file context"
+runcon -t ckpt_test3_t -- ./restart -F $cg < out
+sleep 1
+pid=`pidof ckpt`
+context=`ls -lZ /proc/$pid/fd | grep cr-test.out | awk '{ print $3 '}`
+thaw
+if [ -z "$context" -o "$context" != "ckpt_testf2_t" ]; then
+	echo "Fail"
+	exit 1
+fi
+echo Pass
diff --git a/selinux/wrap.c b/selinux/wrap.c
new file mode 100644
index 0000000..3e92cc3
--- /dev/null
+++ b/selinux/wrap.c
@@ -0,0 +1,22 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Serge Hallyn
+ *
+ * if i do
+ *	runcon -t ckpt_test_1_t ./ckpt
+ * then the file->f_cred for ckpt will actually be runcon's
+ * before the context switch.  We don't want to have to give
+ * the restarter the rights to process:restore unconfined_t,
+ * so we'll do
+ *	runcon -t ckpt_test_1_t ./wrap ./ckpt
+ * so that ckpt is actually opened by a task with type
+ * ckpt_test_1_t, so that all file->f_creds are in that context.
+ */
+
+int main(int argc, char *argv[])
+{
+	char *newcmd, **newargv;
+	newargv = argv+1;
+	newcmd = argv[0];
+	return execv(newcmd, newargv);
+}
