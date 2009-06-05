From: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 05 Jun 2009 16:14:23 +0300
Message-ID: <4A291A2F.3090201__5800.43171435154$1244208188$gmane$org@redhat.com>
References: <20090605030309.GA3872@in.ibm.com> <4A28921C.6010802@redhat.com>
	<661de9470906042137u603e2997n80c270bf7f6191ad@mail.gmail.com>
	<4A28A2AB.3060108@redhat.com>
	<20090605044946.GA11755@balbir.in.ibm.com>
	<20090605051050.GB11755@balbir.in.ibm.com>
	<4A28AB67.7040800@redhat.com>
	<20090605052755.GE11755@balbir.in.ibm.com>
	<20090605053159.GB3872@in.ibm.com> <4A28B4CE.4010004@redhat.com>
	<20090605093947.GJ11755@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605093947.GJ11755-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
>> That's the limit part.  I'd like to be able to specify limits and  
>> guarantees on the same host and for the same groups; I don't think that  
>> works when you advance the bandwidth period.
>>     
>
> Yes, this feature needs to be configurable. But your use case for both
> limits and guarantees is interesting. We spoke to Peter and he was
> convinced only of the guarantee use case. Could you please help
> elaborate your use case, so that we can incorporate it into RFC v2 we
> send out. Peter is opposed to having hard limits and is convinced that
> they are not generally useful, so far I seen you and Paul say it is
> useful, any arguments you have or any +1 from you will help us. Peter
> I am not back stabbing you :)
>   

I am selling virtual private servers.  A 10% cpu share costs $x/month, 
and I guarantee you'll get that 10%, or your money back.  On the other 
hand, I want to limit cpu usage to that 10% (maybe a little more) so 
people don't buy 10% shares and use 100% on my underutilized servers.  
If they want 100%, let them pay for 100%.

>> I think we need to treat guarantees as first-class goals, not something  
>> derived from limits (in fact I think guarantees are more useful as they  
>> can be used to provide SLAs).
>>     
>
> Even limits are useful for SLA's since your b/w available changes
> quite drastically as we add or remove groups. There are other use
> cases for limits as well

SLAs are specified in terms of guarantees on a service, not on limits on 
others.  If we could use limits to provide guarantees, that would be 
fine, but it doesn't quite work out.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
