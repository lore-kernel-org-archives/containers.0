From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/11] blkcg: implement per-blkg request allocation
Date: Fri, 27 Apr 2012 09:20:12 -0700
Message-ID: <20120427162012.GP27486@google.com>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
	<1335477561-11131-12-git-send-email-tj@kernel.org>
	<x49wr51usxi.fsf@segfault.boston.devel.redhat.com>
	<20120427150217.GK27486@google.com>
	<20120427154033.GJ10579@redhat.com>
	<20120427154502.GM27486@google.com>
	<20120427154841.GA16237@redhat.com>
	<20120427155140.GN27486@google.com>
	<20120427155612.GK10579@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120427155612.GK10579-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Apr 27, 2012 at 11:56:12AM -0400, Vivek Goyal wrote:
> > I find allowing unpriv users creating cgroups dumb.  cgroup consumes
> > kernel memory.  Sans using kmemcg, what prevents them from creating
> > gazillion cgroups and consuming all memories?  The idea of allowing
> > cgroups to !priv users is just broken from the get go.
> 
> Well creating a task consumes memory too but we allow unpriv users to
> create tasks. :-)

We have ulimit.

> May be a system wide cgroup limit will make sense?

IMHO, this was one of the larger mistakes cgroup has made.  There are
two ways when building interface for admin stuff like this, you can
either implement and expose the core functionality and let userland
deal with distribution or build things such that the kernel can fully
virtualize and distribute the control to each process.  Both
approaches have their pros and cons but I generally think it's better
to go for the latter for new and extra stuff like cgroup as it is much
simpler and tends to more flexible and adapts better as use cases
develop.

The problem with cgroup is that it's neither the former or the latter.
It's caught somewhere in the middle with its pants down where it does
half-assed job of providing an interface which looks like it could be
made to be directly accessible from !priv processes while not really
being able to handle such usage.

I mean, just think about the case you just raised.  Forget about
memory usage.  What about weights?  If you allow a random user to
create arbitrary number of blkcg groups, [s]he gets 500 extra weight
with each blkcg!  Yeah!

If we support full hierarchy on all controllers, exposing cgroups
directly to !priv users may start to make more sense but I'd much
prefer having resource policy controlled and administered centrally in
userland.  It's a job much better suited for userland.  If such
mechanism would require certain features, sure we can accomodate that
but I think trying to allow !priv users directly to cgroup is stupid
especially at this point, so let's just drop it.

Thanks.

-- 
tejun
