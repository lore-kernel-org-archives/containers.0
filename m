From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [patch 1/4] io controller: documentation
Date: Fri, 7 Nov 2008 11:32:09 +0900
Message-ID: <20081107113209.a6011c67.kamezawa.hiroyu__45476.5216833495$1226025402$gmane$org@jp.fujitsu.com>
References: <20081106153022.215696930@redhat.com>
	<20081106153135.743458085@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081106153135.743458085-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Hirokazu-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Andrea-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 06 Nov 2008 10:30:23 -0500
vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
> +ISSUES
> +======
> +- IO controller can buffer the bios if suffcient tokens were not available
> +  at the time of bio submission. Once the tokens are available, these bios
> +  are dispatched to elevator/lower layers in first come first serve manner.
> +  And this has potential to break CFQ where a RT tasks should be able to
> +  dispatch the bio first or a high priority task should be able to release
> +  more bio as compared to low priority task in same cgroup.
> +
> +  Not sure how to fix it. May be we need to maintain another rb-tree and
> +  keep track of RT tasks and tasks priorities and dispatch accordingly. This
> +  is equivalent of duplicating lots of CFQ logic and not sure how would it
> +  impact AS behaviour.
> 
Why you don't isolate RT tasks into other cgroup ?
   /cgroup/bio-cgroup/group_for_usual/...usual tasks.
                     /group_for_RT/ ...RT tasks. you can use high-speed path.

How about adding RT flag to bio-cgroup and skip buffering at bio-cgroup if RT
flag is set ? I think handling an usual process and RT process in "a" cgroup
just makes the code complex.

Looking into a cpu-scheduler, which is the first module handling RT, it has
some tweaks to handle RT in the system.
 - special RT scheduler.
 - isolated RT domain
 - maximum execution time allowed to RT
 ....

Maybe handling RT in following way is usual way...(if we do something in this layer)

  - Allow RT-bio-cgroup to skip limit check.
  - But RT-bio-cgroup calculates io-throuput, execution time, statistics...
  - When RT tasks in RT-bio-cgroup does excessive I/O which starves the whole system
    too long, raise safeguard-limitter. and tell users Warning or kill it.

Hmm ?

Thanks,
-Kame
