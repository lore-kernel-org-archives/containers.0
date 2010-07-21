From: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Wed, 21 Jul 2010 15:51:46 -0400
Message-ID: <AANLkTiney5OwFrPkoyhiKW8up_9_ORl6mUjns4wpMFZd@mail.gmail.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<AANLkTilTGvFTkjy8vi8N8msB7koEp0r7SnpPqJkVN4XA@mail.gmail.com>
	<201007051234.40943.arnd@arndb.de>
	<20100706222554.GA7648@us.ibm.com>
	<AANLkTilJMi8cXSlbG8towQFFAQpuuJjO9kDXWOfEu_EJ@mail.gmail.com>
	<20100712215456.GA23721@us.ibm.com>
	<AANLkTikXDsv9CoV_EU48bunLD1wCh3w7HVdpo84rJtJg@mail.gmail.com>
	<20100720221357.GA2440@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100720221357.GA2440-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Tue, Jul 20, 2010 at 6:13 PM, Sukadev Bhattiprolu
<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> Albert Cahalan [acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:
> | On Mon, Jul 12, 2010 at 5:54 PM, Sukadev Bhattiprolu
> | <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> | > Albert Cahalan [acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:

> | > | I'm suggesting that you not copy the struct as one blob, or at
> | > | least not expect to do so for future extensions to eclone. You
> | > | can read the flags, use that to determine struct size, and then
> | > | read the rest of the struct. Alternately you can pass 32 more flags
> | > | as a 5th syscall argument.
> | > |
> | > | I'm not so sure we need 96 flag bits, but OK. They can all go
> | > | in the struct if you like, or they can all go in the arguments.
> | > | FWIW, I happen to think that both kernel and user code will
> | > | be less ugly if all of the flags fit in 64 bits. C doesn't provide
> | > | a 96-bit integer type.
> | >
> | > We wanted to leave the original 32-bits of clone-flags as the first
> | > parameter to avoid confusing the application writers.
> | >
> | > =A0 =A0 =A0 =A0http://lkml.org/lkml/2009/10/14/13
> |
> | IMHO, having multiple flags fields is far more confusing.
>
> It is confusing but like I said, it was discussed (see
> http://lkml.org/lkml/2009/10/14/6) and the conclusion was that silent
> data corruption is worse. So, I am leaving the interface as defined in
> this version of the patchset.

The current interface encourages silent data corruption of
a different type. It's far more likely to happen I think; putting
flags in the wrong field is what people will do.

Either way, this is a trivial problem for freshly-written code.
I'd rather the problem affect an obsolete interface, keeping
the new interface nice and clean with a single 64-bit value.

> Maybe we can define other API to set/clear clone flags like the sigset()
> interface when we need more than 32 bit flags.
...
> Maybe the sigset() like interface will help.

That works, but it sure is a pain to use.

BTW, the flags used to give clone extra arguments are no
longer needed and are thus available for reuse. This wouldn't
be confusing if there were ECLONE_* defines.
