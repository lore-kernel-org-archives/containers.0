From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup: implement cgroup.subtree_populated for the
	default hierarchy
Date: Thu, 10 Apr 2014 10:19:57 -0400
Message-ID: <20140410141957.GE25308@htj.dyndns.org>
References: <1397056052-2829-1-git-send-email-tj@kernel.org>
	<1397056052-2829-4-git-send-email-tj@kernel.org>
	<20140410030855.GA29658@mail.hallyn.com>
	<20140410130831.GA25308@htj.dyndns.org>
	<20140410140424.GA4481@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140410140424.GA4481@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Thu, Apr 10, 2014 at 09:04:24AM -0500, Serge Hallyn wrote:
> Except for the keeping state.  If the userspace agent crashes when it
> was meant to drop 100 cgroups when they become empty, then when it
> restarts those 100 cgroups may never be freed.  Of course userspace
> can do things about this, but it just seems like it would be so
> trivial to handle this case in the kernel.  Like you say there is

But it's also trivial from userland.  You can write up a separate
backup agent or just make the main agent perform cleanup on restart,
which it should probably be doing anyway.

> no need for all the fancy agent spawning - just notice that the
> cgroup became empty, that releaseonempty was true, and so unlink the
> thing.  It'll be freed when anyone who has it held open closes it.

It'd be a superflous feature which require a separate control knob on
each cgroup and can lead to confusion too as there are now two
entities acting on it by default.  The manager has to worry about
keeping those knobs in sync and deal with cases where cgroups
disappear unexpectedly.  Think about it.  What should the default
value of the knob be?  What if the manager crashes before setting up
the knob to its desired state?  It needs to perform a cleanup pass
after crash *anyway*.  How is it gonna synchronize with the current
state of cgroup hierarchy otherwise?

It's adding complexity without any actual benefits.  This is kernel
API.  It should be concise and orthogonal where it can be.  There of
course are cases where convenience should be considered but what
you're suggesting doesn't seem beneficial in any substantial way.

> > The case where you move a task out of x1/y1 to another cgroup doesn't
> > generate an event.  One could say that that's unnecessary because the
> 
> Still confused.
> 
> If I create x1/y1 and x3/y3, set notify_on_release on x1 and x1/y1,
> move a task into x1/y1, then move it to x3/y3, then x1/y1 and x1 both
> do get removed.

Ah, you're right, cgroup_task_migrate() sets CGRP_RELEASABLE
explicitly.  I was confused because put_css_set_locked() sets
CGRP_RELEASABLE only if @taskexit is set.  Will drop that part from
the description.

Thanks.

-- 
tejun
