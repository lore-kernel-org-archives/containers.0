From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 5 Jun 2009 15:29:31 +0530
Message-ID: <20090605095931.GE4601__41511.1407325186$1244196055$gmane$org@linux.vnet.ibm.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
	<20090605092733.GA27486@in.ibm.com>
	<6599ad830906050232n11aa30d8xfcda0a279a482f32@mail.gmail.com>
	<20090605094811.GD4601@linux.vnet.ibm.com>
	<6599ad830906050251h18f4e037h182f61aa80a5b046@mail.gmail.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830906050251h18f4e037h182f61aa80a5b046-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 05, 2009 at 02:51:18AM -0700, Paul Menage wrote:
> On Fri, Jun 5, 2009 at 2:48 AM, Dhaval Giani<dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >> > Now if 11th group with same shares comes in, then each group will now
> >> > get 9% of CPU and that 10% guarantee breaks.
> >>
> >> So you're trying to guarantee 11 cgroups that they can each get 10% of
> >> the CPU? That's called over-committing, and while there's nothing
> >> wrong with doing that if you're confident that they'll not all need
> >> their 10% at the same time, there's no way to *guarantee* them all
> >> 10%. You can guarantee them all 9% and hope the extra 1% is spare for
> >> those that need it (over-committing), or you can guarantee 10 of them
> >> 10% and give the last one 0 shares.
> >>
> >> How would you propose to guarantee 11 cgroups each 10% of the CPU
> >> using hard limits?
> >>
> >
> > You cannot guarantee 10% to 11 groups on any system (unless I am missing
> > something). The sum of guarantees cannot exceed 100%.
> 
> That's exactly my point. I was trying to counter Bharata's statement, which was:
> 
> > > Now if 11th group with same shares comes in, then each group will now
> > > get 9% of CPU and that 10% guarantee breaks.
> 
> which seemed to be implying that this was a drawback of using shares
> to implement guarantees.
> 

OK :). Glad to see I did not get it wrong.

I think we are focusing on the wrong use case here. Guarantees is just a
useful side-effect we get by using hard limits. I think the more
important use case is where the provider wants to limit the amount of
time a user gets (such as in a cloud).

Maybe we should direct our attention in solving that problem? :)

thanks,
-- 
regards,
Dhaval
