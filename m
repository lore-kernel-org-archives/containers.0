From: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Sun, 11 Jul 2010 05:00:10 -0400
Message-ID: <AANLkTilJMi8cXSlbG8towQFFAQpuuJjO9kDXWOfEu_EJ@mail.gmail.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<AANLkTilTGvFTkjy8vi8N8msB7koEp0r7SnpPqJkVN4XA@mail.gmail.com>
	<201007051234.40943.arnd@arndb.de>
	<20100706222554.GA7648@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100706222554.GA7648-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Tue, Jul 6, 2010 at 6:25 PM, Sukadev Bhattiprolu
<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> Arnd Bergmann [arnd-r2nGTMty4D4@public.gmane.org] wrote:
> | On Monday 05 July 2010, Albert Cahalan wrote:
> | > On Sun, Jul 4, 2010 at 7:39 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wr=
ote:
> | > > On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
> | > >> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> | > >> > +
> | > >> > +sys_eclone(u32 flags_low, struct clone_args * __user cargs, int=
 cargs_size,
> | > >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t * __user pids)
> | > >>
> | > >> I don't see why cargs_size is needed for expansion if you have fla=
gs.
> | > >
> | > > I think it's cleaner this way. The alternative you seem to be hinti=
ng at
> | > > is:
> | > >
> | > > If we used a flag bit to indicate an expansion of the parameters th=
en it
> | > > would only be able to specify one expansion before we'd have to sta=
rt
> | > > using bits in the args structure itself. Using those extra bits is
> | > > quite gross -- we'd have to copy the initial portion of the struct,=
 decode
> | > > the bit(s) describing the size, and then copy the rest. Also, do we=
 have
> | > > any bits left in flags_low? I thought those were all used up...
>
> I think there is one bit (0x1000 before CLONE_PTRACE) left in clone_flags=
 now.
> Not sure if it had any historical uses, but there was talk of trying to u=
sing
> that flag to extend the functionality of clone() without a new system cal=
l.
>
> IIUC, the conclusion of the discussion was that such approach would make =
the
> API messy and set a bad precedent. And the extra copy-from-user was not
> considered signficant.
>
> IOW, Albert, we have been through this before in [v7] or [v10] of the API=
 :-)

I am not suggesting some foul abuse of the old clone syscall.
I assume there will be a new syscall. Not that one couldn't cram
things into the old system call, but that would involve changing
the meaning of at least one parameter based on a flag. (eeew)

I'm suggesting that you not copy the struct as one blob, or at
least not expect to do so for future extensions to eclone. You
can read the flags, use that to determine struct size, and then
read the rest of the struct. Alternately you can pass 32 more flags
as a 5th syscall argument.

I'm not so sure we need 96 flag bits, but OK. They can all go
in the struct if you like, or they can all go in the arguments.
FWIW, I happen to think that both kernel and user code will
be less ugly if all of the flags fit in 64 bits. C doesn't provide
a 96-bit integer type.

> | > You'd be copying from a struct in userspace to some random local
> | > variables in the kernel. There is no reason why the kernel would
> | > have to use a struct at all. You copy the flags, then see what else
> | > you need to copy.
> |
> | Exactly. The size argument is also my main criticism of the suggested
> | syscall, and I've been arguing the same as you.
> |
> | Note that you may still use copy the entire struct, provided that we
> | leave enough reserved fields at the end for future extensions. If
> | we run out of space ten years from now, we can still have a new syscall
> | number with a new structure.
>
> If we need the API to be extendible, to me specifying the size in the
> API seems more explicit than using the flags.

Is there any other system call with this sort of extendability?
You're going against history and IIRC policy.

Most explicit would be a version number, but even that is
forbidden AFAIK.
