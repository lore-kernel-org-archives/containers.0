From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Mon, 08 Jun 2009 12:50:51 +0400
Message-ID: <4A2CD0EB.5080900__4696.23553003675$1244451129$gmane$org@openvz.org>
References: <20090604053649.GA3701@in.ibm.com>	
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>	
	<20090605092733.GA27486@in.ibm.com>	
	<6599ad830906050232n11aa30d8xfcda0a279a482f32@mail.gmail.com>	
	<20090605094811.GD4601@linux.vnet.ibm.com>	
	<6599ad830906050251h18f4e037h182f61aa80a5b046@mail.gmail.com>	
	<20090605095931.GE4601@linux.vnet.ibm.com>
	<6599ad830906050303r404c325anc60ded4f45a50b95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830906050303r404c325anc60ded4f45a50b95-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Fri, Jun 5, 2009 at 2:59 AM, Dhaval Giani<dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> I think we are focusing on the wrong use case here. Guarantees is just a
>> useful side-effect we get by using hard limits. I think the more
>> important use case is where the provider wants to limit the amount of
>> time a user gets (such as in a cloud).
>>
>> Maybe we should direct our attention in solving that problem? :)
>>
> 
> Yes, that case and the "predictable load test behaviour" case are both
> good reasons for hard limits.

ACK.

I'd like to add two things.

First, the article @openvz.org about guarantees you were discussing was 
not supposed to be a "best practices" paper. This was just a theoretical
thoughts on how to get guarantees out of the limit for those resources 
you cannot reclaim from the user and thus cannot provide the guarantee 
any other way. E.g. locked memory - once a user has it you cannot take 
it back, and if you want to guarantee some mount of it for group X you
have to keep all the other groups away from this amount.

And the second thing is an addition for Dhaval's case about limiting the 
amount of time a user gets. This is exactly what hosting providers do -
they _sell_ the CPU power to their customers and thus need to limit the
CPU time dedicated for containers.

> Paul
> 
