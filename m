From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: C/R of termios
Date: Mon, 13 Dec 2010 08:38:41 -0600
Message-ID: <20101213143841.GF17546@hallyn.com>
References: <20101209012820.GA10001@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101209012820.GA10001-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> Oren,
> 
> Any reason we only checkpoint/restore a 'struct termio' instead of a
> 'struct termios' ?
> 
> AFAICT, 'struct termios' seems to supersede 'struct termio' (i.e includes
> all fields of 'struct termio' plus more). The TCGETS ioctl and tcgetattr()
> interface return a 'struct termios' to user space.
> 
> The man page termio(7) says the 'struct termio' interface is obsolete.
> 
> The kernel uses 'struct ktermios' to represent the attributes internally.
> So shouldn't we checkpoint/restore the 'struct ktermios' object ?
> 
> If application uses legacy interface (TCGETA/TCSETA with 'struct termio')
> the kernel converts the 'struct ktermios' to the 'struct termio' in
> kernel_termios_to_user_termio(). So we should be fine if we C/R the
> ktermios object right ?
> 
> Here is a quick hack, just for reference. With this hack, I can C/R an
> app that does tcgetattr() of a pty before/after checkpoint.

Looks reasonable to me.
