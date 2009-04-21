From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/7] io-throttle controller infrastructure
Date: Tue, 21 Apr 2009 14:58:30 +0200
Message-ID: <20090421125829.GD13699__39204.4614455246$1240319035$gmane$org@linux>
References: <1240090712-1058-1-git-send-email-righi.andrea@gmail.com>
	<1240090712-1058-5-git-send-email-righi.andrea@gmail.com>
	<20090420175904.GD6822@linux.vnet.ibm.com>
	<20090420212225.GA5819@linux>
	<20090421041524.GB6939@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421041524.GB6939-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 20, 2009 at 09:15:24PM -0700, Paul E. McKenney wrote:
> > > How does the above lock relate to the iot->lock called out in the comment
> > > headers in the earlier functions?  Hmmm...  Come to think of it, I don't
> > > see an acquisition of iot->lock anywhere.
> > > 
> > > So, what is the story here?
> > 
> > As said before, only the comment in struct iothrottle is correct, we use
> > cgroup_lock() to protect iot->list, so there's no need to introduce
> > another lock inside struct iothrottle.
> > 
> > And the other comments about iot->lock must be fixed.
> 
> Sounds good!
> 
> So this code is compiled into the kernel only when cgroups are defined,
> correct?  Otherwise, cgroup_lock() seems to be an empty function.

Right, from init/Kconfig:

config CGROUP_IO_THROTTLE
        bool "Enable cgroup I/O throttling"
        depends on CGROUPS && RESOURCE_COUNTERS && EXPERIMENTAL
...

> > > > +int iothrottle_set_page_owner(struct page *page, struct mm_struct *mm)
> > > > +{
> > > > +	struct iothrottle *iot;
> > > > +	unsigned short id = 0;
> > > > +
> > > > +	if (iothrottle_disabled())
> > > > +		return 0;
> > > > +	if (!mm)
> > > > +		goto out;
> > > > +	rcu_read_lock();
> > > > +	iot = task_to_iothrottle(rcu_dereference(mm->owner));
> > > 
> > > Given that task_to_iothrottle() calls task_subsys_state(), which contains
> > > an rcu_dereference(), why is the rcu_dereference() above required?
> > > (There might well be a good reason, just cannot see it right offhand.)
> > 
> > The first rcu_dereference() is required to safely get a task_struct from
> > mm_struct. The second rcu_dereference() inside task_to_iothrottle() is
> > required to safely get the struct iothrottle from task_struct.
> 
> Why not put the rcu_dereference() down inside task_to_iothrottle()?
> 

mmmh... it is needed only when task_struct is taken from mm->owner,
task_to_iothrottle(current) for example works fine without the
rcu_dereference(current).

-Andrea
