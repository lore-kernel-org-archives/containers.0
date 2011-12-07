From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH UPDATED 03/10] threadgroup: extend threadgroup_lock()
	to cover exit and exec
Date: Wed, 7 Dec 2011 10:22:14 -0800
Message-ID: <20111207182214.GA7610__41067.0910416686$1323282159$gmane$org@google.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
	<20111125140136.GC23307@somewhere.redhat.com>
	<20111127193001.GC4266@google.com>
	<20111202162753.GA19752@somewhere.redhat.com>
	<20111205184315.GJ627@google.com>
	<20111207153046.GC13252@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111207153046.GC13252-oHC15RC7JGTpAmv0O++HtFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Frederic.

On Wed, Dec 07, 2011 at 04:30:54PM +0100, Frederic Weisbecker wrote:
> I don't understand what you mean. On your patches, you only process tasks
> that don't have PF_EXITING, ie: you don't include these in the flex array
> on cgroup_attach_proc(). So that still applies in my proposal.
> 
> From the exit path we would have:
> 
> 	exit_signal() {
> 		lock_threadgroup_change(task);
> 		task->flags |= PF_EXITING;
> 		lock_threadgroup(task);
> 	}
> 
> 	exit all the rest: mm, etc...
> 
> Then from cgroup_attach_proc():
> 
> 	lock_threadgroup(task);
> 	for_each_thread(task) {
> 		if (!(task->flags & PF_EXITING))
> 			include in flex array
> 	}
> 
> Am I forgetting something?

The point I was trying to make was that doing the above would make
->exit() called on dangling task of a threadgroup in rare cases.
ie. With the proposed change, after a threadgroup migration, all tasks
in the threadgroup is in the new cgroup.  No method will be called on
the old cgroup for any of the member task.  With the above change,
process migration would leave out dying tasks and ->exit() can be
called with the old cgroup.

Hmm... that said, it probably doesn't matter all that much either way.
I'll update the patchset and repost.

Thanks.

-- 
tejun
