From: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 05 Jun 2009 07:44:27 +0300
Message-ID: <4A28A2AB.3060108__41522.8191334338$1244177278$gmane$org@redhat.com>
References: <20090604053649.GA3701@in.ibm.com> <4A27BBCA.5020606@redhat.com>	
	<20090605030309.GA3872@in.ibm.com> <4A28921C.6010802@redhat.com>
	<661de9470906042137u603e2997n80c270bf7f6191ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <661de9470906042137u603e2997n80c270bf7f6191ad-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> On Fri, Jun 5, 2009 at 11:33 AM, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>   
>> Bharata B Rao wrote:
>>     
>>>> Another way is to place the 8 groups in a container group, and limit
>>>>  that to 80%. But that doesn't work if I want to provide guarantees to
>>>>  several groups.
>>>>
>>>>         
>>> Hmm why not ? Reduce the guarantee of the container group and provide
>>> the same to additional groups ?
>>>
>>>       
>> This method produces suboptimal results:
>>
>> $ cgroup-limits 10 10 0
>> [50.0, 50.0, 40.0]
>>
>> I want to provide two 10% guaranteed groups and one best-effort group.
>>  Using the limits method, no group can now use more than 50% of the
>> resources.  However, having the first group use 90% of the resources does
>> not violate any guarantees, but it not allowed by the solution.
>>
>>     
>
> How, it works out fine in my calculation
>
> 50 + 40 for G2 and G3, make sure that G1 gets 10%, since others are
> limited to 90%
> 50 + 40 for G1 and G3, make sure that G2 gets 10%, since others are
> limited to 90%
> 50 + 50 for G1 and G2, make sure that G3 gets 0%, since others are
> limited to 100%
>   

It's fine in that it satisfies the guarantees, but it is deeply 
suboptimal.  If I ran a cpu hog in the first group, while the other two 
were idle, it would be limited to 50% cpu.  On the other hand, if it 
consumed all 100% cpu it would still satisfy the guarantees (as the 
other groups are idle).

The result is that in such a situation, wall clock time would double 
even though cpu resources are available.
> Now if we really have zeros, I would recommend using
>
> cgroup-limits 10 10 and you'll see that you'll get 90, 90 as output.
>
> Adding zeros to the calcuation is not recommended. Does that help?

What do you mean, it is not recommended? I have two groups which need at 
least 10% and one which does not need any guarantee, how do I express it?

In any case, changing the zero to 1% does not materially change the results.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
