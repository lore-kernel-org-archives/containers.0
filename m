From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [v11][PATCH 7/9] Define do_fork_with_pids()
Date: Wed, 4 Nov 2009 21:40:39 -0800
Message-ID: <20091105054039.GG16142__29109.5605738976$1257399683$gmane$org@us.ibm.com>
References: <20091105053053.GA11289@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091105053053.GA11289-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [v11][PATCH 7/9] Define do_fork_with_pids()

do_fork_with_pids() is same as do_fork(), except that it takes an
additional, 'pid_set', parameter. This parameter, currently unused,
specifies the set of target pids of the process in each of its pid
namespaces.

Changelog[v7]:
	- Drop 'struct pid_set' object and pass in 'pid_t *target_pids'
	  instead of 'struct pid_set *'.

Changelog[v6]:
	- (Nathan Lynch, Arnd Bergmann, H. Peter Anvin, Linus Torvalds)
	  Change 'pid_set.pids' to a 'pid_t pids[]' so size of 'struct pid_set'
	  is constant across architectures.
	- (Nathan Lynch) Change 'pid_set.num_pids' to 'unsigned int'.

Changelog[v4]:
	- Rename 'struct target_pid_set' to 'struct pid_set' since it may
	  be useful in other contexts.

Changelog[v3]:
	- Fix "long-line" warning from checkpatch.pl

Changelog[v2]:
	- To facilitate moving architecture-inpdendent code to kernel/fork.c
	  pass in 'struct target_pid_set __user *' to do_fork_with_pids()
	  rather than 'pid_t *' (next patch moves the arch-independent
	  code to kernel/fork.c)

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/sched.h |    3 +++
 kernel/fork.c         |   17 +++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6b319a0..265efe5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2153,6 +2153,9 @@ extern int disallow_signal(int);
 
 extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
 extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
+extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *,
+				unsigned long, int __user *, int __user *,
+				unsigned int, pid_t __user *);
 struct task_struct *fork_idle(int);
 
 extern void set_task_comm(struct task_struct *tsk, char *from);
diff --git a/kernel/fork.c b/kernel/fork.c
index 11f77ed..210e841 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1377,12 +1377,14 @@ struct task_struct * __cpuinit fork_idle(int cpu)
  * It copies the process, and if successful kick-starts
  * it and waits for it to finish using the VM if required.
  */
-long do_fork(unsigned long clone_flags,
+long do_fork_with_pids(unsigned long clone_flags,
 	      unsigned long stack_start,
 	      struct pt_regs *regs,
 	      unsigned long stack_size,
 	      int __user *parent_tidptr,
-	      int __user *child_tidptr)
+	      int __user *child_tidptr,
+	      unsigned int num_pids,
+	      pid_t __user *upids)
 {
 	struct task_struct *p;
 	int trace = 0;
@@ -1485,6 +1487,17 @@ long do_fork(unsigned long clone_flags,
 	return nr;
 }
 
+long do_fork(unsigned long clone_flags,
+	      unsigned long stack_start,
+	      struct pt_regs *regs,
+	      unsigned long stack_size,
+	      int __user *parent_tidptr,
+	      int __user *child_tidptr)
+{
+	return do_fork_with_pids(clone_flags, stack_start, regs, stack_size,
+			parent_tidptr, child_tidptr, 0, NULL);
+}
+
 #ifndef ARCH_MIN_MMSTRUCT_ALIGN
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
-- 
1.6.0.4
