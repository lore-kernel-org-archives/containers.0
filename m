From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Tue, 06 Jul 2010 11:14:04 -0400
Message-ID: <4C33483C.2050306@cs.columbia.edu>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>	<20100704233951.GK3338@count0.beaverton.ibm.com>	<4C315B42.1020201@zytor.com>
	<AANLkTimWBFbcRyf5tvA9Lork13gAJtCAdUg_ZS3PzbI0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimWBFbcRyf5tvA9Lork13gAJtCAdUg_ZS3PzbI0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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



Albert Cahalan wrote:
> On Mon, Jul 5, 2010 at 12:10 AM, H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> wrote:
>> On 07/04/2010 04:39 PM, Matt Helsley wrote:
>>>> 1. can you implement it for i386 (register starved) using eclone?
>>> That's a very good question. I'm going to punt on a direct answer for
>>> now. Instead,  I wonder if it's even worth enabling vfork through eclone.
>>> vfork is rarely used, is supported by the "old" clone syscall, and any
>>> old code adapted to use eclone for vfork would need significant
>>> changes because of vfork's specialness. (A consequence of the way vfork
>>> borrows page tables and must avoid clobbering parent's registers..)
>> vfork is its own system call for a reason.  We used to do it with
>> sys_clone, and it turned out to be a mess.  Doing it in a separate
>> system call -- even though the internals are largely the same -- is cleaner.
> 
> That's interesting; only ia64 and xtensa still do vfork via clone.
> I remember sys_vfork being purely i386.
> 
> I guess we need an evfork then. We're slowly gaining all sorts
> of functionality (various clone flags) that is inaccessible when
> there is a need for vfork behavior.

For the record, as far as I can tell, we don't need evfork() for
checkpoint-restart. So you'd need to come up with other use cases.

Oren.
