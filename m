From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
	cgroup removal
Date: Fri, 16 Mar 2012 09:02:23 +0900
Message-ID: <4F62830F.4060303@jp.fujitsu.com>
References: <20120312213155.GE23255@google.com>
	<20120312213343.GF23255@google.com>
	<20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com>
	<20120313163914.GD7349@google.com>
	<20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com>
	<4F6068F4.4090909@parallels.com> <4F6134E1.5090601@jp.fujitsu.com>
	<4F61D167.4000402@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4F61D167.4000402-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

(2012/03/15 20:24), Glauber Costa wrote:

> On 03/15/2012 04:16 AM, KAMEZAWA Hiroyuki wrote:
>> (2012/03/14 18:46), Glauber Costa wrote:
>>
>>> On 03/14/2012 04:28 AM, KAMEZAWA Hiroyuki wrote:
>>>> IIUC, in general, even in the processes are in a tree, in major case
>>>> of servers, their workloads are independent.
>>>> I think FLAT mode is the dafault. 'heararchical' is a crazy thing which
>>>> cannot be managed.
>>>
>>> Better pay attention to the current overall cgroups discussions being
>>> held by Tejun then. ([RFD] cgroup: about multiple hierarchies)
>>>
>>> The topic of whether of adapting all cgroups to be hierarchical by
>>> deafult is a recurring one.
>>>
>>> I personally think that it is not unachievable to make res_counters
>>> cheaper, therefore making this less of a problem.
>>>
>>
>>
>> I thought of this a little yesterday. Current my idea is applying following
>> rule for res_counter.
>>
>> 1. All res_counter is hierarchical. But behavior should be optimized.
>>
>> 2. If parent res_counter has UNLIMITED limit, 'usage' will not be propagated
>>    to its parent at _charge_.
> 
> That doesn't seem to make much sense. If you are unlimited, but your 
> parent is limited,
> he has a lot more interest to know about the charge than you do. 


Sorry, I should write "If all ancestors are umlimited'.
If parent is limited, the children should be treated as limited.

> So the 
> logic should rather be the opposite: Don't go around getting locks and 
> all that if you are unlimited. Your parent might, though.
> 
> I am trying to experiment a bit with billing to percpu counters for 
> unlimited res_counters. But their inexact nature is giving me quite a 
> headache.
> 


Personally, I think percpu counter is not the best one. Yes, it will work but...
Because of its nature of error range, it has scalability problem. Considering
to have a tree like

	/A/B/Guest0/tasks
             Guest1/tasks
             Guest2/tasks
             Guest4/tasks
             Guest5/tasks
             ......

percpu res_counter may work scarable in GuestX level but will conflict in level B.
And I don't want to think what happens in 256 cpu system. Error in B will be
very big.

Another idea is to borrow a resource from memcg to the tasks. i.e.having per-task
caching of charges. But it has two problems that draining unused resource is difficult
and precise usage is unknown.

IMHO, hard-limited resource counter itself may be a problem ;)

So, an idea, 'if all ancestors are unlimited, don't propagate charges.'
comes to my mind. With this, people use resource in FLAT (but has hierarchical cgroup
tree) will not see any performance problem.



>> 3. If a res_counter has UNLIMITED limit, at reading usage, it must visit
>>     all children and returns a sum of them.
>>
>> Then,
>> 	/cgroup/
>> 		memory/                       (unlimited)
>> 			libivirt/             (unlimited)
>> 				 qeumu/       (unlimited)
>> 				        guest/(limited)
>>
>> All dir can show hierarchical usage and the guest will not have
>> any lock contention at runtime.
> 
> If we are okay with summing it up at read time, we may as well
> keep everything in percpu counters at all times.
>


If all ancestors are unlimited, we don't need to propagate usage upwards
at charging. If one of ancestors are limited, we need to propagate and
check usage at charging.



>> By this
>>   1. no runtime overhead if the parent has unlimited limit.
>>   2. All res_counter can show aggregate resource usage of children.
>>
>> To do this
>>   1. res_coutner should have children list by itself.
>>
>> Implementation problem
>>   - What should happens when a user set new limit to a res_counter which have
>>     childrens ? Shouldn't we allow it ? Or take all locks of children and
>>     update in atomic ?
> Well, increasing the limit should be always possible.
> 


> As for the kids, how about:
> 
> - ) Take their locks
> - ) scan through them seeing if their usage is bellow the new allowance
>      -) if it is, then ok
>      -) if it is not, then try to reclaim (*). Fail if it is not possible.
> 
> (*) May be hard to implement, because we already have the res_counter 
> lock taken, and the code may get nasty. So maybe it is better just fail 
> if any of your kids usage is over the new allowance...
> 


Seems enough and seems worth to try.


> 
> 
>>   - memory.use_hierarchy should be obsolete ?
> If we're going fully hierarchical, yes.
> 

Another big problem is 'when' we should do this change..
Maybe this 'hierarchical' problem will be good topic in MM summit.

Thanks,
-Kame
