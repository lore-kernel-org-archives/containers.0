From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Tue, 6 Jul 2010 15:25:54 -0700
Message-ID: <20100706222554.GA7648@us.ibm.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<AANLkTilTGvFTkjy8vi8N8msB7koEp0r7SnpPqJkVN4XA@mail.gmail.com>
	<201007051234.40943.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201007051234.40943.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Arnd Bergmann [arnd-r2nGTMty4D4@public.gmane.org] wrote:
| On Monday 05 July 2010, Albert Cahalan wrote:
| > On Sun, Jul 4, 2010 at 7:39 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
| > > On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
| > >> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
| > >> > +
| > >> > +sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
| > >> > +               pid_t * __user pids)
| > >>
| > >> I don't see why cargs_size is needed for expansion if you have flags.
| > >
| > > I think it's cleaner this way. The alternative you seem to be hinting at
| > > is:
| > >
| > > If we used a flag bit to indicate an expansion of the parameters then it
| > > would only be able to specify one expansion before we'd have to start
| > > using bits in the args structure itself. Using those extra bits is
| > > quite gross -- we'd have to copy the initial portion of the struct, decode
| > > the bit(s) describing the size, and then copy the rest. Also, do we have
| > > any bits left in flags_low? I thought those were all used up...

I think there is one bit (0x1000 before CLONE_PTRACE) left in clone_flags now.
Not sure if it had any historical uses, but there was talk of trying to using
that flag to extend the functionality of clone() without a new system call.

IIUC, the conclusion of the discussion was that such approach would make the
API messy and set a bad precedent. And the extra copy-from-user was not
considered signficant.

IOW, Albert, we have been through this before in [v7] or [v10] of the API :-)

| > 
| > You'd be copying from a struct in userspace to some random local
| > variables in the kernel. There is no reason why the kernel would
| > have to use a struct at all. You copy the flags, then see what else
| > you need to copy.
| 
| Exactly. The size argument is also my main criticism of the suggested
| syscall, and I've been arguing the same as you.
| 
| Note that you may still use copy the entire struct, provided that we
| leave enough reserved fields at the end for future extensions. If
| we run out of space ten years from now, we can still have a new syscall
| number with a new structure.

If we need the API to be extendible, to me specifying the size in the
API seems more explicit than using the flags. Of course these extensions
should not mean anything goes. It could be for something that does not
change the basic function of the call (like adding a new clone flag).
Anything significant than that should probably be a new system-call.
