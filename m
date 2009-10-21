From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][v8][PATCH 9/10]: Define clone3() syscall
Date: Thu, 22 Oct 2009 07:03:28 +0900
Message-ID: <4ADF8530.7070703__42347.4611751319$1256164070$gmane$org@zytor.com>
References: <20091013044925.GA28181@us.ibm.com>
	<20091013045439.GI28435@us.ibm.com>
	<20091016042041.GA7220@us.ibm.com>
	<cfd18e0f0910152325m4a9125c2q18f36f5bd7d4a0@mail.gmail.com>
	<20091016180631.GA31036@us.ibm.com>
	<20091019174405.GE27627@count0.beaverton.ibm.com>
	<4ADCDAA8.5080408@zytor.com>
	<20091019235012.GF27627@count0.beaverton.ibm.com>
	<cfd18e0f0910202126w1ebfa2e2u2ecbaa23b198d100@mail.gmail.com>
	<4ADF06B7.50508@zytor.com> <20091021194440.GA1283@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091021194440.GA1283-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/22/2009 04:44 AM, Sukadev Bhattiprolu wrote:
>>
>> "3" is number of arguments.
>
> To me, it is a version number.
>
> mmap() and mmap2() both have 6 parameters.
>

You keep bringing this up.  mmap2() is (a) a non-user-visible call; (b) 
an exception (a mistake, if you want.)

> Besides if wait4() were born before wait3(), would it still be wait4() :-)

Yes.  wait3() came before wait4(), but there never was a wait2().

> But I see that it is hard to get one-convention-that-fits-all.
>
>> It's better than "extended" or something
>> like that simply because "extended" just means "more than", and a number
>> at least tells you *how much more than*.
>
> And extended assumes we wont extend again.

Exactly.

	-hpa
