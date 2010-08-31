From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix API thinko
Date: Tue, 31 Aug 2010 17:57:29 +0300
Message-ID: <20100831145729.GA19109__38586.5897791975$1283267063$gmane$org@redhat.com>
References: <20100805225914.GA26772@redhat.com> <4C5C3985.5060706@us.ibm.com>
	<1281112704.10055.0.camel@x201>
	<20100825143520.9954d3f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100825143520.9954d3f9.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 25, 2010 at 02:35:20PM -0700, Andrew Morton wrote:
> On Fri, 06 Aug 2010 10:38:24 -0600
> Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Fri, 2010-08-06 at 09:34 -0700, Sridhar Samudrala wrote:
> > > On 8/5/2010 3:59 PM, Michael S. Tsirkin wrote:
> > > > cgroup_attach_task_current_cg API that have upstream is backwards: we
> > > > really need an API to attach to the cgroups from another process A to
> > > > the current one.
> > > >
> > > > In our case (vhost), a priveledged user wants to attach it's task to cgroups
> > > > from a less priveledged one, the API makes us run it in the other
> > > > task's context, and this fails.
> > > >
> > > > So let's make the API generic and just pass in 'from' and 'to' tasks.
> > > > Add an inline wrapper for cgroup_attach_task_current_cg to avoid
> > > > breaking bisect.
> > > >
> > > > Signed-off-by: Michael S. Tsirkin<mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > ---
> > > >
> > > > Paul, Li, Sridhar, could you please review the following
> > > > patch?
> > > >
> > > > I only compile-tested it due to travel, but looks
> > > > straight-forward to me.
> > > > Alex Williamson volunteered to test and report the results.
> > > > Sending out now for review as I might be offline for a bit.
> > > > Will only try to merge when done, obviously.
> > > >
> > > > If OK, I would like to merge this through -net tree,
> > > > together with the patch fixing vhost-net.
> > > > Let me know if that sounds ok.
> > > >
> > > > Thanks!
> > > >
> > > > This patch is on top of net-next, it is needed for fix
> > > > vhost-net regression in net-next, where a non-priveledged
> > > > process can't enable the device anymore:
> > > >
> > > > when qemu uses vhost, inside the ioctl call it
> > > > creates a thread, and tries to add
> > > > this thread to the groups of current, and it fails.
> > > > But we control the thread, so to solve the problem,
> > > > we really should tell it 'connect to out cgroups'.
> 
> So am I correct to assume that this change is now needed in 2.6.36, and
> unneeded in 2.6.35?

Yes, I think so. Unless there are objections, I intend to merge this
(with the review fixes) through net-2.6 together with a vhost-net patch
that depends on this fix.

> Can it affect the userspace<->kernel API in amy manner?  If so, it
> should be backported into earlier kernels to reduce the number of
> incompatible kernels out there.

I think it doesn't affect anything except 2.6.36-rcX,
earlier kernels didn't use this API.

> Paul, did you have any comments?
> 
> I didn't see any update in response to the minor review comments, so...
> 
> 
>  include/linux/cgroup.h |    1 +
>  kernel/cgroup.c        |    6 +++---
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff -puN include/linux/cgroup.h~cgroups-fix-api-thinko-fix include/linux/cgroup.h
> --- a/include/linux/cgroup.h~cgroups-fix-api-thinko-fix
> +++ a/include/linux/cgroup.h
> @@ -579,6 +579,7 @@ void cgroup_iter_end(struct cgroup *cgrp
>  int cgroup_scan_tasks(struct cgroup_scanner *scan);
>  int cgroup_attach_task(struct cgroup *, struct task_struct *);
>  int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
> +
>  static inline int cgroup_attach_task_current_cg(struct task_struct *tsk)
>  {
>  	return cgroup_attach_task_all(current, tsk);
> diff -puN kernel/cgroup.c~cgroups-fix-api-thinko-fix kernel/cgroup.c
> --- a/kernel/cgroup.c~cgroups-fix-api-thinko-fix
> +++ a/kernel/cgroup.c
> @@ -1798,13 +1798,13 @@ out:
>  int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
>  {
>  	struct cgroupfs_root *root;
> -	struct cgroup *cur_cg;
>  	int retval = 0;
>  
>  	cgroup_lock();
>  	for_each_active_root(root) {
> -		cur_cg = task_cgroup_from_root(from, root);
> -		retval = cgroup_attach_task(cur_cg, tsk);
> +		struct cgroup *from_cg = task_cgroup_from_root(from, root);
> +
> +		retval = cgroup_attach_task(from_cg, tsk);
>  		if (retval)
>  			break;
>  	}
> _
