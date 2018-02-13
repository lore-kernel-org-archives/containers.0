From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH net-next 3/3] bpf: Add eBPF seccomp sample programs
Date: Tue, 13 Feb 2018 15:43:22 +0000
Message-ID: <20180213154320.GA3319__46436.9128145792$1518536525$gmane$org@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
List-Id: containers.vger.kernel.org

From: Sargun Dhillon <sargun-5cpTQ645gshBDgjK7y7TUQ@public.gmane.org>

This adds two sample programs:
seccomp1: A simple eBPF seccomp filter
seccomp2: A program which installs an eBPF filter
	  and then retrieves it via ptrace to show
	  checkpoint / restore capability.

Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
---
 samples/bpf/Makefile        |  9 +++++++
 samples/bpf/bpf_load.c      |  9 +++++--
 samples/bpf/seccomp1_kern.c | 17 ++++++++++++
 samples/bpf/seccomp1_user.c | 34 +++++++++++++++++++++++
 samples/bpf/seccomp2_kern.c | 24 +++++++++++++++++
 samples/bpf/seccomp2_user.c | 66 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 157 insertions(+), 2 deletions(-)
 create mode 100644 samples/bpf/seccomp1_kern.c
 create mode 100644 samples/bpf/seccomp1_user.c
 create mode 100644 samples/bpf/seccomp2_kern.c
 create mode 100644 samples/bpf/seccomp2_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index ec3fc8d88e87..f1ba5fa18db7 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -43,6 +43,8 @@ hostprogs-y += xdp_redirect_cpu
 hostprogs-y += xdp_monitor
 hostprogs-y += xdp_rxq_info
 hostprogs-y += syscall_tp
+hostprogs-y += seccomp1
+hostprogs-y += seccomp2
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o ../../tools/lib/bpf/nlattr.o
@@ -93,6 +95,9 @@ xdp_redirect_cpu-objs := bpf_load.o $(LIBBPF) xdp_redirect_cpu_user.o
 xdp_monitor-objs := bpf_load.o $(LIBBPF) xdp_monitor_user.o
 xdp_rxq_info-objs := bpf_load.o $(LIBBPF) xdp_rxq_info_user.o
 syscall_tp-objs := bpf_load.o $(LIBBPF) syscall_tp_user.o
+seccomp1-objs := bpf_load.o $(LIBBPF) seccomp1_user.o
+seccomp2-objs := bpf_load.o $(LIBBPF) seccomp2_user.o
+
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -144,6 +149,8 @@ always += xdp_monitor_kern.o
 always += xdp_rxq_info_kern.o
 always += xdp2skb_meta_kern.o
 always += syscall_tp_kern.o
+always += seccomp1_kern.o
+always += seccomp2_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -188,6 +195,8 @@ HOSTLOADLIBES_xdp_redirect_cpu += -lelf
 HOSTLOADLIBES_xdp_monitor += -lelf
 HOSTLOADLIBES_xdp_rxq_info += -lelf
 HOSTLOADLIBES_syscall_tp += -lelf
+HOSTLOADLIBES_seccomp1 += -lelf
+HOSTLOADLIBES_seccomp2 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 69806d74fa53..856bc8b93916 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -67,6 +67,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
 	bool is_sockops = strncmp(event, "sockops", 7) == 0;
 	bool is_sk_skb = strncmp(event, "sk_skb", 6) == 0;
+	bool is_seccomp = strncmp(event, "seccomp", 7) == 0;
 	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
@@ -96,6 +97,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_SOCK_OPS;
 	} else if (is_sk_skb) {
 		prog_type = BPF_PROG_TYPE_SK_SKB;
+	} else if (is_seccomp) {
+		prog_type = BPF_PROG_TYPE_SECCOMP;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -110,7 +113,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk)
+	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk ||
+	    is_seccomp)
 		return 0;
 
 	if (is_socket || is_sockops || is_sk_skb) {
@@ -589,7 +593,8 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 		    memcmp(shname, "socket", 6) == 0 ||
 		    memcmp(shname, "cgroup/", 7) == 0 ||
 		    memcmp(shname, "sockops", 7) == 0 ||
-		    memcmp(shname, "sk_skb", 6) == 0) {
+		    memcmp(shname, "sk_skb", 6) == 0 ||
+		    memcmp(shname, "seccomp", 7) == 0) {
 			ret = load_and_attach(shname, data->d_buf,
 					      data->d_size);
 			if (ret != 0)
diff --git a/samples/bpf/seccomp1_kern.c b/samples/bpf/seccomp1_kern.c
new file mode 100644
index 000000000000..7fcbd48fa69a
--- /dev/null
+++ b/samples/bpf/seccomp1_kern.c
@@ -0,0 +1,17 @@
+#include <uapi/linux/seccomp.h>
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/unistd.h>
+#include "bpf_helpers.h"
+#include <uapi/linux/errno.h>
+
+/* Returns EPERM when trying to close fd 999 */
+SEC("seccomp")
+int bpf_prog1(struct seccomp_data *ctx)
+{
+	if (ctx->nr == __NR_close && ctx->args[0] == 999)
+		return SECCOMP_RET_ERRNO | EPERM;
+
+	return SECCOMP_RET_ALLOW;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/seccomp1_user.c b/samples/bpf/seccomp1_user.c
new file mode 100644
index 000000000000..35b3533de711
--- /dev/null
+++ b/samples/bpf/seccomp1_user.c
@@ -0,0 +1,34 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <assert.h>
+#include <stdio.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <linux/bpf.h>
+#include <sys/prctl.h>
+#include <strings.h>
+#include <errno.h>
+#include <sys/ptrace.h>
+#include <linux/seccomp.h>
+
+int main(int argc, char **argv)
+{
+	char filename[256];
+
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	assert(!prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER_EXTENDED, &prog_fd));
+	close(111);
+	assert(errno == EBADF);
+	close(999);
+	assert(errno = EPERM);
+
+	return 0;
+}
diff --git a/samples/bpf/seccomp2_kern.c b/samples/bpf/seccomp2_kern.c
new file mode 100644
index 000000000000..38014ed41b9b
--- /dev/null
+++ b/samples/bpf/seccomp2_kern.c
@@ -0,0 +1,24 @@
+#include <uapi/linux/seccomp.h>
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/unistd.h>
+#include "bpf_helpers.h"
+#include <uapi/linux/errno.h>
+
+static inline int unknown(struct seccomp_data *ctx)
+{
+	if (ctx->args[0] % 2 == 0)
+		return SECCOMP_RET_KILL;
+	return SECCOMP_RET_LOG;
+}
+
+/* Returns errno on sched_yield syscall */
+SEC("seccomp")
+int bpf_prog1(struct seccomp_data *ctx)
+{
+	if (ctx->nr == __NR_sched_yield)
+		return SECCOMP_RET_ERRNO | EPERM;
+
+	return SECCOMP_RET_ALLOW;
+}
+
+char _license[] SEC("license") = "aGPL";
diff --git a/samples/bpf/seccomp2_user.c b/samples/bpf/seccomp2_user.c
new file mode 100644
index 000000000000..986f70473fca
--- /dev/null
+++ b/samples/bpf/seccomp2_user.c
@@ -0,0 +1,66 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <assert.h>
+#include <stdio.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <linux/bpf.h>
+#include <sys/prctl.h>
+#include <strings.h>
+#include <errno.h>
+#include <linux/seccomp.h>
+#include <sys/ptrace.h>
+#include <sys/types.h>
+#include <signal.h>
+#include <stdlib.h>
+#include <sys/wait.h>
+#include <sched.h>
+
+#define PTRACE_SECCOMP_GET_FILTER_EXTENDED	0x420e
+static void tracee(void)
+{
+	assert(!prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0));
+
+	assert(!prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER_EXTENDED, &prog_fd));
+	sched_yield();
+	assert(errno == EPERM);
+	ptrace(PTRACE_TRACEME, 0, NULL, NULL);
+	kill(getpid(), SIGSTOP);
+}
+
+int main(int argc, char **argv)
+{
+	struct bpf_prog_info loaded_prog_info = {}, retrieved_prog_info = {};
+	char filename[256];
+	__u32 info_len;
+	pid_t child;
+	int fd;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+	info_len = sizeof(loaded_prog_info);
+	assert(!bpf_obj_get_info_by_fd(prog_fd[0], &loaded_prog_info,
+				       &info_len));
+
+	child = fork();
+	if (child == 0) {
+		tracee();
+		return 0;
+	}
+
+	wait(NULL);
+	/* Fetches eBPF filter from traced child */
+	fd = ptrace(PTRACE_SECCOMP_GET_FILTER_EXTENDED, child, 0, NULL);
+	kill(child, SIGKILL);
+	assert(fd >= 0);
+	info_len = sizeof(retrieved_prog_info);
+	assert(!bpf_obj_get_info_by_fd(fd, &retrieved_prog_info, &info_len));
+	assert(retrieved_prog_info.id == loaded_prog_info.id);
+
+	return 0;
+}
-- 
2.14.1
