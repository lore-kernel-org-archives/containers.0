From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Fri, 13 Apr 2012 11:48:28 +0900
Message-ID: <4F8793FC.5030209__44138.1408869804$1334285438$gmane$org@jp.fujitsu.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
	<20120412163825.GB13069@google.com>
	<20120412172309.GM1787@cmpxchg.org>
	<20120412174155.GC13069@google.com> <4F878480.60505@jp.fujitsu.com>
	<4F87865F.5060701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4F87865F.5060701-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

(2012/04/13 10:50), Glauber Costa wrote:

> On 04/12/2012 10:42 PM, KAMEZAWA Hiroyuki wrote:
>> To be honest, I doubt that task counter is unnecessary...memcg can catch
>> oom situation well. I often test 'make -j' under memcg.
>>
>> To the questions
>> *   It sounds like a 'ulimit' cgroup. How about overwriting
>>      ulimit values via cgroup ? (sounds joke?) Then, overhead will be small but
>>      I'm not sure it can be hierarchical and doesn't break userland.
>>
>>      If people wants to limit the number of tasks, I think interface should provide it
>>      in the unit of objects. Then, I'm ok to have other subsystem for counting something.
>>      fork-bomb's memory overhead can be prevent by memcg. What memcg cannot handle
>>      is ulimit. If forkbomb exhausts all ulimit/tasks, the user cannot login.
>>      So, having task-limit cgroup subsys for a sandbox will make sense in some situation.
>>
>> In short, I don't think it's better to have task-counting and fd-counting in memcg.
>> It's kmem, but it's more than that, I think.
>> Please provide subsys like ulimit.
>>
> Kame,
> 
> You're talking about the memcg that is in the kernel today.
> I think the discussion is orbiting around how it is going to be once we
> start tracking kernel memory like the slab (for task_struct), or kernel 
> stack pages.
> 
> In those scenarios, a fork bomb will be stopped anyway, because it will 
> need kernel memory it can't grab.
> 



fork-bomb can be caught by some method.


I just consider about 'task' cgroup. You can know the number of tasks by reading
tasks file even if we don't have task cgroup. Because of this, using
task cgroup for accounting the number of tasks doesn't make sense to me.
But, here, Tejun? mentioned accounting the number of 'fd'. 

Hearing that, I think of ulimit.

We do resource accounting based on cgroup. But there are another limiting
feature as ulimit, sysctl, etc...This makes total view of resource accounting in Linux
complicated. So, I wonder whether cgroup can be a unified control feature and have
subsys for ulimit or ipc, by overriding other control stuffs.

But  resources which doesn't belong to 'thread' ...as memory may add something
messy to cgroup, it's accounting resources based on threads.

Thanks,
-Kame
