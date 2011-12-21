From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 5/5] cgroup: separate out cgroup_attach_proc error
	handling code
Date: Tue, 20 Dec 2011 16:02:31 -0800
Message-ID: <20111221000231.GX13529__8664.60103211484$1324426357$gmane$org@google.com>
References: <1324422873-31001-1-git-send-email-msb@chromium.org>
	<1324422873-31001-6-git-send-email-msb@chromium.org>
	<20111220233502.GN10752@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111220233502.GN10752-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:
> Hello,
> 
> On Tue, Dec 20, 2011 at 03:14:33PM -0800, Mandeep Singh Baines wrote:
> > @@ -2067,9 +2067,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> >  	read_unlock(&tasklist_lock);
> >  
> >  	/* methods shouldn't be called if no task is actually migrating */
> > -	retval = 0;
> > -	if (!group_size)
> > +	if (!group_size) {
> > +		retval = 0;
> >  		goto out_free_group_list;
> > +	}
> 
> Eh... I don't think this is an improvement.  It's just different.
> 

The main benefit is that the comment is directly above the code its
describing but I can drop this part of the change.

> > @@ -2126,20 +2127,20 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> >  	 */
> >  	synchronize_rcu();
> >  	cgroup_wakeup_rmdir_waiter(cgrp);
> > -	retval = 0;
> > +	flex_array_free(group);
> > +	return 0;
> 
> Hmm... maybe goto out_free_group_list?  Duplicating cleanup on success
> and failure paths can lead future updaters forget one of them.  The
> exit path in this function isn't pretty but I don't think the proposed
> patch improves it either.
> 

Should I drop the patch or add the goto? Its 5/5 so easy enough to drop
since nothing else depends on it.

> Thanks.
> 
> -- 
> tejun
