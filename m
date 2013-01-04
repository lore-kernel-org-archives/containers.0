From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] cgroups: move cgroup_event_listener.c to tools/cgroup
Date: Fri,  4 Jan 2013 13:05:17 -0800
Message-ID: <1357333518-28899-1-git-send-email-gthelen__32076.723004184$1357333571$gmane$org@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Move the cgroup_event_listener.c tool from Documentation into the new
tools/cgroup directory.

This change involves wiring cgroup_event_listener.c into the tools/
make system so that is can be built with:
  $ make tools/cgroup

Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 Documentation/cgroups/00-INDEX                |    2 -
 Documentation/cgroups/cgroup_event_listener.c |  110 -------------------------
 Documentation/cgroups/memcg_test.txt          |    3 +-
 tools/Makefile                                |   19 ++--
 tools/cgroup/.gitignore                       |    1 +
 tools/cgroup/Makefile                         |   11 +++
 tools/cgroup/cgroup_event_listener.c          |  110 +++++++++++++++++++++++++
 7 files changed, 133 insertions(+), 123 deletions(-)
 delete mode 100644 Documentation/cgroups/cgroup_event_listener.c
 create mode 100644 tools/cgroup/.gitignore
 create mode 100644 tools/cgroup/Makefile
 create mode 100644 tools/cgroup/cgroup_event_listener.c

diff --git a/Documentation/cgroups/00-INDEX b/Documentation/cgroups/00-INDEX
index f78b90a..f5635a0 100644
--- a/Documentation/cgroups/00-INDEX
+++ b/Documentation/cgroups/00-INDEX
@@ -4,8 +4,6 @@ blkio-controller.txt
 	- Description for Block IO Controller, implementation and usage details.
 cgroups.txt
 	- Control Groups definition, implementation details, examples and API.
-cgroup_event_listener.c
-	- A user program for cgroup listener.
 cpuacct.txt
 	- CPU Accounting Controller; account CPU usage for groups of tasks.
 cpusets.txt
diff --git a/Documentation/cgroups/cgroup_event_listener.c b/Documentation/cgroups/cgroup_event_listener.c
deleted file mode 100644
index 3e082f9..0000000
--- a/Documentation/cgroups/cgroup_event_listener.c
+++ /dev/null
@@ -1,110 +0,0 @@
-/*
- * cgroup_event_listener.c - Simple listener of cgroup events
- *
- * Copyright (C) Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
- */
-
-#include <assert.h>
-#include <errno.h>
-#include <fcntl.h>
-#include <libgen.h>
-#include <limits.h>
-#include <stdio.h>
-#include <string.h>
-#include <unistd.h>
-
-#include <sys/eventfd.h>
-
-#define USAGE_STR "Usage: cgroup_event_listener <path-to-control-file> <args>\n"
-
-int main(int argc, char **argv)
-{
-	int efd = -1;
-	int cfd = -1;
-	int event_control = -1;
-	char event_control_path[PATH_MAX];
-	char line[LINE_MAX];
-	int ret;
-
-	if (argc != 3) {
-		fputs(USAGE_STR, stderr);
-		return 1;
-	}
-
-	cfd = open(argv[1], O_RDONLY);
-	if (cfd == -1) {
-		fprintf(stderr, "Cannot open %s: %s\n", argv[1],
-				strerror(errno));
-		goto out;
-	}
-
-	ret = snprintf(event_control_path, PATH_MAX, "%s/cgroup.event_control",
-			dirname(argv[1]));
-	if (ret >= PATH_MAX) {
-		fputs("Path to cgroup.event_control is too long\n", stderr);
-		goto out;
-	}
-
-	event_control = open(event_control_path, O_WRONLY);
-	if (event_control == -1) {
-		fprintf(stderr, "Cannot open %s: %s\n", event_control_path,
-				strerror(errno));
-		goto out;
-	}
-
-	efd = eventfd(0, 0);
-	if (efd == -1) {
-		perror("eventfd() failed");
-		goto out;
-	}
-
-	ret = snprintf(line, LINE_MAX, "%d %d %s", efd, cfd, argv[2]);
-	if (ret >= LINE_MAX) {
-		fputs("Arguments string is too long\n", stderr);
-		goto out;
-	}
-
-	ret = write(event_control, line, strlen(line) + 1);
-	if (ret == -1) {
-		perror("Cannot write to cgroup.event_control");
-		goto out;
-	}
-
-	while (1) {
-		uint64_t result;
-
-		ret = read(efd, &result, sizeof(result));
-		if (ret == -1) {
-			if (errno == EINTR)
-				continue;
-			perror("Cannot read from eventfd");
-			break;
-		}
-		assert(ret == sizeof(result));
-
-		ret = access(event_control_path, W_OK);
-		if ((ret == -1) && (errno == ENOENT)) {
-				puts("The cgroup seems to have removed.");
-				ret = 0;
-				break;
-		}
-
-		if (ret == -1) {
-			perror("cgroup.event_control "
-					"is not accessible any more");
-			break;
-		}
-
-		printf("%s %s: crossed\n", argv[1], argv[2]);
-	}
-
-out:
-	if (efd >= 0)
-		close(efd);
-	if (event_control >= 0)
-		close(event_control);
-	if (cfd >= 0)
-		close(cfd);
-
-	return (ret != 0);
-}
diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index fc8fa97..ce94a83 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -399,8 +399,7 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 
  9.10 Memory thresholds
 	Memory controller implements memory thresholds using cgroups notification
-	API. You can use Documentation/cgroups/cgroup_event_listener.c to test
-	it.
+	API. You can use tools/cgroup/cgroup_event_listener.c to test it.
 
 	(Shell-A) Create cgroup and run event listener
 	# mkdir /cgroup/A
diff --git a/tools/Makefile b/tools/Makefile
index 1f9a529..fc57a28 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -3,6 +3,7 @@ include scripts/Makefile.include
 help:
 	@echo 'Possible targets:'
 	@echo ''
+	@echo '  cgroup     - cgroup tools'
 	@echo '  cpupower   - a tool for all things x86 CPU power'
 	@echo '  firewire   - the userspace part of nosy, an IEEE-1394 traffic sniffer'
 	@echo '  lguest     - a minimal 32-bit x86 hypervisor'
@@ -33,7 +34,7 @@ help:
 cpupower: FORCE
 	$(call descend,power/$@)
 
-firewire lguest perf usb virtio vm: FORCE
+cgroup firewire lguest perf usb virtio vm: FORCE
 	$(call descend,$@)
 
 selftests: FORCE
@@ -45,7 +46,7 @@ turbostat x86_energy_perf_policy: FORCE
 cpupower_install:
 	$(call descend,power/$(@:_install=),install)
 
-firewire_install lguest_install perf_install usb_install virtio_install vm_install:
+cgroup_install firewire_install lguest_install perf_install usb_install virtio_install vm_install:
 	$(call descend,$(@:_install=),install)
 
 selftests_install:
@@ -54,14 +55,14 @@ selftests_install:
 turbostat_install x86_energy_perf_policy_install:
 	$(call descend,power/x86/$(@:_install=),install)
 
-install: cpupower_install firewire_install lguest_install perf_install \
-		selftests_install turbostat_install usb_install virtio_install \
-		vm_install x86_energy_perf_policy_install
+install: cgroup_install cpupower_install firewire_install lguest_install \
+		perf_install selftests_install turbostat_install usb_install \
+		virtio_install vm_install x86_energy_perf_policy_install
 
 cpupower_clean:
 	$(call descend,power/cpupower,clean)
 
-firewire_clean lguest_clean perf_clean usb_clean virtio_clean vm_clean:
+cgroup_clean firewire_clean lguest_clean perf_clean usb_clean virtio_clean vm_clean:
 	$(call descend,$(@:_clean=),clean)
 
 selftests_clean:
@@ -70,8 +71,8 @@ selftests_clean:
 turbostat_clean x86_energy_perf_policy_clean:
 	$(call descend,power/x86/$(@:_clean=),clean)
 
-clean: cpupower_clean firewire_clean lguest_clean perf_clean selftests_clean \
-		turbostat_clean usb_clean virtio_clean vm_clean \
-		x86_energy_perf_policy_clean
+clean: cgroup_clean cpupower_clean firewire_clean lguest_clean perf_clean \
+		selftests_clean turbostat_clean usb_clean virtio_clean \
+		vm_clean x86_energy_perf_policy_clean
 
 .PHONY: FORCE
diff --git a/tools/cgroup/.gitignore b/tools/cgroup/.gitignore
new file mode 100644
index 0000000..633cd9b
--- /dev/null
+++ b/tools/cgroup/.gitignore
@@ -0,0 +1 @@
+cgroup_event_listener
diff --git a/tools/cgroup/Makefile b/tools/cgroup/Makefile
new file mode 100644
index 0000000..b428619
--- /dev/null
+++ b/tools/cgroup/Makefile
@@ -0,0 +1,11 @@
+# Makefile for cgroup tools
+
+CC = $(CROSS_COMPILE)gcc
+CFLAGS = -Wall -Wextra
+
+all: cgroup_event_listener
+%: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+clean:
+	$(RM) cgroup_event_listener
diff --git a/tools/cgroup/cgroup_event_listener.c b/tools/cgroup/cgroup_event_listener.c
new file mode 100644
index 0000000..3e082f9
--- /dev/null
+++ b/tools/cgroup/cgroup_event_listener.c
@@ -0,0 +1,110 @@
+/*
+ * cgroup_event_listener.c - Simple listener of cgroup events
+ *
+ * Copyright (C) Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
+ */
+
+#include <assert.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <libgen.h>
+#include <limits.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#include <sys/eventfd.h>
+
+#define USAGE_STR "Usage: cgroup_event_listener <path-to-control-file> <args>\n"
+
+int main(int argc, char **argv)
+{
+	int efd = -1;
+	int cfd = -1;
+	int event_control = -1;
+	char event_control_path[PATH_MAX];
+	char line[LINE_MAX];
+	int ret;
+
+	if (argc != 3) {
+		fputs(USAGE_STR, stderr);
+		return 1;
+	}
+
+	cfd = open(argv[1], O_RDONLY);
+	if (cfd == -1) {
+		fprintf(stderr, "Cannot open %s: %s\n", argv[1],
+				strerror(errno));
+		goto out;
+	}
+
+	ret = snprintf(event_control_path, PATH_MAX, "%s/cgroup.event_control",
+			dirname(argv[1]));
+	if (ret >= PATH_MAX) {
+		fputs("Path to cgroup.event_control is too long\n", stderr);
+		goto out;
+	}
+
+	event_control = open(event_control_path, O_WRONLY);
+	if (event_control == -1) {
+		fprintf(stderr, "Cannot open %s: %s\n", event_control_path,
+				strerror(errno));
+		goto out;
+	}
+
+	efd = eventfd(0, 0);
+	if (efd == -1) {
+		perror("eventfd() failed");
+		goto out;
+	}
+
+	ret = snprintf(line, LINE_MAX, "%d %d %s", efd, cfd, argv[2]);
+	if (ret >= LINE_MAX) {
+		fputs("Arguments string is too long\n", stderr);
+		goto out;
+	}
+
+	ret = write(event_control, line, strlen(line) + 1);
+	if (ret == -1) {
+		perror("Cannot write to cgroup.event_control");
+		goto out;
+	}
+
+	while (1) {
+		uint64_t result;
+
+		ret = read(efd, &result, sizeof(result));
+		if (ret == -1) {
+			if (errno == EINTR)
+				continue;
+			perror("Cannot read from eventfd");
+			break;
+		}
+		assert(ret == sizeof(result));
+
+		ret = access(event_control_path, W_OK);
+		if ((ret == -1) && (errno == ENOENT)) {
+				puts("The cgroup seems to have removed.");
+				ret = 0;
+				break;
+		}
+
+		if (ret == -1) {
+			perror("cgroup.event_control "
+					"is not accessible any more");
+			break;
+		}
+
+		printf("%s %s: crossed\n", argv[1], argv[2]);
+	}
+
+out:
+	if (efd >= 0)
+		close(efd);
+	if (event_control >= 0)
+		close(event_control);
+	if (cfd >= 0)
+		close(cfd);
+
+	return (ret != 0);
+}
-- 
1.7.7.3
