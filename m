From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 15/15] Hooks over the code to show correct values to user
Date: Fri, 27 Jul 2007 10:44:54 +0400
Message-ID: <46A99466.4030009@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B6AD.4000307@openvz.org>
	<20070727055736.GC23584@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070727055736.GC23584-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Pavel Emelianov [xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org] wrote:
> | diff -upr linux-2.6.23-rc1-mm1.orig/fs/proc/array.c 
> | linux-2.6.23-rc1-mm1-7/fs/proc/array.c
> | --- linux-2.6.23-rc1-mm1.orig/fs/proc/array.c	2007-07-26 
> | 16:34:45.000000000 +0400
> | +++ linux-2.6.23-rc1-mm1-7/fs/proc/array.c	2007-07-26 
> | 16:36:36.000000000 +0400
> | @@ -77,6 +77,7 @@
> | #include <linux/cpuset.h>
> | #include <linux/rcupdate.h>
> | #include <linux/delayacct.h>
> | +#include <linux/pid_namespace.h>
> | 
> | #include <asm/pgtable.h>
> | #include <asm/processor.h>
> | @@ -161,7 +162,9 @@ static inline char *task_state(struct ta
> | 	struct group_info *group_info;
> | 	int g;
> | 	struct fdtable *fdt = NULL;
> | +	struct pid_namespace *ns;
> | 
> | +	ns = current->nsproxy->pid_ns;
> | 	rcu_read_lock();
> | 	buffer += sprintf(buffer,
> | 		"State:\t%s\n"
> | @@ -172,9 +175,12 @@ static inline char *task_state(struct ta
> | 		"Uid:\t%d\t%d\t%d\t%d\n"
> | 		"Gid:\t%d\t%d\t%d\t%d\n",
> | 		get_task_state(p),
> | -		p->tgid, p->pid,
> | -		pid_alive(p) ? rcu_dereference(p->real_parent)->tgid : 0,
> | -		pid_alive(p) && p->ptrace ? rcu_dereference(p->parent)->pid 
> | : 0,
> | +	       	task_tgid_nr_ns(p, ns),
> | +		task_pid_nr_ns(p, ns),
> | +	       	pid_alive(p) ?
> | +			task_ppid_nr_ns(p, ns) : 0,
> | +		pid_alive(p) && p->ptrace ?
> | +			task_tgid_nr_ns(rcu_dereference(p->parent), ns) : 0,
> 
> Hmm. I think we have this reversed here. We should print the 'tgid' of
> task->real_parent and 'pid' of task->parent.
> 

You mean smth like task_tgid_nr_ns(p->real_parent) ? Yes, thanks :)
