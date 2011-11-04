From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 04/10] cgroup: always lock threadgroup during migration
Date: Fri, 4 Nov 2011 08:21:50 -0700
Message-ID: <20111104152150.GX4417@google.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-5-git-send-email-tj@kernel.org>
	<20111104175413.30afaf8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111104175413.30afaf8e.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Nov 04, 2011 at 05:54:13PM +0900, KAMEZAWA Hiroyuki wrote:
> > -	/* if PF_EXITING is set, the tsk->cgroups pointer is no longer safe. */
> > +	/* @tsk can't exit as its threadgroup is locked */
> >  	task_lock(tsk);
> > -	if (tsk->flags & PF_EXITING) {
> > -		task_unlock(tsk);
> > -		put_css_set(newcg);
> > -		return -ESRCH;
> > -	}
> > +	WARN_ON_ONCE(tsk->flags & PF_EXITING);
> >  	rcu_assign_pointer(tsk->cgroups, newcg);
> >  	task_unlock(tsk);
> 
> Is this task_lock/unlock is required ?

For put, I don't think it's necessary.

> > @@ -2116,11 +2120,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> >  			continue;
> >  		/* get old css_set pointer */
> >  		task_lock(tsk);
> > -		if (tsk->flags & PF_EXITING) {
> > -			/* ignore this task if it's going away */
> > -			task_unlock(tsk);
> > -			continue;
> > -		}
> >  		oldcg = tsk->cgroups;
> >  		get_css_set(oldcg);
> >  		task_unlock(tsk);

For get, I think it is; otherwise, nothing prevents someone else from
changing tsk->cgroups between load and get, and destroying it.

Thanks.

-- 
tejun
