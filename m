From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/5] freezer cgroup: Fix an RCU warning in
 cgroup_freezing_or_frozen()
Date: Thu, 22 Apr 2010 22:08:55 +0200
Message-ID: <1271966935.1646.4.camel@laptop>
References: <4BD016F4.8060108@cn.fujitsu.com>
	 <4BD01768.2020606@cn.fujitsu.com> <1271939275.1776.345.camel@laptop>
	 <20100422195911.GN2524@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100422195911.GN2524@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <clg@vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Thu, 2010-04-22 at 12:59 -0700, Paul E. McKenney wrote:
> On Thu, Apr 22, 2010 at 02:27:55PM +0200, Peter Zijlstra wrote:
> > On Thu, 2010-04-22 at 17:31 +0800, Li Zefan wrote:
> > > with CONFIG_PROVE_RCU, a warning can be triggered when we
> > > resume from suspend:
> > > 
> > > ...
> > > include/linux/cgroup.h:533 invoked rcu_dereference_check() without protection!
> > > ...
> > > 
> > > task_freezer() calls task_subsys_state(), which needs to be
> > > protected by rcu_read_lock or cgroup_mutex.
> > > 
> > > Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> > > ---
> > >  kernel/cgroup_freezer.c |    2 ++
> > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> > > index 5038f4c..ac76983 100644
> > > --- a/kernel/cgroup_freezer.c
> > > +++ b/kernel/cgroup_freezer.c
> > > @@ -53,6 +53,7 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
> > >  	struct freezer *freezer;
> > >  	enum freezer_state state;
> > >  
> > > +	rcu_read_lock();
> > >  	task_lock(task);
> > >  	freezer = task_freezer(task);
> > >  	if (!freezer->css.cgroup->parent)
> > > @@ -60,6 +61,7 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
> > >  	else
> > >  		state = freezer->state;
> > >  	task_unlock(task);
> > > +	rcu_read_unlock();
> > >  
> > >  	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
> > >  }
> > 
> > Hmm cgroup_attach_task() does hold task_lock() over setting
> > tsk->cgroups, so doesn't that also pin the task to the cgroup and thus
> > the cgroup itself?
> 
> So you are advocating for the rcu_dereference check including the
> task lock, correct?

I think that might be correct yes, although I would prefer confirmation
from someone who actually knows kernel/cgroup.c ;-)
