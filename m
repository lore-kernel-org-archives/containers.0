From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 0/9] cgroups: add res_counter_write_u64() API
Date: Fri, 20 Dec 2013 21:13:17 +0000
Message-ID: <20131220211317.GA361@mail.hallyn.com>
References: <1386884118-14972-1-git-send-email-dwight.engen@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1386884118-14972-1-git-send-email-dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dwight Engen (dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
> Hello,
> 
> I've seen that some sort of fork/task limiter has been proposed and
> discussed several times before. Despite the existance of kmem in memcg, a
> fork limiter is still often asked for by container users. Perhaps this is
> due to current granularity in kmem (ie. stack/struct task not split out from
> other slab allocations) but I believe it is just more natural for users to
> express a limit in terms of tasks.

Sorry, I thought I had replied to this.  I'm in support of this patchset,
and think you'd be better served just sending it to lkml.

Unfortunately I will be out for most of the rest of the year, but
please cc: me here and I'll do what I can to support you.

Assuming you've run ltp with and without your patchset and saw no
change in behavior, you should mention that here as well.

> So what I've done is updated Frederic Weisbecker's task counter patchset and
> tried to address the concerns that I saw people had raised. This involved
> the following changes:
> 
> - merged into cpuacct controller, as it seems there is a desire not to add
>   new controllers, this controller is already heirarchical, and I feel
>   limiting number of tasks/forks fits best here
> - included a fork_limit similar to the one Max Kellermann posted
>   (https://lkml.org/lkml/2011/2/17/116) which is a use case not addressable
>   with memcg
> - ala memcg kmem, for performance reasons don't account unless limit is set
> - ala memcg, allow usage to roll up to root (prevents warnings on
>   uncharge), but still don't allow setting limits in root
> - changed the interface at fork()/exit(), adding
>   can_fork()/cancel_can_fork() modeled on can_attach(). cgroup_fork()
>   can now return failure to fork().
> - ran Frederics selftests, and added a couple more
> 
> I also wrote a small fork micro benchmark to see how this change affected
> performance. I did 20 runs of 100000 fork/exit/waitpid, and took the
> average. Times are in seconds, base is without the change, cpuacct1 is with
> the change but no accounting be done (ie. no limit set), and cpuacct2 is
> with the test being in a cgroup 1 level deep.
> 
> base  cpuacct1  cpuaac2
> 5.59  5.59      5.64
> 
> So I believe this change has minimal performance impact, especially when no
> limit is set.
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
