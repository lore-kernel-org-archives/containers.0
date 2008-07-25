From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] introduce sys_restore
Date: Fri, 25 Jul 2008 17:58:49 -0500
Message-ID: <20080725225849.GA28764@us.ibm.com>
References: <20080725225655.GA28276@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080725225655.GA28276-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Create a useless (?) sys_restore system call.  All it does
is read a "checkpoint file" :) for a pid number and a file
to execute.

Since we don't take things like argv and envp and registers
from the checkpoint file, in order to make this easily
testable, we take those things as arguments.
Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> 
Signed-off-by: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
---
 arch/x86/kernel/process_32.c       |   10 ++++++++
 arch/x86/kernel/syscall_table_32.S |    2 +
 kernel/fork.c                      |   43 ++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 0c3927a..e11627d 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -688,6 +688,16 @@ out:
 	return error;
 }
 
+long do_restore(unsigned int fd,
+		char __user * __user *argv,
+                char __user * __user *envp,
+		struct pt_regs *regs);
+
+asmlinkage long sys_restore(struct pt_regs regs)
+{
+	return do_restore(regs.bx, regs.cx, regs.dx, &regs);
+}
+
 #define top_esp                (THREAD_SIZE - sizeof(unsigned long))
 #define top_ebp                (THREAD_SIZE - 2*sizeof(unsigned long))
 
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..019a8e4 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -326,3 +326,5 @@ ENTRY(sys_call_table)
 	.long sys_fallocate
 	.long sys_timerfd_settime	/* 325 */
 	.long sys_timerfd_gettime
+	.long sys_restore
+	
diff --git a/kernel/fork.c b/kernel/fork.c
index adefc11..0e43f69 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1679,3 +1679,46 @@ int unshare_files(struct files_struct **displaced)
 	task_unlock(task);
 	return 0;
 }
+
+
+#define CKPT_SIZE (PAGE_SIZE*4)
+char buf[CKPT_SIZE];
+char exe_filename[PAGE_SIZE];
+
+/*
+ * userspace will already have made us a new pidns
+ */
+long do_restore(unsigned int fd,
+		char __user * __user *argv,
+                char __user * __user *envp,
+		struct pt_regs *regs)
+{
+	int nr_scanned;
+        struct file *file;
+        long ret = -EBADF;
+        int fput_needed;
+	int pid;
+
+	if (!is_container_init(current)) {
+		printk("I am not init\n");
+		return -EPERM;
+	}
+
+        file = fget_light(fd, &fput_needed);
+	if (!file)
+		goto out;
+	ret = kernel_read(file, 0, buf, CKPT_SIZE);
+	fput_light(file, fput_needed);
+	if (ret <= 0)
+		goto out;
+	
+	nr_scanned = sscanf(buf, "%d %s", &pid, exe_filename);
+
+	if (nr_scanned != 2)
+		return -EINVAL;
+
+
+	ret = do_execve(exe_filename, argv, envp, regs);
+out:
+        return ret;
+}
-- 
1.5.4.3
