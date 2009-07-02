From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [cr_tests PATCH 1/1] ns_exec: define -g option to emulate ns cgroup
Date: Wed, 1 Jul 2009 20:15:40 -0500
Message-ID: <20090702011539.GA30945@us.ibm.com>
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

Since I'm asking Oren to send out cr patches I suppose I should
really be doing the same things with cr_tests patches that I intend
to apply to git://git.sr71.net/~hallyn/cr_tests.git.

This one lets ns_exec be used to emulate the way ns cgroup auto-creates
cgroups, without having ns_cgroup mounted.  This will be used in
some of the tests, process-tree being first.

From a03283de1ff71a9100db63883dde690350e0592a Mon Sep 17 00:00:00 2001
From: root <root-4X4tz4w3nuxpk64qw6wm7cxtgHpCUUYS@public.gmane.org>
Date: Wed, 1 Jul 2009 19:11:04 -0400
Subject: [PATCH 1/1] ns_exec: define -g option to emulate ns cgroup

Add a -g option to ns_exec.  When given, ns_exec will start the
new task in a new cgroup, named for the pid (in the pidns of
ns_exec itself) of the new child.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ns_exec.c |  111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 108 insertions(+), 3 deletions(-)

diff --git a/ns_exec.c b/ns_exec.c
index 8adace9..3c3aa9e 100644
--- a/ns_exec.c
+++ b/ns_exec.c
@@ -30,6 +30,7 @@ static void usage(const char *name)
 	printf("  -h		this message\n");
 	printf("\n");
 	printf("  -c		use 'clone' rather than 'unshare' system call\n");
+	printf("  -g		launch in new cgroup\n");
 	printf("  -m		mount namespace\n");
 	printf("  -n		network namespace\n");
 	printf("  -u		utsname namespace\n");
@@ -104,9 +105,94 @@ opentty(const char * tty) {
 }
 // Code copy end
 
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
 int do_child(void *vargv)
 {
 	char **argv = (char **)vargv;
+	int ret, newgroup = 0;
+	char buf[20];
+
+	if (check_newcgrp())
+		return 1;
+
 	execve(argv[0], argv, __environ);
 	perror("execve");
 	return 1;
@@ -145,10 +231,11 @@ int main(int argc, char *argv[])
 	memset(ttyname, '\0', sizeof(ttyname));
 	readlink("/proc/self/fd/0", ttyname, sizeof(ttyname));
 
-	while ((c = getopt(argc, argv, "+muUiphcnf:P:")) != EOF) {
+	while ((c = getopt(argc, argv, "+mguUiphcnf:P:")) != EOF) {
 		switch (c) {
-		case 'm': flags |= CLONE_NEWNS;  break;
-		case 'c': use_clone = 1; break;
+		case 'g': do_newcgrp = getpid();		break;
+		case 'm': flags |= CLONE_NEWNS;			break;
+		case 'c': use_clone = 1;			break;
 		case 'P': pid_file = optarg; 			break;
 		case 'u': flags |= CLONE_NEWUTS;		break;
 		case 'i': flags |= CLONE_NEWIPC;		break;
@@ -168,6 +255,15 @@ int main(int argc, char *argv[])
 	argv = &argv[optind];
 	argc = argc - optind;	
 	
+	if (do_newcgrp) {
+		ret = pipe(pipefd);
+		if (ret) {
+			perror("pipe");
+			return -1;
+		}
+		do_newcgrp = pipefd[0];
+	}
+
 	if (use_clone) {
 		int stacksize = 4*getpagesize();
 		void *childstack, *stack = malloc(stacksize);
@@ -189,6 +285,8 @@ int main(int argc, char *argv[])
 			// Child.
 			//print_my_info(procname, ttyname);
 
+			if (check_newcgrp())
+				return 1;
 			opentty(ttyname);
 
 			printf("about to unshare with %lx\n", flags);
@@ -202,6 +300,13 @@ int main(int argc, char *argv[])
 		}
 
 	}
+	if (pid != -1 && do_newcgrp) {
+		char buf[20];
+		snprintf(buf, 20, "%d", pid);
+		close(pipefd[0]);
+		write(pipefd[1], buf, strlen(buf)+1);
+		close(pipefd[1]);
+	}
 
 	write_pid(pid_file, pid);
 
-- 
1.6.1.1
