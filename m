From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Tue, 7 Jul 2009 09:34:53 +0200
Message-ID: <20090707073452.GA1383@megiteam.pl>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
	<20090707033135.GA29461@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090707033135.GA29461-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On pon, lip 06, 2009 at 08:31:35 -0700, Sukadev Bhattiprolu wrote:
> | To my untrained eye it looks like the cmpl corresponds to:
> | 
> | 1841        if (tty->driver->type == TTY_DRIVER_TYPE_PTY &&
> | 1842            tty->driver->subtype == PTY_TYPE_MASTER)
> | 
> | in drivers/char/tty_io.c
> 
> I don't yet have the exact version of tty_io.c so the line numbers don't
> match, but even so isn't the above 'cmpl' comparing a constant 0x10004
> with the %rdx+0x9c address ? If so, I am not sure how it matches up to
> either TTY_DRIVER_TYPE_PTY (0x0004) or PTY_TYPE_MASTER (0x0001).
> 
> Wouldn't the above 'if' require two separate compare instructions ?

They're two 16-bit words occupying the same 32-bit word, so presumably
gcc optimised it into a single memory access.

> Is it possibly related to this bug where they talk of some sort of
> corruption going on with tty data structures (kernel versions appear
> to be close, but need to double check).
> 
> 	http://lkml.org/lkml/2009/6/16/131

2.6.30 has no tty_ldisc_hangup (the function being touched) at all. I
guess it was added while restructuring the tty layer. I'll have a look
at it though, thanks for the link.

Best regards,
 Grzegorz Nosek
