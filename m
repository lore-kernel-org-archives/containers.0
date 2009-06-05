From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 5 Jun 2009 19:12:26 +0530
Message-ID: <661de9470906050642s7774d601l53e366c77ffa7475@mail.gmail.com>
References: <20090605030309.GA3872@in.ibm.com> <4A28A2AB.3060108@redhat.com>
	<20090605044946.GA11755@balbir.in.ibm.com>
	<20090605051050.GB11755@balbir.in.ibm.com>
	<4A28AB67.7040800@redhat.com>
	<20090605052755.GE11755@balbir.in.ibm.com>
	<20090605053159.GB3872@in.ibm.com> <4A28B4CE.4010004@redhat.com>
	<20090605093947.GJ11755@balbir.in.ibm.com>
	<4A291A2F.3090201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A291A2F.3090201-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Fri, Jun 5, 2009 at 6:44 PM, Avi Kivity<avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Balbir Singh wrote:
>>>
>>> That's the limit part. =A0I'd like to be able to specify limits and
>>> =A0guarantees on the same host and for the same groups; I don't think t=
hat
>>> =A0works when you advance the bandwidth period.
>>>
>>
>> Yes, this feature needs to be configurable. But your use case for both
>> limits and guarantees is interesting. We spoke to Peter and he was
>> convinced only of the guarantee use case. Could you please help
>> elaborate your use case, so that we can incorporate it into RFC v2 we
>> send out. Peter is opposed to having hard limits and is convinced that
>> they are not generally useful, so far I seen you and Paul say it is
>> useful, any arguments you have or any +1 from you will help us. Peter
>> I am not back stabbing you :)
>>
>
> I am selling virtual private servers. =A0A 10% cpu share costs $x/month, =
and I
> guarantee you'll get that 10%, or your money back. =A0On the other hand, I
> want to limit cpu usage to that 10% (maybe a little more) so people don't
> buy 10% shares and use 100% on my underutilized servers. =A0If they want =
100%,
> let them pay for 100%.

Excellent examples, we've covered them in the RFC, could you see if we
missed anything in terms of use cases? The real question is do we care
enough to build hard limits control into the CFS group scheduler. I
believe we should.

>
>>> I think we need to treat guarantees as first-class goals, not something
>>> =A0derived from limits (in fact I think guarantees are more useful as t=
hey
>>> =A0can be used to provide SLAs).
>>>
>>
>> Even limits are useful for SLA's since your b/w available changes
>> quite drastically as we add or remove groups. There are other use
>> cases for limits as well
>
> SLAs are specified in terms of guarantees on a service, not on limits on
> others. =A0If we could use limits to provide guarantees, that would be fi=
ne,
> but it doesn't quite work out.

To be honest, I would disagree here, specifically if you start
comparing how you would build guarantees in the kernel and compare it
with the proposed approach. I don't want to harp on the technicality,
but point out the feasibility for people who care for lower end of the
guarantee without requiring density. I think the real technical
discussion should be on here are the use cases, lets agree on the need
for the feature and go ahead and start prototyping the feature.

Thanks,
Balbir
