From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Fri, 13 Apr 2012 10:42:24 +0900
Message-ID: <4F878480.60505__12556.9696109325$1334281470$gmane$org@jp.fujitsu.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
	<20120412163825.GB13069@google.com>
	<20120412172309.GM1787@cmpxchg.org>
	<20120412174155.GC13069@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120412174155.GC13069-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

(2012/04/13 2:41), Tejun Heo wrote:

> Hello, Johannes.

> I'm still split on the issue.
> 
> * #tasks as unit of accounting / limiting is well understood (or at
>   least known).  I think this holds the same to #open files, to a
>   lesser extent.  It means there are and will continue to be people
>   wanting them.  So, they have some value in familiarity - "but... I
>   want to limit the resources consumed by tasks cuz that's what I
>   know!" factor.
> 
> * People could want counting and limiting #tasks or #open files
>   without the overhead of tracking all memory resources.  This stems
>   from the same reason #tasks was used for this sort of things in the
>   first place.  Counting tasks or open files tends to be easier and
>   cheaper than tracking all memory allocations.
> 
> So, there's spectrum of solutions between merging task counter and
> just directing everyone to kmem without distinguishing task resource
> at all, and at the moment voices in my head are succeeding at making
> cases for both directions.  What do you guys think about the above two
> issues?
> 


To be honest, I doubt that task counter is unnecessary...memcg can catch
oom situation well. I often test 'make -j' under memcg.

To the questions
*   It sounds like a 'ulimit' cgroup. How about overwriting
    ulimit values via cgroup ? (sounds joke?) Then, overhead will be small but
    I'm not sure it can be hierarchical and doesn't break userland.

    If people wants to limit the number of tasks, I think interface should provide it
    in the unit of objects. Then, I'm ok to have other subsystem for counting something.
    fork-bomb's memory overhead can be prevent by memcg. What memcg cannot handle
    is ulimit. If forkbomb exhausts all ulimit/tasks, the user cannot login.
    So, having task-limit cgroup subsys for a sandbox will make sense in some situation.

In short, I don't think it's better to have task-counting and fd-counting in memcg.
It's kmem, but it's more than that, I think.
Please provide subsys like ulimit.

Thanks,
-Kame
