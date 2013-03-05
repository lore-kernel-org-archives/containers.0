From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: For review: pid_namespaces(7) man page
Date: Tue, 5 Mar 2013 08:01:26 +0100
Message-ID: <CAKgNAkgYxE5XNqPmKDg=6ksazno6y8nHzMJ4UTk551C717P4NQ__18180.5453067229$1362466935$gmane$org@mail.gmail.com>
References: <876217olp0.fsf@xmission.com> <1362425267.7276.1@driftwood>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1362425267.7276.1@driftwood>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 4, 2013 at 8:27 PM, Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org> wrote:
> On 03/03/2013 10:03:55 PM, Eric W. Biederman wrote:
>>
>> Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org> writes:
>>
>> > On 03/01/2013 03:57:40 AM, Michael Kerrisk (man-pages) wrote:
>> >> > And yet the glibc guys insist on #define
>> >> GNU_GNU_GNU_ALL_HAIL_STALLMAN in
>> >> > order to access this Linux-specific feature which has nothing
>> >> whatsoever to
>> >> > do with the FSF.
>> >>
>> >> This is a misunderstanding. _GNU_SOURCE is the standard way to expose
>> >> Linux-specific functionality from POSIX header files.
>> >
>> > What standard? The Linux kernel is not, and never was, part of the GNU
>> > project.
>>
>> Is the argument that there should be a _LINUX_SOURCE directive in glibc
>> for this?
>
>
> If you don't #define any feature test macros at all, you get a bunch of
> macros (_BSD_SOURCE, _SVID_SOURCE, _POSIX_SOURCE, _POSIX_C_SOURCE=200809L,
> and so on) defined by default in features.h. If you start defining macros,
> several of the default ones _go_away_, and you start missing things that are
> defined by posix-2008. Yes, defining feature test macros makes definitions
> _vanish_ out of the headers, which means feature test macros can actually
> reduce code portability.

This has nothing to do with reducing portability; have a (careful)
read of feature_test_macros(7).

[...]

> The new musl-libc.org did an _ALL_SOURCE macro that just enables every
> feature test macro they implemented. (That's its definition, it's the
> feature test macro that says feature test macros area bad idea.)
>
>
>> Although come to think of it I can't imagine how <sched.h> is a POSIX
>> header.  Last I looked it only had linux specific bits in it.  Which
>> makes needing any kind of #define strange.
>
>
> My objection is that Linux system calls are not part of the GNU project.
> Requiring that macro to get Linux system calls out of bionic, uClibc, klibc,
> musl, olibc, dietlibc, or newlib is _silly_. It's the "GNU/Linux" prefix
> imposed on the source level, and it's a fairly recent development (I've only
> noticed it since 2008 or so).

The macro has been present since at least glibc 2.0 (1997).

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
