From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 2/3] Pid ns helpers for signals
Date: Mon, 3 Sep 2007 20:24:55 +0400
Message-ID: <20070903162455.GA180@tv-sign.ru>
References: <20070831203634.GB3268@us.ibm.com>
	<20070901112903.GD191@tv-sign.ru> <20070901115601.GA258@tv-sign.ru>
	<20070903160147.GB2793@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070903160147.GB2793-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/03, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>
> Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
> | On 09/01, Oleg Nesterov wrote:
> | >
> | > On 08/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> | > >
> | > > +static struct pid_namespace *get_task_pid_ns(struct task_struct *tsk)
> | > > +{
> | > > +	struct pid *pid;
> | > > +	struct pid_namespace *ns;
> | > > +
> | > > +	pid = get_task_pid(tsk, PIDTYPE_PID);
> | > > +	ns = get_pid_ns(pid_active_ns(pid));
> | > > +	put_pid(pid);
> | > > +
> | > > +	return ns;
> | > > +}
> | > 
> | > Hmm. Firstly, we don't need this for the "current", but all users of this func
> | > also do get_task_pid_ns(current).
> | > 
> | > Also, we don't need get/put_pid. rcu locks are enough,
> | > 
> | > 	rcu_read_lock();
> | > 	ns = get_pid_ns(pid_active_ns(task_pid(tks)));
> | > 	rcu_read_unlock();
> | > 
> | > However, do we really need this complications right now? Currently, we use
> | > this "compare namespaces" helpers only when we know that "struct pid" is
> | > stable. We are sending the signal to that task, it must be pid_alive(), and
> | > we either locked the task itself, or we hold tasklist.
> | 
> | (forgot to mention)
> | 
> | Otherwise, it is not safe to use "tsk" in get_task_pid_ns(), so I don't think
> | these get/put pid/pid_ns games make too much sense.
> 
> get_pid(), put_pid(), get_pid_ns(), put_pid_ns() all allow pid to be NULL.
> You mean tsk itself can be NULL bc task is exiting ? 

My apologies, I was unclear (as always ;)

No, tsk can't be NULL, and its memory can't be freed, because we use this func
from signal sending path (see above).

But this (signal sending path) also guarantees that its pid is also stable and
can't be NULL, no need to get/put pid, or even check it is not NULL.

Oleg.
