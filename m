From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2] futex: mark get_robust_list as deprecated
Date: Fri, 30 Mar 2012 10:14:07 +0400
Message-ID: <4F754F2F.7000600@parallels.com>
References: <20120323190855.GA27213@www.outflux.net>
	<m1fwczvuph.fsf@fess.ebiederm.org>
	<20120330050544.GA32299@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120330050544.GA32299-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org" <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, "linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Darren Hart <dvhart-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org" <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/30/2012 09:05 AM, Matt Helsley wrote:
> On Fri, Mar 23, 2012 at 03:06:02PM -0700, Eric W. Biederman wrote:
>> Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:
>>
>>> Notify get_robust_list users that the syscall is going away.
>>
>> Has anyone asked the question if the folks working on checkpoint/restart
>> are going to need this.
>>
>> This seems like important information to know if you want to checkpoint
>> a process.
> 
> I have no idea if the CRIU and DMTCP folks care about this. I've added
> some folks related to those projects to the Cc list.

Nope, we don't need this syscall, thanks for notifying!

>>
>> Eric
>>
>>> Suggested-by: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
>>> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>>> ---
>>> v2:
>>>  - add note to feature-removal-schedule.txt.
>>> ---
>>>  Documentation/feature-removal-schedule.txt |   10 ++++++++++
>>>  kernel/futex.c                             |    2 ++
>>>  kernel/futex_compat.c                      |    2 ++
>>>  3 files changed, 14 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
>>> index 4bfd982..e3bf119 100644
>>> --- a/Documentation/feature-removal-schedule.txt
>>> +++ b/Documentation/feature-removal-schedule.txt
>>> @@ -543,3 +543,13 @@ When:	3.5
>>>  Why:	The old kmap_atomic() with two arguments is deprecated, we only
>>>  	keep it for backward compatibility for few cycles and then drop it.
>>>  Who:	Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> +
>>> +----------------------------
>>> +
>>> +What:	get_robust_list syscall
>>> +When:	2013
>>> +Why:	There appear to be no production users of the get_robust_list syscall,
>>> +	and it runs the risk of leaking address locations, allowing the bypass
>>> +	of ASLR. It was only ever intended for debugging, so it should be
>>> +	removed.
> 
> So I've looked in glibc, gdb, and DMTCP. The description of the intended
> use of get_robust_list() is accurate. However the benefit of ASLR is
> less clear when it comes to the robust list. In glibc the robust list is
> only used from NPTL. The robust list head is in struct pthread which can be
> obtained from pthread_self() anyway. Thus I think ASLR doesn't really help
> obfuscate the robust futex list unless the program is using robust futexes
> without the aid of glibc.
> 
> Cheers,
> 	-Matt Helsley
> 
> .
> 
