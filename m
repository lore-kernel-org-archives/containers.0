From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: A strange behavior of sched_fair
Date: Thu, 28 Feb 2008 23:08:20 -0800
Message-ID: <20080228230820.22ad38b3.akpm@linux-foundation.org>
References: <47C5E977.2010401@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47C5E977.2010401-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kei Tokunaga <tokunaga.keiich-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


(cc containers list)

On Wed, 27 Feb 2008 17:51:35 -0500 Kei Tokunaga <tokunaga.keiich-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:

> Hi Ingo,
> 
> I am playing around with sched_fair and cgroup, and it seems like
> I hit a possible bug.  Could you also check if that is a bug?
> 
> Description of behavior:
>    Start a cpu-bound task (t1), attach it to a cgroup (cgA), and let the
>    task to run for a while (e.g. several tens of seconds or a couple of
>    minutes would be adequate.)  Then, start another cpu-bound task (t2)
>    and attach it to cgA in the way described in "Steps to Reproduce" section.
>    You will see t1 does not get run for a while.
>    (The tasks may not have to be cpu-bound, but it is easier to see the
>     behavior using cpu-bound tasks.)
> 
> How reproducible:
>    Always.
> 
> Environments where I saw the behavior:
>    2.6.25-rc3 with resource management functions enabled on ia64 box.
> 
> Steps to Reproduce:
>    # mkdir /dev/cgroup
>    # mount -t cgroup -ocpuset,cpu cpu /dev/cgroup
>    # mkdir /dev/cgroup/{a,b}
>    # echo 0 > /dev/cgroup/a/cpuset.cpus
>    # echo 0 > /dev/cgroup/b/cpuset.cpus
>    # echo 1 > /dev/cgroup/a/cpuset.mems
>    # echo 1 > /dev/cgroup/b/cpuset.mems
>    # echo $$ > /dev/cgroup/b/tasks
>    # ./a.out & echo $! > /dev/cgroup/a/tasks (a.out is just a for-loop program)
>      [Wait for several tens of seconds or a couple of minutes.]
>    # ./a.out2 & echo $! > /dev/cgroup/a/tasks (a.out2 is just a for-loop program)
>      [You will see a.out does not get run for a while by running top command.]
> 
> Additional Info:
>    a.out2 needs to be started from the shell of cgroup-b in order to
>    reproduce the problem (, unless the system is UP.)  Starting a.out2
>    in the manner, se->vruntime (or something to create the se->vruntime)
>    of a.out2 seems to be initialized to a small value, compared to the
>    value of a.out.  And the fair scheduler only runs a.out2 until the
>    se->vruntime catches up with the se->vruntime of a.out.
> 
> Thanks,
> Kei
> --
> Kei Tokunaga
> Fujitsu (Red Hat On-site Partner)
