From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: For review: pid_namespaces(7) man page
Date: Fri, 1 Mar 2013 09:53:35 +0100
Message-ID: <CAKgNAkhuzSjkak__1FdQ9jUv0VcovoxLLXA=Lq1GBdcQ-aYbTw@mail.gmail.com>
References: <CAKgNAki=mUYuu_Ewhe7sjCmo+Dq2Vr+FZCixqNRaadcvAxtpFw@mail.gmail.com>
	<20130228142440.GA6328@cachalot>
	<CAKgNAkjXAfq4RwtX1ELier+GLv0D5e9spM3Os3-oqSCXGqRqOg@mail.gmail.com>
	<87fw0f5xfw.fsf@xmission.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fw0f5xfw.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 1, 2013 at 9:36 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> [CC += Lennart]
>>
>> On Thu, Feb 28, 2013 at 3:24 PM, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> wrote:
>>> Hi Michael,
>>>
>>> On Thu, Feb 28, 2013 at 12:24 +0100, Michael Kerrisk (man-pages) wrote:
>>>>    The namespace init process
>>>>        The first process created in a new namespace (i.e., the process
>>>>        created using clone(2) with the CLONE_NEWPID flag, or the first
>>>>        child created by a process after a call to unshare(2) using the
>>>>        CLONE_NEWPID flag) has the PID 1, and is the "init" process for
>>>>        the namespace (see init(1)).  Children that are orphaned within
>>>>        the namespace will be reparented to this  process  rather  than
>>>>        init(1).
>>>
>>> Probably it worth noting here that this is true unless
>>> prctl() with PR_SET_CHILD_SUBREAPER option is called.
>>
>> Thanks Vasily. It probably is worth mentioning that, and I will add some words.
>>
>> One thing I am not sure of (have not tested), but maybe you (or Eric)
>> know the answer: does the effect of PR_SET_CHILD_SUBREAPER  cross a
>> PID namespace boundary?
>
> No.

Thanks for the clarification, Eric. I'll note that point in the page.

Cheers,

Michael


>> In other words, if it was a process in the
>> parent PID namespace that employed PR_SET_CHILD_SUBREAPER , will that
>> affect child processes in a child PID namespace, or  wiill
>> PR_SET_CHILD_SUBREAPER  only apply to child processes in the same PID
>> namespace as the caller?
>
> With respect to reparenting it acts like an additional pid namespace
> init is on the path.
>
> If you want to read the code it is in kernel/exit.c:find_new_reaper().
> called from forget_original_parent, which does the actual reparenting.
>
> Eric
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
