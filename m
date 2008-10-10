From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Fri, 10 Oct 2008 15:17:16 +0200
Message-ID: <200810101517.17809.rjw__26477.0454531119$1223644828$gmane$org@sisk.pl>
References: <20081009190405.13A253CB@kernel> <1223585671.11830.40.camel@nimitz>
	<20081010084614.GA319@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081010084614.GA319-X9Un+BFzKDI@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday, 10 of October 2008, Ingo Molnar wrote:
> 
> * Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
> > On Thu, 2008-10-09 at 14:43 -0500, Serge E. Hallyn wrote:
> > > Hmm, I don't know too much about aio, but is it possible to succeed with
> > > io_getevents if we didn't first do a submit?  It looks like the contexts
> > > are looked up out of current->mm, so I don't think we need this call
> > > here.
> > > 
> > > Otherwise, this is neat.
> > 
> > Good question.  I know nothing, either. :)
> > 
> > My thought was that any process *trying* to do aio stuff of any kind 
> > is going to be really confused if it gets checkpointed.  Or, it might 
> > try to submit an aio right after it checks the list of them.  I 
> > thought it best to be cautious and say, if you screw with aio, no 
> > checkpointing for you!
> 
> as long as there's total transparency and the transition from CR-capable 
> to CR-disabled state is absolutely safe and race-free, that should be 
> fine.
> 
> I expect users to quickly cause enough pressure to reduce the NOCR areas 
> of the kernel significantly ;-)
> 
> In the long run, could we expect a (experimental) version of hibernation 
> that would just use this checkpointing facility to hibernate?

Surely not ACPI-compliant.

Apart from this I don't see why not, but OTOH I'm not particularly interested
in implementing that.

Thanks,
Rafael
