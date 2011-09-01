From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 6/6] cgroup: kill subsys->can_attach_task(), pre_attach()
	and attach_task()
Date: Thu, 1 Sep 2011 14:58:24 +0200
Message-ID: <20110901125822.GB24650__30195.0942179703$1314929399$gmane$org@somewhere.redhat.com>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<1314312192-26885-7-git-send-email-tj@kernel.org>
	<20110830201030.GC15953@somewhere.redhat.com>
	<20110831070313.GA29179@mtj.dyndns.org>
	<20110831134220.GB20598@somewhere>
	<20110901112221.GA2752@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110901112221.GA2752-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Sep 01, 2011 at 08:22:21PM +0900, Tejun Heo wrote:
> Hello,
> 
> On Wed, Aug 31, 2011 at 03:42:24PM +0200, Frederic Weisbecker wrote:
> > My task counter subsystem patchset brings a cancel_attach_task() callback
> > that cancels can_attach_task() effects.
> > 
> > I thought that rebased on top of your patch it's going to be merged inside
> > cancel_attach() but OTOH we can't cancel the effect of failed migration
> > on a thread that way.
> > 
> > May be we need to keep a cancel_attach_task() just for that purpose?
> 
> We can do that but I think that becomes a bit too complex and fragile.
> That path won't be traveled unless it races against exit.  Bugs will
> be difficult to detect and reproduce.  In this respect, the current
> code already seems racy.  ->can_attach (or other methods in the attach
> path) and ->exit can race each other and I don't think all subsystems
> handle that properly.

I guess subsystems don't care about that currently, although I haven't
checked. But the task counter will need this per thread cancellation in
migration failure, without the need for any synchronization between
can_attach, attach and exit.

Now if we want to solve this with a synchronization there, either
we task_lock() every tasks in the group in the beginning of cgroup_attach_proc().
But that's not very nice. Or we use cgroup_mutex on cgroup_exit() exit,
but that's even worse.

I guess we need the leader->sighand->siglock on both cgroup_attach_proc()
and cgroup_exit(). Besides we may have more reasons to have that:

https://lkml.org/lkml/2011/8/15/342

> 
> IMHO the right thing to do here is simplifying synchronization rules
> so that nothing else happens while migration is in progress.
> 
> Thanks.
> 
> -- 
> tejun
