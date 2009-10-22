From: Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [RFC][v8][PATCH 9/10]: Define clone3() syscall
Date: Thu, 22 Oct 2009 14:14:16 +0200
Message-ID: <cfd18e0f0910220514y1bd5967aj3a04bc3f5b38948b__4875.14000055871$1256213831$gmane$org@mail.gmail.com>
References: <20091013044925.GA28181@us.ibm.com>
	<cfd18e0f0910152325m4a9125c2q18f36f5bd7d4a0@mail.gmail.com>
	<20091016180631.GA31036@us.ibm.com>
	<20091019174405.GE27627@count0.beaverton.ibm.com>
	<4ADCDAA8.5080408@zytor.com>
	<20091019235012.GF27627@count0.beaverton.ibm.com>
	<cfd18e0f0910202126w1ebfa2e2u2ecbaa23b198d100@mail.gmail.com>
	<4ADF06B7.50508@zytor.com>
	<cfd18e0f0910220326w1a71b899s5ff0fce9e0a2b8ed@mail.gmail.com>
	<4AE0444B.5070603@zytor.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AE0444B.5070603-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Peter,

On Thu, Oct 22, 2009 at 1:38 PM, H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> wrote:
> On 10/22/2009 07:26 PM, Michael Kerrisk wrote:
>>>
>>> "3" is number of arguments.
>>
>> sys_clone3(struct clone_struct __user *ucs, pid_t __user *pids)
>>
>> It appears to me that the number of arguments is 2.
>>
>
> It was 3 at one point... I'm not sure when that changed last :-/
>
>>> It's better than "extended" or something like
>>> that simply because "extended" just means "more than", and a number at
>>> least
>>> tells you *how much more than*.
>>
>> I'm not sure why you think including a number in the name tells us
>> "how much more than". Unless you are considering the numbering to be
>> version numbers, which apparently is not what you mean.
>
> It is a version number of sorts.

So, sometimes, a number in a system call should be the bit width of
some arguments(s), sometimes it should be the number of arguments, and
sometimes (well, just occasionally, as in mmap2() and clone()) -- it
should be a version number? Does the weather play any part in the
decision? ;-)

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface" http://blog.man7.org/
