From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH net-next 2/3] seccomp, ptrace: Add a mechanism to retrieve
	attached eBPF seccomp filters
Date: Tue, 13 Feb 2018 15:43:10 +0000
Message-ID: <20180213154308.GA3310__6065.00874641842$1518536529$gmane$org@ircssh-2.c.rugged-nimbus-611.internal>
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

This extends the the ptrace API to allow fetching eBPF seccomp filters
attached to programs. This is to enable checkpoint / restore cases.
The user will have to use the traditional PTRACE_SECCOMP_GET_FILTER
API call, and if they get an invalid medium type error they can switch
over to the eBPF variant of the API -- PTRACE_SECCOMP_GET_FILTER_EXTENDED.

Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
---
 include/linux/seccomp.h     | 12 ++++++++++++
 include/uapi/linux/ptrace.h |  5 +++--
 kernel/ptrace.c             |  3 +++
 kernel/seccomp.c            | 37 +++++++++++++++++++++++++++++++++++++
 4 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index c723a5c4e3ff..97fdbcffacc2 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -110,4 +110,16 @@ static inline long seccomp_get_metadata(struct task_struct *task,
 	return -EINVAL;
 }
 #endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
+#if defined(CONFIG_SECCOMP_FILTER_EXTENDED) && defined(CONFIG_CHECKPOINT_RESTORE)
+extern long seccomp_get_filter_extended(struct task_struct *task,
+					unsigned long n,
+					void __user *data);
+#else
+static inline long seccomp_get_filter_extended(struct task_struct *task,
+					       unsigned long n,
+					       void __user *data)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_SECCOMP_FILTER_EXTENDED && CONFIG_CHECKPOINT_RESTORE */
 #endif /* _LINUX_SECCOMP_H */
diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
index e46d82b91166..c619eb46b9d9 100644
--- a/include/uapi/linux/ptrace.h
+++ b/include/uapi/linux/ptrace.h
@@ -65,8 +65,9 @@ struct ptrace_peeksiginfo_args {
 #define PTRACE_GETSIGMASK	0x420a
 #define PTRACE_SETSIGMASK	0x420b
 
-#define PTRACE_SECCOMP_GET_FILTER	0x420c
-#define PTRACE_SECCOMP_GET_METADATA	0x420d
+#define PTRACE_SECCOMP_GET_FILTER		0x420c
+#define PTRACE_SECCOMP_GET_METADATA		0x420d
+#define PTRACE_SECCOMP_GET_FILTER_EXTENDED	0x420e
 
 struct seccomp_metadata {
 	unsigned long filter_off;	/* Input: which filter */
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 21fec73d45d4..90c62f9e1a55 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1096,6 +1096,9 @@ int ptrace_request(struct task_struct *child, long request,
 		ret = seccomp_get_metadata(child, addr, datavp);
 		break;
 
+	case PTRACE_SECCOMP_GET_FILTER_EXTENDED:
+		ret = seccomp_get_filter_extended(child, addr, datavp);
+
 	default:
 		break;
 	}
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index b30dd25c1cb8..931a13a8cd63 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1155,6 +1155,43 @@ long seccomp_get_metadata(struct task_struct *task,
 }
 #endif
 
+#if defined(CONFIG_SECCOMP_FILTER_EXTENDED) && defined(CONFIG_CHECKPOINT_RESTORE)
+long seccomp_get_filter_extended(struct task_struct *task,
+				 unsigned long filter_off,
+				 void __user *data)
+{
+	struct seccomp_filter *filter;
+	struct bpf_prog *prog;
+	long ret;
+
+	if (!capable(CAP_SYS_ADMIN) ||
+	    current->seccomp.mode != SECCOMP_MODE_DISABLED) {
+		return -EACCES;
+	}
+
+	filter = get_nth_filter(task, filter_off);
+	if (IS_ERR(filter))
+		return PTR_ERR(filter);
+
+	if (bpf_prog_was_classic(filter->prog)) {
+		ret = -EMEDIUMTYPE;
+		goto out;
+	}
+	prog = bpf_prog_inc_not_zero(filter->prog);
+	if (IS_ERR(prog)) {
+		ret = PTR_ERR(prog);
+		goto out;
+	}
+
+	ret = bpf_prog_new_fd(filter->prog);
+	if (ret < 0)
+		bpf_prog_put(prog);
+out:
+	__put_seccomp_filter(filter);
+	return ret;
+}
+#endif
+
 #ifdef CONFIG_SYSCTL
 
 /* Human readable action names for friendly sysctl interaction */
-- 
2.14.1
