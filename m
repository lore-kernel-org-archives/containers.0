From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: remove tasklist_lock from cgroup_attach_proc
Date: Thu, 22 Dec 2011 16:58:57 -0800
Message-ID: <20111223005857.GL13529@google.com>
References: <1324592816-13792-1-git-send-email-msb@chromium.org>
	<20111222225102.GM17084@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111222225102.GM17084-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:
> Hello,
> 
> On Thu, Dec 22, 2011 at 02:26:55PM -0800, Mandeep Singh Baines wrote:
> > @@ -2283,14 +2261,26 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
> >  
> >  	threadgroup_lock(tsk);
> >  
> > -	if (threadgroup)
> > +	if (threadgroup) {
> > +		if (!thread_group_leader(tsk)) {
> > +			/*
> > +			 * a race with de_thread from another thread's exec()
> > +			 * may strip us of our leadership, if this happens,
> > +			 * there is no choice but to throw this task away and
> > +			 * try again (from cgroup_procs_write); this is
> > +			 * "double-double-toil-and-trouble-check locking".
> > +			 */
> > +			ret = -EAGAIN;
> > +			goto out_unlock_threadgroup;
> > +		}
> >  		ret = cgroup_attach_proc(cgrp, tsk);
> 
> Ummm... can't we just do tsk = tsk->leader after locking threadgroup?

You're right. Nice!

New series coming up.

> Why do we need to retry from the beginning?
> 
> Thanks.
> 
> -- 
> tejun
