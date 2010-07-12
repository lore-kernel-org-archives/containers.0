From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Mon, 12 Jul 2010 11:02:23 -0700
Message-ID: <20100712180223.GD3129@count0.beaverton.ibm.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<AANLkTilTGvFTkjy8vi8N8msB7koEp0r7SnpPqJkVN4XA@mail.gmail.com>
	<201007051234.40943.arnd@arndb.de>
	<20100706222554.GA7648@us.ibm.com>
	<AANLkTilJMi8cXSlbG8towQFFAQpuuJjO9kDXWOfEu_EJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTilJMi8cXSlbG8towQFFAQpuuJjO9kDXWOfEu_EJ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Jul 11, 2010 at 05:00:10AM -0400, Albert Cahalan wrote:
> On Tue, Jul 6, 2010 at 6:25 PM, Sukadev Bhattiprolu
> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > Arnd Bergmann [arnd-r2nGTMty4D4@public.gmane.org] wrote:
> > | On Monday 05 July 2010, Albert Cahalan wrote:
> > | > On Sun, Jul 4, 2010 at 7:39 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > | > > On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
> > | > >> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

<snip>

> > | > You'd be copying from a struct in userspace to some random local
> > | > variables in the kernel. There is no reason why the kernel would
> > | > have to use a struct at all. You copy the flags, then see what else
> > | > you need to copy.
> > |
> > | Exactly. The size argument is also my main criticism of the suggested
> > | syscall, and I've been arguing the same as you.
> > |
> > | Note that you may still use copy the entire struct, provided that we
> > | leave enough reserved fields at the end for future extensions. If
> > | we run out of space ten years from now, we can still have a new syscall
> > | number with a new structure.
> >
> > If we need the API to be extendible, to me specifying the size in the
> > API seems more explicit than using the flags.
> 
> Is there any other system call with this sort of extendability?
> You're going against history and IIRC policy.
>
> Most explicit would be a version number, but even that is
> forbidden AFAIK.

Have a look at set_robust_list() -- it passes a size parameter for a
struct.

Lots of socket calls take a socklen_t for a variable-size address struct.
(Granted, they all go through socketcall, but that's a bit beside the
point.)

read() and write() syscalls operating on pseudofiles can be for structs
(e.g. signalfd_siginfo) and thus indirectly do this.

Cheers,
	-Matt Helsley
