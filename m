From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Simplfying copy_siginfo_to_user
Date: Mon, 31 Jul 2017 11:37:41 -0500
Message-ID: <87mv7k1s16.fsf__6564.55572830072$1501519578$gmane$org@xmission.com>
References: <87o9shg7t7.fsf_-_@xmission.com>
	<20170718140651.15973-7-ebiederm@xmission.com>
	<CA+55aFyKsmf+BpYjcH30MGpHTDJ=zgYPx6kwyEB9CXXFxj_xsw@mail.gmail.com>
	<878tjlbqpt.fsf@xmission.com> <8760ek5ics.fsf_-_@xmission.com>
	<CA+55aFyH5W2doo9vxXta_-pXfNXqQ19d7z48k1hmfAot+aJvMw@mail.gmail.com>
	<20170725013756.GH2063@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170725013756.GH2063-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Tue, 25 Jul 2017 02:37:57 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: "linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

2> On Mon, Jul 24, 2017 at 10:43:34AM -0700, Linus Torvalds wrote:
>> On Sat, Jul 22, 2017 at 1:25 PM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> > I played with some clever changes such as limiting the copy to 48 bytes,
>> > disabling the memset and the like but I could not get a strong enough
>> > signal to say that any one change removed the extra or a clear part of
>> > it 20ns.
>> 
>> What CPU did you use? Because the SMAP bit in particular matters.
>> 
>> The field-by-field copies are extremely slow on modern CPU's that
>> implement SMAP, unless you also use the special "unsafe_put_user()"
>> code (or the nasty old put_user_ex() code that some of the x86 signal
>> code uses).
>> 
>> So one of the advantages of just copy_to_user() ends up being visible
>> only on Broadwell+ (or whatever the SMAP cutoff is).
>
> Guys, could you take a look at vfs.git#work.siginfo?  I'd been pretty
> much buried lately (and probably will for several more weeks - long-distance
> moves *suck*), so that thing got stalled, but it might be worth a
> look.

There is some good stuff in there.  If you don't mind I am going to
cherry pick out your unification of struct siginfo and struct compat_siginfo.

> The code generated in copy_siginfo_to_user() in it looks reasonably good,
> we don't copy more than we need and all copying to userland is done
> by copy_to_user() - one call per call of copy_siginfo_to_user(), so
> SMAP crap is not an issue.

There is actually a core problem with doing things that way.  You rely
on having the siginfo union member stored in the high bits of si_code.

I have just fixed that in my tree and replaced using the high bits
with calling the function siginfo_layout.

It has been a significant problem storing the union member differently
in the kernel than in userspace.  It has allowed for some pretty
horrendous gaffs in the archictecures changing the meaning of SI_USER
when specific signals are delivered over.  It has also meant that ptrace
siginfo injection and tg_sigqueueinfo have been broken for some signals
almost since the interface was added.

Without any optimization and just changing the code to be copy_to_user
I am seeing a maybe 2% slowdown.  Given that no one has seemed to care
overly for the performance of signal delivery I suspect an almost
unmeasurable slowdown is a reasonable tradeoff for simpler code.

> The next thing I hope to do is converting compat side of that thing to
> the same; that got stalled.

All of that said your precise copying code appears reasonable and quite
nice so I may adopt it on the compat side.

> Al "Buried in boxes" Viro...

Eric "Also Buried in boxes" Biederman
