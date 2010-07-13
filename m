From: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Tue, 13 Jul 2010 02:48:29 -0400
Message-ID: <AANLkTikXDsv9CoV_EU48bunLD1wCh3w7HVdpo84rJtJg@mail.gmail.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<AANLkTilTGvFTkjy8vi8N8msB7koEp0r7SnpPqJkVN4XA@mail.gmail.com>
	<201007051234.40943.arnd@arndb.de>
	<20100706222554.GA7648@us.ibm.com>
	<AANLkTilJMi8cXSlbG8towQFFAQpuuJjO9kDXWOfEu_EJ@mail.gmail.com>
	<20100712215456.GA23721@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100712215456.GA23721-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jul 12, 2010 at 5:54 PM, Sukadev Bhattiprolu
<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> Albert Cahalan [acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:
>
> | Not that one couldn't cram
> | things into the old system call, but that would involve changing
> | the meaning of at least one parameter based on a flag. (eeew)
>
> My understanding was that extending eclone() in the future using a flag
> to determine the size would get the same response.

I doubt that. We extended clone via flags without trouble,
increasing the number of parameters it took. We never had
to change the meaning of a parameter though. Unfortunately
we used up the last (sixth) free system call parameter. There
is no way to cram in a pointer to a parameter struct unless
we redefine one of the six existing parameters, which is yucky.
For example, the stack pointer parameter could instead point
at a struct if some "#define CLONE_EXT 0x80000000" is set.
We've done worse I think, (mount?), but...

So the distinction here is adding vs. redefining. You wouldn't
need to redefine anything, since RAM space is plentiful. The
old clone syscall can only be extended by redefining, because
we've run out of registers.

I must admit that the hack looks strangely appealing though,
eliminating the need to wait for glibc or find alternatives. :-)

> | I'm suggesting that you not copy the struct as one blob, or at
> | least not expect to do so for future extensions to eclone. You
> | can read the flags, use that to determine struct size, and then
> | read the rest of the struct. Alternately you can pass 32 more flags
> | as a 5th syscall argument.
> |
> | I'm not so sure we need 96 flag bits, but OK. They can all go
> | in the struct if you like, or they can all go in the arguments.
> | FWIW, I happen to think that both kernel and user code will
> | be less ugly if all of the flags fit in 64 bits. C doesn't provide
> | a 96-bit integer type.
>
> We wanted to leave the original 32-bits of clone-flags as the first
> parameter to avoid confusing the application writers.
>
> =A0 =A0 =A0 =A0http://lkml.org/lkml/2009/10/14/13

IMHO, having multiple flags fields is far more confusing.
It's easier to document the high flag case ("This flag requires
the eclone system call.") than to document multiple sets
of incompatible flags for one system call. I always curse
the nasty multi-flagged mmap interface whenever I use it.
If you're going to be concerned with flags getting truncated
via improper use of the syscall, then you should be at least
as concerned with flags getting passed in the wrong place.
For example, one might pass all flags (high and low) in the
struct. Somebody else might pass all flags in the parameters.
