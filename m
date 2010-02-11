From: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RFC: s390: Move get_signal_to_deliver() up in do_signal
Date: Thu, 11 Feb 2010 09:48:38 +0100
Message-ID: <20100211094838.4550edd9@mschwide.boeblingen.de.ibm.com>
References: <20100210204019.GA24269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100210204019.GA24269-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 10 Feb 2010 14:40:19 -0600
"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> The current placement of get_signal_to_deliver() means that
> try_to_freeze() in get_signal_to_deliver() will happen after
> regs->psw.addr, regs->svcnr, and regs->gprs[2] may have been
> mangled.  Since the app may get checkpointed while frozen and
> then restarted, this means we have to attempt a complicated
> and subtle re-calculation of the initial conditions.
> 
> If we just move the get_signal_to_deliver() above the
> immediately preceding block, we enourmously simplify the
> arch-specific checkpoint/restart code.
> 
> A full ltp run seems to show no regressions do to this move,
> though I'm not familiar enough with the entry_64.S code in
> particular to be absolutely confident.
> 
> Is this a bad idea?

I think it is a bad idea. The comment of get_signal_to_deliver tells
you that the debugger is invoked and may want to change the registers.
If the get_signal_to_deliver calls is moved then the debugger sees
the unmodified registers which is imho wrong. A comparison of the
gdb testsuite with and without the patch will tell us more.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
