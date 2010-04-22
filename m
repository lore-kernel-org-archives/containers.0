From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/5] freezer cgroup: Fix an RCU warning in
	cgroup_freezing_or_frozen()
Date: Thu, 22 Apr 2010 12:59:11 -0700
Message-ID: <20100422195911.GN2524@linux.vnet.ibm.com>
References: <4BD016F4.8060108@cn.fujitsu.com> <4BD01768.2020606@cn.fujitsu.com>
	<1271939275.1776.345.camel@laptop>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1271939275.1776.345.camel@laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Cedric Le Goater <clg-DhXWPJtHtuFWk0Htik3J/w@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 22, 2010 at 02:27:55PM +0200, Peter Zijlstra wrote:
> On Thu, 2010-04-22 at 17:31 +0800, Li Zefan wrote:
> > with CONFIG_PROVE_RCU, a warning can be triggered when we
> > resume from suspend:
> > 
> > ...
> > include/linux/cgroup.h:533 invoked rcu_dereference_check() without protection!
> > ...
> > 
> > task_freezer() calls task_subsys_state(), which needs to be
> > protected by rcu_read_lock or cgroup_mutex.
> > 
> > Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > ---
> >  kernel/cgroup_freezer.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> > index 5038f4c..ac76983 100644
> > --- a/kernel/cgroup_freezer.c
> > +++ b/kernel/cgroup_freezer.c
> > @@ -53,6 +53,7 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
> >  	struct freezer *freezer;
> >  	enum freezer_state state;
> >  
> > +	rcu_read_lock();
> >  	task_lock(task);
> >  	freezer = task_freezer(task);
> >  	if (!freezer->css.cgroup->parent)
> > @@ -60,6 +61,7 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
> >  	else
> >  		state = freezer->state;
> >  	task_unlock(task);
> > +	rcu_read_unlock();
> >  
> >  	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
> >  }
> 
> Hmm cgroup_attach_task() does hold task_lock() over setting
> tsk->cgroups, so doesn't that also pin the task to the cgroup and thus
> the cgroup itself?

So you are advocating for the rcu_dereference check including the
task lock, correct?

							Thanx, Paul
