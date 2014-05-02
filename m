From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.15] cgroup: implement unified hierarchy
Date: Fri, 2 May 2014 11:12:50 -0400
Message-ID: <20140502151250.GB10204@htj.dyndns.org>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
	<20140414154556.GA9552@redhat.com>
	<20140414175236.GB15249@htj.dyndns.org>
	<CAC4Lta0qd2vW4ENSOpzK+0i06MorzfmsZZZuW9xUtpZ_gWA9gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAC4Lta0qd2vW4ENSOpzK+0i06MorzfmsZZZuW9xUtpZ_gWA9gA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Raghavendra KT <raghavendra.kt-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Wed, Apr 30, 2014 at 04:27:51PM +0530, Raghavendra KT wrote:
> For some controllers like cpuset, when we have exclusive_cpu is set,
> what about having a knob in the cpuset controller
> to move the task to non-root (when option is set).

I'm doubtful.

> Because all the way along, though we have freedom to make the cpusets
> exclusive and move tasks (say VMs) into them,
> making sure they do not interfere with each other, we can not prevent
> the other tasks spawned in a system eating into cpus of
> exclusive cpuset since they go to root automatically.

I believe the right thing to do would be starting / confining other
tasks in the appropriate non-root cgroups.  cgroup already provides
mechanisms to achieve that.  The rest is upto userland.

> Do you think having a knob, to make sure new tasks spawned go to say a
> default  directory under root makes sense?
> 
>  I understand that we could easily have a userspace script which could
> achieve intended goal, but kernel solution
>  would really make the exclusive cpusets have exclusive access to cpus
> it should have.

This would just be a more reliable implementation of an ad-hoc
mechanism when it can already be properly achieved by managing cgroups
of all processes in the system.

> (I also have a POC implemented for pre-unified hierarchy tree and
> understand some bit of complications involved in that and
> understand that we should not have complex policies in kernel for e.g.
> filtering tasks based on patterns etc..).

As I wrote above, I think this is something to be solved from
userland.  I'm very positively against adding this sort of hacky
ad-hoc policies which serves one or a few use cases well while
introducing possible long-term maintenance issues.

Thanks.

-- 
tejun
