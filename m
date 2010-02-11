From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] RFC: s390: Move get_signal_to_deliver() up in do_signal
Date: Thu, 11 Feb 2010 12:48:28 -0500
Message-ID: <4B7442EC.5080903@cs.columbia.edu>
References: <20100210204019.GA24269@us.ibm.com>
	<20100211094838.4550edd9@mschwide.boeblingen.de.ibm.com>
	<20100211172917.GD6884@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100211172917.GD6884-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Martin Schwidefsky (schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
>> On Wed, 10 Feb 2010 14:40:19 -0600
>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>>
>>> The current placement of get_signal_to_deliver() means that
>>> try_to_freeze() in get_signal_to_deliver() will happen after
>>> regs->psw.addr, regs->svcnr, and regs->gprs[2] may have been
>>> mangled.  Since the app may get checkpointed while frozen and
>>> then restarted, this means we have to attempt a complicated
>>> and subtle re-calculation of the initial conditions.
>>>
>>> If we just move the get_signal_to_deliver() above the
>>> immediately preceding block, we enourmously simplify the
>>> arch-specific checkpoint/restart code.
>>>
>>> A full ltp run seems to show no regressions do to this move,
>>> though I'm not familiar enough with the entry_64.S code in
>>> particular to be absolutely confident.
>>>
>>> Is this a bad idea?
>> I think it is a bad idea. The comment of get_signal_to_deliver tells
>> you that the debugger is invoked and may want to change the registers.
>> If the get_signal_to_deliver calls is moved then the debugger sees
>> the unmodified registers which is imho wrong. A comparison of the
>> gdb testsuite with and without the patch will tell us more.
> 
> Right, but I guess what's confounding me is exactly why the values
> being set for the debugger make more sense to the debugger than the
> initial ones.  Note that they're not actually the same as they will
> be upon exit, for instance in the -ERESTARTNOHAND case if certain
> signals are delivered we'll change psw.addr back after all and set
> -EINTR.
> 
> So yeah, with this patch, if I send a signal to a program being
> debugged and then do 'i r' I see -516 instead of the -4 which I
> otherwise see, and a different $pswa.  Results for 'sleep' (which
> is ERESTART_RESTARTBLOCK) and 'getchar' (which is not) being
> interupted is below.  Frankly I think the info you see with the
> patch is more informative, not less, and the debugger certainly
> functions as well as it did before.
> 
> Of course there is probably fancier userspace tracing/debugging
> code out there which depends on the current behavior?  And the
> most convincing argument might be that it's all so magical that
> changing it is begging for trouble.

I suppose it also changes the behavior/ output of strace/ltrace ?

> But it sure would simplify checkpoint.

If this doesn't get through, then an alternative would be to
save the original state -- namely, svcnr, pswa, and gprs[2] --
on somewhere that is accessible to the checkpoint code ?

Oren.
