From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 5 Jun 2009 13:20:14 +0800
Message-ID: <20090605052014.GD11755__23582.4156472974$1244179272$gmane$org@balbir.in.ibm.com>
References: <20090604053649.GA3701@in.ibm.com> <4A27BBCA.5020606@redhat.com>
	<20090605030309.GA3872@in.ibm.com> <4A28921C.6010802@redhat.com>
	<661de9470906042137u603e2997n80c270bf7f6191ad@mail.gmail.com>
	<4A28A2AB.3060108@redhat.com>
	<20090605044946.GA11755@balbir.in.ibm.com>
	<4A28AA25.4050206@redhat.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A28AA25.4050206-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

* Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-06-05 08:16:21]:

> Balbir Singh wrote:
>
>    
>
>>>> How, it works out fine in my calculation
>>>>
>>>> 50 + 40 for G2 and G3, make sure that G1 gets 10%, since others are
>>>> limited to 90%
>>>> 50 + 40 for G1 and G3, make sure that G2 gets 10%, since others are
>>>> limited to 90%
>>>> 50 + 50 for G1 and G2, make sure that G3 gets 0%, since others are
>>>> limited to 100%
>>>>         
>>> It's fine in that it satisfies the guarantees, but it is deeply   
>>> suboptimal.  If I ran a cpu hog in the first group, while the other 
>>> two  were idle, it would be limited to 50% cpu.  On the other hand, 
>>> if it  consumed all 100% cpu it would still satisfy the guarantees 
>>> (as the  other groups are idle).
>>>
>>> The result is that in such a situation, wall clock time would double  
>>> even though cpu resources are available.
>>>     
>>
>> But then there is no other way to make a *guarantee*, guarantees come
>> at a cost of idling resources, no? Can you show me any other
>> combination that will provide the guarantee and without idling the
>> system for the specified guarantees?
>>   
>
> Suppose in my example cgroup 1 consumed 100% of the cpu resources and  
> cgroup 2 and 3 were completely idle.  All of the guarantees are met (if  
> cgroup 2 is idle, there's no need to give it the 10% cpu time it is  
> guaranteed).
>
> If  your only tool to achieve the guarantees is a limit system, then  
> yes, the equation yields the correct results.  But given that it yields  
> such inferior results, I think we need to look for a more involved 
> solution.
>
> I think the limits method fits cases where it is difficult to evict a  
> resource (say, disk quotas -- if you want to guarantee 10% of space to  
> cgroups 1, you must limit all others to 90%).  But for processor usage,  
> you can evict a cgroup instantly, so nothing prevents a cgroup from  
> consuming all available resources as long as others do not contend for 
> them.

Avi,

Could you look at my newer email and comment, where I've mentioned
that I see your concern and discussed a design point. We could
probably take this discussion forward from there?

-- 
	Balbir
