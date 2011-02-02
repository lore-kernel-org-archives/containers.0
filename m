From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH] cgroups: respect cgroup timer slack value in prctl
Date: Wed, 2 Feb 2011 09:15:09 +0200
Message-ID: <20110202071509.GB25262__25096.8325221494$1296631064$gmane$org@shutemov.name>
References: <1296600103-15726-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<20110202070743.GO16432@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110202070743.GO16432-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 01, 2011 at 11:07:43PM -0800, Matt Helsley wrote:
> On Tue, Feb 01, 2011 at 02:41:43PM -0800, jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org wrote:
> > From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > 
> > Per cgroup timer slack value is used to manage task groups
> > for more friendly power management behavior. Once a task is
> > attached to a cgroup, we should not allow user to change
> > (escape) the per cgroup restriction unless a more relaxed
> > timer slack value is given by user via prctl.
> > 
> > Signed-off-by: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> 
> > ---
> >  include/linux/cgroup.h      |   13 +++++++++++++
> 
> Looks like the original two patches (one or more implementing:
> 
> >  kernel/cgroup_timer_slack.c |    4 ----
> 
> ) were not sent to containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org ?

Hm.. 

https://lists.linux-foundation.org/pipermail/containers/2011-February/026415.html

> 
> >  kernel/sys.c                |   21 ++++++++++++++++++++-
> >  3 files changed, 33 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> > index ed4ba11..4405666 100644
> > --- a/include/linux/cgroup.h
> > +++ b/include/linux/cgroup.h
> > @@ -627,6 +627,19 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
> >  unsigned short css_id(struct cgroup_subsys_state *css);
> >  unsigned short css_depth(struct cgroup_subsys_state *css);
> > 
> > +#ifdef CONFIG_CGROUP_TIMER_SLACK
> > +struct timer_slack_cgroup {
> > +	struct cgroup_subsys_state css;
> > +	unsigned long timer_slack_ns;
> > +};
> > +
> > +static inline struct timer_slack_cgroup *task_timer_slack(struct task_struct *task)
> > +{
> > +	return container_of(task_subsys_state(task, timer_slack_subsys_id),
> > +			    struct timer_slack_cgroup, css);
> > +}
> > +#endif
> > +
> >  #else /* !CONFIG_CGROUPS */
> > 
> >  static inline int cgroup_init_early(void) { return 0; }
> > diff --git a/kernel/cgroup_timer_slack.c b/kernel/cgroup_timer_slack.c
> > index daa452d..1de122a 100644
> > --- a/kernel/cgroup_timer_slack.c
> > +++ b/kernel/cgroup_timer_slack.c
> > @@ -4,10 +4,6 @@
> >  #include <linux/slab.h>
> > 
> >  struct cgroup_subsys timer_slack_subsys;
> > -struct timer_slack_cgroup {
> > -	struct cgroup_subsys_state css;
> > -	unsigned long timer_slack_ns;
> > -};
> > 
> >  static struct timer_slack_cgroup *cgroup_to_tslack_cgroup(struct cgroup *cgroup)
> >  {
> > diff --git a/kernel/sys.c b/kernel/sys.c
> > index 7f5a0cd..433fcdb 100644
> > --- a/kernel/sys.c
> > +++ b/kernel/sys.c
> > @@ -37,6 +37,8 @@
> >  #include <linux/ptrace.h>
> >  #include <linux/fs_struct.h>
> >  #include <linux/gfp.h>
> > +#include <linux/cgroup.h>
> > +#include <linux/init_task.h>
> > 
> >  #include <linux/compat.h>
> >  #include <linux/syscalls.h>
> > @@ -1688,8 +1690,25 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
> >  			if (arg2 <= 0)
> >  				current->timer_slack_ns =
> >  					current->default_timer_slack_ns;
> > -			else
> > +			else {
> > +#ifdef CONFIG_CGROUP_TIMER_SLACK
> > +				/* only allow more relaxed slack value than
> > +				 * the attached timer slack cgroup allows.
> > +				 */
> > +				unsigned long cg_timer_slack;
> > +
> > +				rcu_read_lock();
> > +				cg_timer_slack = task_timer_slack(current)->timer_slack_ns;
> > +				rcu_read_unlock();
> > +				if (cg_timer_slack < arg2 || cg_timer_slack
> > +					== TIMER_SLACK_NS_DEFAULT)
> > +					current->timer_slack_ns = arg2;
> > +				else
> > +					return -EINVAL;
> > +#else
> 
> Looks like this could be an inline function which returns the
> minimum timer slack allowed for the task. Then the code here would be:
> 
> if (arg2 <= 0)
> 	current->timer_slack_ns = current->default_timer_slack_ns;
> else {
> 	if (arg2 < min_timer_slack_ns(tsk))
> 		return -EINVAL; /* Can't set less than the minimum */
> 	current->timer_slack_ns = arg2;
> }
> 
> and the #ifdef CONFIG_CGROUP_TIMER_SLACK bits could be in a header as
> usual.
> 
> Incidentally, shouldn't that really be -EPERM since it's not an invalid
> value -- just one that's not permitted due to restrictions imposed by
> the cgroup subsystem?

I guess better to add more functionality to the cgroup subsystem.
I'm going to implement timer_slack.min_slack_ns and timer_slack.max_slack_ns.
prctl(2) will be modified to check these limits.


> >  				current->timer_slack_ns = arg2;
> > +#endif
> > +			}
> >  			error = 0;
> >  			break;
> >  		case PR_MCE_KILL:
> > -- 
> > 1.7.0.4
> > 
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers

-- 
 Kirill A. Shutemov
