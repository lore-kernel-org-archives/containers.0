From: Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Fri, 10 Oct 2008 16:40:25 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0810101637050.7059__4481.53299880705$1223671492$gmane$org@localhost.localdomain>
References: <20081009190405.13A253CB@kernel> <200810101517.17809.rjw@sisk.pl>
	<20081010145422.GE11695@elte.hu> <200810102153.45174.rjw@sisk.pl>
	<20081010195339.GA509@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20081010195339.GA509-X9Un+BFzKDI@public.gmane.org>
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, ACPI Devel Maling List <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Id: containers.vger.kernel.org



On Fri, 10 Oct 2008, Ingo Molnar wrote:

> 
> * Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> 
> > > > Surely not ACPI-compliant.
> > > 
> > > what do you mean?
> > 
> > The ACPI spec says quite specifically what should be done while 
> > entering hibernation and during resume from hibernation.  We're not 
> > following that in the current code, but we can (gradually) update the 
> > code to become ACPI-compilant in that respect.  However, if we go the 
> > checkpointing route, I don't think that will be possible any more.
> 
> ah, i see. I did not mean to utilize any ACPI paths but simple powerdown 
> or reboot.

If we don't enter ACPI S4, and instead poweroff,
then we'll lose the capability to wake the system from
devices that are capable of waking S4, but incapable of waking S5.

ie. The power button will still work, but others may not.

cheers,
-Len

> If we checkpoint all apps to persistent disk areas (which the checkpoint 
> patches in this thread are about), then we can just reboot the kernel 
> and forget all its state.
> 
> That capability can be used to build a really robust hibernation 
> implementation IMO: we could "hibernate/kexec" over between different 
> kernel versions transparently. (only a small delay will be noticed by 
> the user - if we do it smartly with in-kernel modesetting then not even 
> the screen contents will be changed over this.)
