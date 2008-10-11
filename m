From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Sat, 11 Oct 2008 17:00:22 +0200
Message-ID: <20081011150022.GA18989__2169.39062015644$1223737373$gmane$org@elte.hu>
References: <20081009190405.13A253CB@kernel> <20081009190406.1B257119@kernel>
	<20081009194350.GA31214@us.ibm.com>
	<1223585671.11830.40.camel@nimitz>
	<20081010084614.GA319@elte.hu> <20081011134803.GA1483@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081011134803.GA1483-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Id: containers.vger.kernel.org


* Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org> wrote:

> > In the long run, could we expect a (experimental) version of 
> > hibernation that would just use this checkpointing facility to 
> > hibernate? That would be way cool for users and for testing: we 
> > could do transparent kernel upgrades/downgrades via this form of 
> > hibernation, between CR-compatible kernels (!).
> 
> Well, if we could do that, I guess we could also use CR to 'hibernate' 
> your desktop then continue on your notebook. And yes that sounds cool.

yes.

> > Pie in the sky for sure, but way cool: it could propel Linux kernel 
> > testing to completely new areas - new kernels could be tried 
> > non-intrusively. (as long as a new kernel does not corrupt the CR 
> > data structures - so some good consistency and redundancy checking 
> > would be nice in the format!)
> 
> Well, for simple apps, it should not be that hard...

Generally, if something works for simple apps already (in a robust, 
compatible and supportable way) and users find it "very cool", then 
support for more complex apps is not far in the future.

but if you want to support more complex apps straight away, it takes 
forever and gets ugly.

	Ingo
