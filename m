From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Mon, 12 Jul 2010 14:54:56 -0700
Message-ID: <20100712215456.GA23721@us.ibm.com>
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
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Albert Cahalan [acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:

| Not that one couldn't cram
| things into the old system call, but that would involve changing
| the meaning of at least one parameter based on a flag. (eeew)

My understanding was that extending eclone() in the future using a flag
to determine the size would get the same response. Maybe I misunderstood
that, but when Peter proposed that we use the 'args_size' - it looked
logical to me. Sure such interfaces are not common, but I did not see any
response/objections to it.

	http://lkml.org/lkml/2009/10/14/497

| 
| I'm suggesting that you not copy the struct as one blob, or at
| least not expect to do so for future extensions to eclone. You
| can read the flags, use that to determine struct size, and then
| read the rest of the struct. Alternately you can pass 32 more flags
| as a 5th syscall argument.
| 
| I'm not so sure we need 96 flag bits, but OK. They can all go
| in the struct if you like, or they can all go in the arguments.
| FWIW, I happen to think that both kernel and user code will
| be less ugly if all of the flags fit in 64 bits. C doesn't provide
| a 96-bit integer type.

We wanted to leave the original 32-bits of clone-flags as the first
parameter to avoid confusing the application writers.

	http://lkml.org/lkml/2009/10/14/13

We do not anticipate needing 64 more flags - we may have several
independent calls to unshare/clone new namespaces. We can treat
the higher 32-bits as a "reserved" field for now and not worry
about using all 96-bits for now.

Sukadev
