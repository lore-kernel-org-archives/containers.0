From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 06/17] cgroup: remove duplicate RCU free on struct cgroup
Date: Mon, 19 Nov 2012 08:59:03 -0800
Message-ID: <20121119165903.GG15971@htj.dyndns.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-7-git-send-email-tj@kernel.org>
	<50A9F5B2.5080509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50A9F5B2.5080509-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Li.

On Mon, Nov 19, 2012 at 05:02:42PM +0800, Li Zefan wrote:
> On 2012/11/13 11:01, Tejun Heo wrote:
> > struct cgroup is made RCU-safe by synchronize_rcu() in cgroup_diput().
> 
> but synchronize_rcu() is called before ss->destroy().
> 
> rcu_read_lock();
> for_each_leaf_cfs_rq(cpu_rq(cpu), cfs_rq)
> 	print_cfs_rq(m, cpu, cfs_rq);
> 	-> call cgroup_path(task_group->css.cgroup);
> rcu_read_unlock();
> 
> With this patch, if the above code race with cgroup_diput(), we might
> end up accessing a cgroup which has been freed.

Ah, okay.  So, the problem here is that sched is using ->css_free() as
a de-registration point rather than freeing and may end up walking it
after ->css_free() is complete inside RCU period.

I think the correct solution is using ->css_offline() for that.  It's
ugly to require double RCU grace periods.

> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index 278752e..a91e7ad 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -893,7 +893,7 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
> >  
> >  		simple_xattrs_free(&cgrp->xattrs);
> >  
> > -		kfree_rcu(cgrp, rcu_head);
> > +		kfree(cgrp);
> 
> This was also added to prevent a race in group scheduling code, and I think the race still
> exists.

Care to point out which one?  I don't think the double-RCU workaround
is a good idea.  We really should sort it out by following object
lifecycle rules consistently.

Thanks.

-- 
tejun
