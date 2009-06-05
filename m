From: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 05 Jun 2009 09:01:50 +0300
Message-ID: <4A28B4CE.4010004__24262.9453111023$1244181859$gmane$org@redhat.com>
References: <20090604053649.GA3701@in.ibm.com> <4A27BBCA.5020606@redhat.com>
	<20090605030309.GA3872@in.ibm.com> <4A28921C.6010802@redhat.com>
	<661de9470906042137u603e2997n80c270bf7f6191ad@mail.gmail.com>
	<4A28A2AB.3060108@redhat.com>
	<20090605044946.GA11755@balbir.in.ibm.com>
	<20090605051050.GB11755@balbir.in.ibm.com>
	<4A28AB67.7040800@redhat.com>
	<20090605052755.GE11755@balbir.in.ibm.com>
	<20090605053159.GB3872@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605053159.GB3872-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Bharata B Rao wrote:
> On Fri, Jun 05, 2009 at 01:27:55PM +0800, Balbir Singh wrote:
>   
>> * Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-06-05 08:21:43]:
>>
>>     
>>> Balbir Singh wrote:
>>>       
>>>>> But then there is no other way to make a *guarantee*, guarantees come
>>>>> at a cost of idling resources, no? Can you show me any other
>>>>> combination that will provide the guarantee and without idling the
>>>>> system for the specified guarantees?
>>>>>     
>>>>>           
>>>> OK, I see part of your concern, but I think we could do some
>>>> optimizations during design. For example if all groups have reached
>>>> their hard-limit and the system is idle, should we do start a new hard
>>>> limit interval and restart, so that idleness can be removed. Would
>>>> that be an acceptable design point?
>>>>         
>>> I think so.  Given guarantees G1..Gn (0 <= Gi <= 1; sum(Gi) <= 1), and a  
>>> cpu hog running in each group, how would the algorithm divide resources?
>>>
>>>       
>> As per the matrix calculation, but as soon as we reach an idle point,
>> we redistribute the b/w and start a new quantum so to speak, where all
>> groups are charged up to their hard limits.
>>     
>
> But could there be client models where you are required to strictly
> adhere to the limit within the bandwidth and not provide more (by advancing
> the bandwidth period) in the presence of idle cycles ?
>   

That's the limit part.  I'd like to be able to specify limits and 
guarantees on the same host and for the same groups; I don't think that 
works when you advance the bandwidth period.

I think we need to treat guarantees as first-class goals, not something 
derived from limits (in fact I think guarantees are more useful as they 
can be used to provide SLAs).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
