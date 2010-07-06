From: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Tue, 6 Jul 2010 00:11:45 -0400
Message-ID: <AANLkTimWBFbcRyf5tvA9Lork13gAJtCAdUg_ZS3PzbI0@mail.gmail.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<4C315B42.1020201@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C315B42.1020201-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jul 5, 2010 at 12:10 AM, H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> wrote:
> On 07/04/2010 04:39 PM, Matt Helsley wrote:
>>>
>>> 1. can you implement it for i386 (register starved) using eclone?
>>
>> That's a very good question. I'm going to punt on a direct answer for
>> now. Instead, =A0I wonder if it's even worth enabling vfork through eclo=
ne.
>> vfork is rarely used, is supported by the "old" clone syscall, and any
>> old code adapted to use eclone for vfork would need significant
>> changes because of vfork's specialness. (A consequence of the way vfork
>> borrows page tables and must avoid clobbering parent's registers..)
>
> vfork is its own system call for a reason. =A0We used to do it with
> sys_clone, and it turned out to be a mess. =A0Doing it in a separate
> system call -- even though the internals are largely the same -- is clean=
er.

That's interesting; only ia64 and xtensa still do vfork via clone.
I remember sys_vfork being purely i386.

I guess we need an evfork then. We're slowly gaining all sorts
of functionality (various clone flags) that is inaccessible when
there is a need for vfork behavior.

To greatly reduce the mess, I strongly suggest that it have the
int(*func)(void*arg) and void*arg arguments like BSD's rfork_thread.
Note that this mess reduction would be severe enough to solve
the problems with sharing a syscall.
