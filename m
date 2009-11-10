From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr 2/2] add nsexeccwp to test clone-with-pids
Date: Tue, 10 Nov 2009 10:59:22 -0600
Message-ID: <20091110165922.GA19263@us.ibm.com>
References: <20091110165839.GA19222@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091110165839.GA19222-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

One of the concerns with clone-with-pids is whether the
stack handling is all correct and robust enough to withstand
real usage.  Little testcases playing with pid values are
also necessary, but can't replace really using clone-with-pids
to start a shell from which to keep working.

This patch tweaks the old ns_exec.c namespace manipulation
program to add a -z option to specify a pid.  So you can:

	nsexeccwp -cmp /bin/bash # start a shell in a new pidns+mntns
	mount -t proc proc /proc # mount private /proc
	echo $$
		1
	nsexeccwp -z /bin/bash   #  start a shell with pid 999
	echo $$
		999

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile    |    5 +-
 clone.h     |   54 +++++++++
 nsexeccwp.c |  352 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 410 insertions(+), 1 deletions(-)
 create mode 100644 clone.h
 create mode 100644 nsexeccwp.c

diff --git a/Makefile b/Makefile
index 181cc1c..32a6893 100644
--- a/Makefile
+++ b/Makefile
@@ -20,7 +20,7 @@ CFLAGS += -g $(WARNS) $(CKPT_INCLUDE) $(DEBUG)
 # install dir
 INSTALL_DIR = /bin
 
-PROGS =	checkpoint restart ckptinfo
+PROGS =	checkpoint restart ckptinfo nsexeccwp
 
 # other cleanup
 OTHER = ckptinfo_types.c
@@ -39,11 +39,14 @@ restart: CFLAGS += -D__REENTRANT -pthread
 ifneq ($(SUBARCH),)
 restart: clone_$(SUBARCH).o
 restart: CFLAGS += -DARCH_HAS_CLONE_WITH_PID
+nsexeccwp: clone_$(SUBARCH).o
+nsexeccwp: CFLAGS += -DARCH_HAS_CLONE_WITH_PID
 endif
 
 # on powerpc, need also assembly file
 ifeq ($(SUBARCH),ppc)
 restart: clone_$(SUBARCH)_.o
+nsexeccwp: clone_$(SUBARCH)_.o
 endif
 
 # ckptinfo dependencies
diff --git a/clone.h b/clone.h
new file mode 100644
index 0000000..3569a45
--- /dev/null
+++ b/clone.h
@@ -0,0 +1,54 @@
+#ifndef CLONE_H
+#define CLONE_H
+/*
+ *  Copyright (C) 2007 IBM Corporation
+ *
+ *  Author: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+#include <sys/syscall.h>
+
+#ifndef HAVE_UNSHARE
+
+#if __i386__
+#    define __NR_unshare 310
+#elif __x86_64__
+#    define __NR_unshare 272
+#elif __ia64__
+#    define __NR_unshare 1296
+#elif __s390x__
+#    define __NR_unshare 303
+#elif __powerpc__
+#    define __NR_unshare 282
+#else
+#    error "Architecture not supported"
+#endif
+
+#endif /* HAVE_UNSHARE */
+
+#ifndef CLONE_NEWUTS
+#define CLONE_NEWUTS		0x04000000
+#endif
+
+#ifndef CLONE_NEWIPC
+#define CLONE_NEWIPC		0x08000000
+#endif
+
+#ifndef CLONE_NEWUSER
+#define CLONE_NEWUSER		0x10000000
+#endif
+
+#ifndef CLONE_NEWPID
+#define CLONE_NEWPID		0x20000000
+#endif
+
+#ifndef CLONE_NEWNET
+#define CLONE_NEWNET		0x40000000
+#endif
+
+#endif /* CLONE_H */
diff --git a/nsexeccwp.c b/nsexeccwp.c
new file mode 100644
index 0000000..f14b8b0
--- /dev/null
+++ b/nsexeccwp.c
@@ -0,0 +1,352 @@
+/*
+ * Copyright 2008,2009 IBM Corp.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <sched.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+#include <signal.h>
+#include <string.h>
+#include <errno.h>
+#include <libgen.h>
+#include <fcntl.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+
+#include "clone.h"
+
+struct pid_set {
+	int num_pids;
+	pid_t *pids;
+};
+
+typedef unsigned long long u64;
+typedef unsigned int u32;
+typedef int pid_t;
+struct clone_args {
+	u64 clone_flags_high;
+
+	u64 child_stack_base;
+	u64 child_stack_size;
+
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+
+	u32 nr_pids;
+
+	u32 reserved0;
+	u64 reserved1;
+};
+extern int clone_with_pids(int (*fn)(void *), void *child_stack,
+			unsigned long stack_size, unsigned long flags,
+			struct pid_set *target_pids, void *arg);
+
+extern pid_t getpgid(pid_t pid);
+extern pid_t getsid(pid_t pid);
+
+static const char* procname;
+
+static void usage(const char *name)
+{
+	printf("usage: %s [-h] [-c] [-mnuUip] [-P <pid-file>]"
+			"[command [arg ..]]\n", name);
+	printf("\n");
+	printf("  -h		this message\n");
+	printf("\n");
+	printf("  -z <pid>	use clone_with_pids and specify chosen pid\n");
+	printf("  		Note that -z and -p are not compatible\n");
+	printf("  -c		use 'clone' rather than 'unshare' system call\n");
+	printf("  -g		launch in new cgroup\n");
+	printf("  -m		mount namespace\n");
+	printf("  -n		network namespace\n");
+	printf("  -u		utsname namespace\n");
+	printf("  -U		userid namespace\n");
+	printf("  -i		ipc namespace\n");
+	printf("  -P <pid-file>	File in which to write global pid of cinit\n");
+	printf("  -p		pid namespace\n");
+	printf("  -f <flag>	extra clone flags\n");
+	printf("\n");
+	printf("(C) Copyright IBM Corp. 2006\n");
+	printf("\n");
+	exit(1);
+}
+
+static int string_to_ul(const char *str, unsigned long int *res)
+{
+	char *tail;
+	long long int r;
+
+	if (!*str)
+		return -1;
+
+	errno = 0;
+
+	r = strtol(str, &tail, 16);
+
+	/*
+	 * according to strtol(3), if errno is set or tail does no point
+	 * to the ending '\0', the conversion failed.
+	 */
+	if (errno || *tail)
+		return -1;
+
+	*res = r;
+	return 0;
+}
+
+/*
+ * Copied following opentty() from Fedora's util-linux rpm
+ * I just changed the "FATAL" message below from syslog()
+ * to printf
+ */
+static void
+opentty(const char * tty) {
+        int i, fd, flags;
+
+        fd = open(tty, O_RDWR | O_NONBLOCK);
+        if (fd == -1) {
+		printf("FATAL: can't reopen tty: %s", strerror(errno));
+                sleep(1);
+                exit(1);
+        }
+
+        flags = fcntl(fd, F_GETFL);
+        flags &= ~O_NONBLOCK;
+        fcntl(fd, F_SETFL, flags);
+
+        for (i = 0; i < fd; i++)
+                close(i);
+        for (i = 0; i < 3; i++)
+                if (fd != i)
+                        dup2(fd, i);
+        if (fd >= 3)
+                close(fd);
+}
+// Code copy end
+
+int do_newcgrp = 0;
+
+int load_cgroup_dir(char *dest, int len)
+{
+	FILE *f = fopen("/proc/mounts", "r");
+	char buf[200];
+	char *name, *path, *fsname, *options, *p1, *p2, *s;
+	if (!f)
+		return 0;
+	while (fgets(buf, 200, f)) {
+		name = strtok_r(buf, " ", &p1);
+		path = strtok_r(NULL, " ", &p1);
+		fsname = strtok_r(NULL, " ", &p1);
+		options = strtok_r(NULL, " ", &p1);
+		if (strcmp(fsname, "cgroup") != 0)
+			continue;
+
+		/* make sure the freezer is composed */
+		s = strtok_r(options, ",", &p2);
+		while (s && strcmp(s, "freezer") != 0)
+			s = strtok_r(NULL, ",", &p2);
+		if (!s)
+			continue;
+		strncpy(dest, path, len);
+		fclose(f);
+		return 1;
+	}
+	fclose(f);
+	printf("Freezer not mounted\n");
+	return 0;
+}
+
+int move_to_new_cgroup(int newcgroup)
+{
+	char cgroupname[150], cgroupbase[100], tasksfname[200];
+	FILE *fout;
+	int ret;
+
+	if (!load_cgroup_dir(cgroupbase, 100))
+		return 0;
+
+	snprintf(cgroupname, 150, "%s/%d", cgroupbase, newcgroup);
+	ret = mkdir(cgroupname, 0755);
+	if (ret)
+		return 0;
+	snprintf(tasksfname, 200, "%s/tasks", cgroupname);
+	fout = fopen(tasksfname, "w");
+	if (!fout)
+		return 0;
+	fprintf(fout, "%d\n", getpid());
+	fclose(fout);
+	return 1;
+}
+
+int pipefd[2];
+
+/* gah. opentty will close the pipefd */
+int check_newcgrp(void)
+{
+	int ret, newgroup;
+	char buf[20];
+
+	if (!do_newcgrp)
+		return 0;
+
+	close(pipefd[1]);
+	ret = read(pipefd[0], buf, 20);
+	close(pipefd[0]);
+	if (ret == -1) {
+		perror("read");
+		return 1;
+	}
+	newgroup = atoi(buf);
+	if (!move_to_new_cgroup(newgroup))
+		return 1;
+	do_newcgrp = 0;
+	return 0;
+}
+
+int do_child(void *vargv)
+{
+	char **argv = (char **)vargv;
+
+	if (check_newcgrp())
+		return 1;
+
+	execve(argv[0], argv, __environ);
+	perror("execve");
+	return 1;
+}
+
+void write_pid(char *pid_file, int pid)
+{
+	FILE *fp;
+
+	if (!pid_file)
+		return;
+
+	fp = fopen(pid_file, "w");
+	if (!fp) {
+		perror("fopen, pid_file");
+		exit(1);
+	}
+	fprintf(fp, "%d", pid);
+	fflush(fp);
+	fclose(fp);
+}
+
+int main(int argc, char *argv[])
+{	
+	int c;
+	unsigned long flags = 0, eflags = 0;
+	char ttyname[256];
+	int status;
+	int ret, use_clone = 0;
+	int pid;
+	char *pid_file = NULL;
+	struct pid_set pid_set;
+	int chosen_pid = 0;
+
+	pid_set.num_pids = 1;
+	pid_set.pids = &chosen_pid;
+
+	procname = basename(argv[0]);
+
+	memset(ttyname, '\0', sizeof(ttyname));
+	readlink("/proc/self/fd/0", ttyname, sizeof(ttyname));
+
+	while ((c = getopt(argc, argv, "+mguUiphz:cnf:P:")) != EOF) {
+		switch (c) {
+		case 'g': do_newcgrp = getpid();		break;
+		case 'm': flags |= CLONE_NEWNS;			break;
+		case 'c': use_clone = 1;			break;
+		case 'P': pid_file = optarg; 			break;
+		case 'u': flags |= CLONE_NEWUTS;		break;
+		case 'i': flags |= CLONE_NEWIPC;		break;
+		case 'U': flags |= CLONE_NEWUSER;		break;
+		case 'n': flags |= CLONE_NEWNET;		break;
+		case 'p': flags |= CLONE_NEWNS|CLONE_NEWPID;	break;
+		case 'z': chosen_pid = atoi(optarg);		break;
+		case 'f': if (!string_to_ul(optarg, &eflags)) {
+				flags |= eflags;
+				break;
+			}
+		case 'h':
+		default:
+			usage(procname);
+		}
+	};
+
+	if (chosen_pid) {
+		use_clone = 1;
+		if (flags & CLONE_NEWPID) {
+			printf("Error: can't use CLONE_NEWPID and pick a pid\n");
+			exit(1);
+		}
+	}
+	argv = &argv[optind];
+	argc = argc - optind;	
+
+	if (do_newcgrp) {
+		ret = pipe(pipefd);
+		if (ret) {
+			perror("pipe");
+			return -1;
+		}
+		do_newcgrp = pipefd[0];
+	}
+
+	if (use_clone) {
+		int stacksize = 4*getpagesize();
+		void *stack = malloc(stacksize);
+
+		if (!stack) {
+			perror("malloc");
+			return -1;
+		}
+
+		printf("about to clone with %lx\n", flags);
+		if (chosen_pid)
+			printf("Will choose pid %d\n", chosen_pid);
+		flags |= SIGCHLD;
+		pid = clone_with_pids(do_child, stack, stacksize, flags,
+			&pid_set, (void *)argv);
+		if (pid == -1) {
+			perror("clone");
+			return -1;
+		}
+	} else {
+		if ((pid = fork()) == 0) {
+			// Child.
+			//print_my_info(procname, ttyname);
+
+			if (check_newcgrp())
+				return 1;
+			opentty(ttyname);
+
+			printf("about to unshare with %lx\n", flags);
+			ret = unshare(flags);
+			if (ret < 0) {
+				perror("unshare");
+				return 1;
+			}		
+			
+			return do_child((void*)argv);
+		}
+
+	}
+	if (pid != -1 && do_newcgrp) {
+		char buf[20];
+		snprintf(buf, 20, "%d", pid);
+		close(pipefd[0]);
+		write(pipefd[1], buf, strlen(buf)+1);
+		close(pipefd[1]);
+	}
+
+	write_pid(pid_file, pid);
+
+	if ((ret = waitpid(pid, &status, __WALL)) < 0)
+		printf("waitpid() returns %d, errno %d\n", ret, errno);
+
+	exit(0);
+}
-- 
1.6.1.1
