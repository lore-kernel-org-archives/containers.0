From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 2/3] Pid ns helpers for signals
Date: Sat, 1 Sep 2007 15:56:01 +0400
Message-ID: <20070901115601.GA258@tv-sign.ru>
References: <20070831203634.GB3268@us.ibm.com>
	<20070901112903.GD191@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070901112903.GD191-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
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

On 09/01, Oleg Nesterov wrote:
>
> On 08/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> >
> > +static struct pid_namespace *get_task_pid_ns(struct task_struct *tsk)
> > +{
> > +	struct pid *pid;
> > +	struct pid_namespace *ns;
> > +
> > +	pid = get_task_pid(tsk, PIDTYPE_PID);
> > +	ns = get_pid_ns(pid_active_ns(pid));
> > +	put_pid(pid);
> > +
> > +	return ns;
> > +}
> 
> Hmm. Firstly, we don't need this for the "current", but all users of this func
> also do get_task_pid_ns(current).
> 
> Also, we don't need get/put_pid. rcu locks are enough,
> 
> 	rcu_read_lock();
> 	ns = get_pid_ns(pid_active_ns(task_pid(tks)));
> 	rcu_read_unlock();
> 
> However, do we really need this complications right now? Currently, we use
> this "compare namespaces" helpers only when we know that "struct pid" is
> stable. We are sending the signal to that task, it must be pid_alive(), and
> we either locked the task itself, or we hold tasklist.

(forgot to mention)

Otherwise, it is not safe to use "tsk" in get_task_pid_ns(), so I don't think
these get/put pid/pid_ns games make too much sense.

Oleg.
