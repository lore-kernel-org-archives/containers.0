From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v4 2/2] cgroups: make procs file writable
Date: Wed, 4 Aug 2010 00:38:49 -0400
Message-ID: <20100804043849.GC11950@ghc17.ghc.andrew.cmu.edu>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100730235902.GC22644@ghc17.ghc.andrew.cmu.edu>
	<20100804100811.199d73ba.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikMofFGHSwF2QrdcAsit+hU6ihndhK5cod8duwS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikMofFGHSwF2QrdcAsit+hU6ihndhK5cod8duwS-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 03, 2010 at 09:30:00PM -0700, Paul Menage wrote:
> >> --- a/kernel/cpuset.c
> >> +++ b/kernel/cpuset.c
> >> @@ -1404,6 +1404,10 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
> >> ? ? ? ? ? ? ? struct task_struct *c;
> >>
> >> ? ? ? ? ? ? ? rcu_read_lock();
> >> + ? ? ? ? ? ? if (!thread_group_leader(tsk)) {
> >> + ? ? ? ? ? ? ? ? ? ? rcu_read_unlock();
> >> + ? ? ? ? ? ? ? ? ? ? return -EAGAIN;
> >> + ? ? ? ? ? ? }
> 
> Why are you adding this requirement, here and in sched.c? (ns_cgroup.c
> doesn't matter since it's being deleted).
> 
> Paul

It was either this or:

rcu_read_lock();
for_each_subsys(...) {
	can_attach(...);
}
rcu_read_unlock();

Which forces all can_attaches to not sleep. So by dropping
rcu_read_lock(), we allow the possibility of the exec race I described
in my last email, and therefore we have to check each time we re-acquire
rcu_read to iterate thread_group.

Yeah, it is not pretty. I call it "double-double-toil-and-trouble-check
locking". But it is safe.

-- Ben
