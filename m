From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH, v3 2/2] cgroups: introduce timer slack subsystem
Date: Thu, 3 Feb 2011 09:51:17 -0800
Message-ID: <20110203095117.76a568fc__10556.8012375899$1296755793$gmane$org@putvin>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-3-git-send-email-kirill@shutemov.name>
	<20110202145605.6c9006fa@putvin>
	<20110203092229.GB1083@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110203092229.GB1083-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 3 Feb 2011 11:22:29 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> On Wed, Feb 02, 2011 at 02:56:05PM -0800, jacob pan wrote:
> > On Wed,  2 Feb 2011 22:47:36 +0200
> > "Kirill A. Shutsemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> > 
> > > From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > > 
> > > Provides a way of tasks grouping by timer slack value. Introduces
> > > per cgroup max and min timer slack value. When a task attaches to
> > > a cgroup, its timer slack value adjusts (if needed) to fit min-max
> > > range.
> > > 
> > > It also provides a way to set timer slack value for all tasks in
> > > the cgroup at once.
> > > 
> > > This functionality is useful in mobile devices where certain
> > > background apps are attached to a cgroup and minimum wakeups are
> > > desired.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > > Idea-by: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > > ---
> > >  include/linux/cgroup_subsys.h |    6 +
> > >  include/linux/init_task.h     |    4 +-
> > >  init/Kconfig                  |   10 ++
> > >  kernel/Makefile               |    1 +
> > >  kernel/cgroup_timer_slack.c   |  242
> > > +++++++++++++++++++++++++++++++++++++++++
> > 


> > 
> > > +
> > > +static struct cftype files[] = {
> > > +	{
> > > +		.name = "set_slack_ns",
> > > +		.write_u64 = tslack_write_set_slack_ns,
> > > +	},
> > should we also allow reading of the current slack_ns?
> 
> There is no 'current slack_ns' for a cgroup since any process free to
> change it with prctl().
> 

I think there is still a need for current slack_ns. e.g. if i created a
cgroup_1 then attach task_A and task_B to it such that their
individual timer_slack got adjusted based on the limit in the
cgroup. Now I set cgroup_1 timer_slack to be ts_1, then timer_slack
for both task_A and task_B are set to ts_1.

If i attach another task_C to cgroup_1, timer_slack for task_C will be
adjusted based on min/max setting of cgroup_1, which can be different
than ts_1. User has to manually set cgroup time_slack again to make them
identical.

I think this logic defeats the purpose of having timer_slack
subsystem in the first place. IMHO, the original intention was to have
grouping effect of tasks in the cgroup.

So my suggestion is to keep a per cgroup current timer_slack value,
which can be default to the system default at 50us. Like Arjan
suggested, we can enforce the timer_slack value in the timer code when
it is used. This way we can solve another problem where when a task is
detached from the cgroup, it would be desirable to restore its original
slack value.
