From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/7][v8] Container-init signal semantics
Date: Sat, 07 Mar 2009 20:43:42 +0100
Message-ID: <49B2CE6E.3090501@free.fr>
References: <20090219030207.GA18783@us.ibm.com> <499D73C8.3090209@free.fr> <20090307190428.GA30594@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080303010407060308060503"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756051AbZCGTn5@vger.kernel.org>
In-Reply-To: <20090307190428.GA30594@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, Greg Kurz <gkurz@fr.ibm.com>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------080303010407060308060503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sukadev Bhattiprolu wrote:
>> Gregory Kurz proposed a solution:
>>    * when shutdown is called and we are not in the init pidns, then we kill 
>> the process 1 of the pidnamespace.
>>    * when reboot is called and we are not in the init pidns, then we reexec 
>> the init process, using the same command line. I guess this one could be 
>> easily retrieved if we are able to display /proc/1/cmdline ;)
>>
>> IMHO, this is a good proposition because it is generic and intuitive, no ?
>>
>> What do you thing ?
>>     
>
> Yes, I think it makes sense. Do we have any prototype patches that
> implement this behavior ?
>   
I have a simple prototype for the first case, added in attachment.
For the second case, I didn't had time to do it yet as it is not so 
trivial because we force an exec of another process.



--------------080303010407060308060503
Content-Type: text/x-diff;
 name="kill-cinit-at-shutdown.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kill-cinit-at-shutdown.patch"

Subject: kill the pid 1 process at shutdown
From: Daniel Lezcano <daniel.lezcano@free.fr>

This patch makes the pid 1 to be killed when we shutdown the host
and we are not in the init namespace.

Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
---
 include/linux/pid_namespace.h |    5 +++++
 kernel/pid_namespace.c        |   17 +++++++++++++++++
 kernel/sys.c                  |   17 +++++++++++------
 3 files changed, 33 insertions(+), 6 deletions(-)

Index: 2.6.29-rc3/include/linux/pid_namespace.h
===================================================================
--- 2.6.29-rc3.orig/include/linux/pid_namespace.h
+++ 2.6.29-rc3/include/linux/pid_namespace.h
@@ -44,6 +44,7 @@ static inline struct pid_namespace *get_
 
 extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *ns);
 extern void free_pid_ns(struct kref *kref);
+extern int power_off_pid_ns(struct pid_namespace *ns);
 extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
 
 static inline void put_pid_ns(struct pid_namespace *ns)
@@ -72,6 +73,10 @@ static inline void put_pid_ns(struct pid
 {
 }
 
+static inline int power_off_pid_ns(struct pid_namespace *ns)
+{
+	return -EINVAL;
+}
 
 static inline void zap_pid_ns_processes(struct pid_namespace *ns)
 {
Index: 2.6.29-rc3/kernel/pid_namespace.c
===================================================================
--- 2.6.29-rc3.orig/kernel/pid_namespace.c
+++ 2.6.29-rc3/kernel/pid_namespace.c
@@ -148,6 +148,23 @@ void free_pid_ns(struct kref *kref)
 		put_pid_ns(parent);
 }
 
+int power_off_pid_ns(struct pid_namespace *pid_ns)
+{
+	struct task_struct *task;
+
+	if (pid_ns == &init_pid_ns)
+		return -EINVAL;
+
+	rcu_read_lock();
+
+	task = pid_task(find_vpid(1), PIDTYPE_PID);
+	force_sig(SIGKILL, task);
+
+	rcu_read_unlock();
+
+	return 0;
+}
+
 void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 {
 	int nr;
Index: 2.6.29-rc3/kernel/sys.c
===================================================================
--- 2.6.29-rc3.orig/kernel/sys.c
+++ 2.6.29-rc3/kernel/sys.c
@@ -34,6 +34,7 @@
 #include <linux/seccomp.h>
 #include <linux/cpu.h>
 #include <linux/ptrace.h>
+#include <linux/pid_namespace.h>
 
 #include <linux/compat.h>
 #include <linux/syscalls.h>
@@ -393,15 +394,19 @@ SYSCALL_DEFINE4(reboot, int, magic1, int
 		break;
 
 	case LINUX_REBOOT_CMD_HALT:
-		kernel_halt();
-		unlock_kernel();
-		do_exit(0);
+		if (power_off_pid_ns(current->nsproxy->pid_ns)) {
+			kernel_halt();
+			unlock_kernel();
+			do_exit(0);
+		}
 		break;
 
 	case LINUX_REBOOT_CMD_POWER_OFF:
-		kernel_power_off();
-		unlock_kernel();
-		do_exit(0);
+		if (power_off_pid_ns(current->nsproxy->pid_ns)) {
+			kernel_power_off();
+			unlock_kernel();
+			do_exit(0);
+		}
 		break;
 
 	case LINUX_REBOOT_CMD_RESTART2:

--------------080303010407060308060503--
