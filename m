From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH UPDATED AGAIN 03/10] threadgroup: extend
	threadgroup_lock() to cover exit and exec
Date: Sat, 10 Dec 2011 00:42:53 +0100
Message-ID: <20111209234246.GC27173@somewhere>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
	<20111125140136.GC23307@somewhere.redhat.com>
	<20111127193001.GC4266@google.com>
	<20111202162753.GA19752@somewhere.redhat.com>
	<20111205184315.GJ627@google.com>
	<20111207153046.GC13252@somewhere.redhat.com>
	<20111207182214.GA7610@google.com>
	<20111208205055.GB12108@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111208205055.GB12108-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Dec 08, 2011 at 12:50:55PM -0800, Tejun Heo wrote:
> (Note for Linus at the bottom)
> 
> threadgroup_lock() protected only protected against new addition to
> the threadgroup, which was inherently somewhat incomplete and
> problematic for its only user cgroup.  On-going migration could race
> against exec and exit leading to interesting problems - the symmetry
> between various attach methods, task exiting during method execution,
> ->exit() racing against attach methods, migrating task switching basic
> properties during exec and so on.
> 
> This patch extends threadgroup_lock() such that it protects against
> all three threadgroup altering operations - fork, exit and exec.  For
> exit, threadgroup_change_begin/end() calls are added to exit_signals
> around assertion of PF_EXITING.  For exec, threadgroup_[un]lock() are
> updated to also grab and release cred_guard_mutex.
> 
> With this change, threadgroup_lock() guarantees that the target
> threadgroup will remain stable - no new task will be added, no new
> PF_EXITING will be set and exec won't happen.
> 
> The next patch will update cgroup so that it can take full advantage
> of this change.
> 
> -v2: beefed up comment as suggested by Frederic.
> 
> -v3: narrowed scope of protection in exit path as suggested by
>      Frederic.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ---
> Okay, narrowed exit path protection down to setting of PF_EXITING
> itself.  ->exit() on dangling tasks is a bit weird but I don't think
> it's too bad.  Frederic, are you okay with this version?

Yeah that new scheme that only protects PF_EXITING may look a bit
strange. But I think we are fine. With rcu list traversal, it should
be safe even if a group member is concurrently dropped from the list (in that
case all we check if its PF_EXITING then we give up). And we may
have a concurrent ->exit() but that should be fine too.

Thanks!

Acked-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> 
> Linus, if Frederic is okay with it, I'm gonna rebase the series on top
> of freezer changes in pm tree to avoid conflicts in cgroup_freezer,
> which sits between cgroup and freezer, both of which are going through
> non-trivial changes, push the branch to linux-next and put pending
> cgroup patches on top.  Please scream if you're mighty unhappy with it
> or have a better idea.
> 
> Thank you.
