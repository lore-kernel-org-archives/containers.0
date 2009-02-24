From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: debugging threaded apps running under a clone(CLONE_NEWPID)
Date: Tue, 24 Feb 2009 10:51:16 +0100
Message-ID: <49A3C314.6010806@fr.ibm.com>
References: <499EE0D1.1010001@fr.ibm.com> <20090223182153.GD13151@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090223182153.GD13151-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>> Hello !
>>
>> to debug threaded apps, gdb uses a special libthread_db which seeks in the
>> symbols of the exec the list of running threads. This list contains the glibc 
>> 'struct pthread' descriptor with pids and tids which values are relative 
>> to the namespace in which the threads were created.  
>>
>> unless you run gdb in the same pid namespace, gdb will not see any thread
>> in the debugged app. this is frustrating for some scenarios and some 
>> support from the kernel would be needed to address this issue. Here
>> are some ideas :
>>
>>    . enter a pid namespace. hard.  
>>
>>    . expose the pid numbers of a task in its pid namespaces, through some 
>>      ways like /proc/self/stat or /proc/self/pids and modify gdb to make 
>>      the conversion.
>>
>> How would you do it ? 
> 
> perhaps a /proc/$$/vpid which prints out
> 	task_pid_nr_ns(tsk, current->nsproxy->pidns)

yes something like below, which prints out too much values.

> then each thread opens an fd for /proc/self/vpid and passes it
> over an af_unix socket to the parent gdb, which then reads it
> to get the pid in its own ns?

if we suppose that gdb is running in a parent namespace, i'd fix 
the libthread_db to convert the pids of the threads in the child
namespace to the pids of the threads in the parent namespace using 
the new /proc file. this can be done with LD_PRELOAD but gdb also 
offers a framework to load operations interacting with threads. 

This needs more studies, specially on the gdb side, but I think we 
will need a way to convert pid values between parent and child 
namespace if we don't want to change the all the thread support in
gdb. 

C.


Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 fs/proc/base.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

Index: 2.6.27-mcr.git/fs/proc/base.c
===================================================================
--- 2.6.27-mcr.git.orig/fs/proc/base.c
+++ 2.6.27-mcr.git/fs/proc/base.c
@@ -2444,6 +2444,23 @@ static int proc_tgid_io_accounting(struc
 }
 #endif /* CONFIG_TASK_IO_ACCOUNTING */
 
+static int proc_pid_vpids(struct task_struct *task, char *buffer)
+{
+	struct pid_namespace *pid_ns = task->nsproxy->pid_ns;
+
+	return sprintf(buffer, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n",
+		       task_pid_nr_ns(task, pid_ns), // pid
+		       task_pid_nr(task),
+		       task_tgid_nr_ns(task, pid_ns), // tgid
+		       task_tgid_nr(task),
+		       task_tgid_nr_ns(task->real_parent, pid_ns), // ppid
+		       task_tgid_nr(task->real_parent),
+		       task_pgrp_nr_ns(task, pid_ns), // pgid
+		       task_pgrp_nr(task),
+		       task_session_nr_ns(task, pid_ns), // sid
+		       task_session_nr(task));
+}
+
 /*
  * Thread groups
  */
@@ -2519,6 +2536,7 @@ static const struct pid_entry tgid_base_
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, tgid_io_accounting),
 #endif
+	INF("vpids",	S_IRUGO, pid_vpids),
 };
 
 static int proc_tgid_base_readdir(struct file * filp,
@@ -2854,6 +2872,7 @@ static const struct pid_entry tid_base_s
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, tid_io_accounting),
 #endif
+	INF("vpids",	S_IRUGO, pid_vpids),
 };
 
 static int proc_tid_base_readdir(struct file * filp,
