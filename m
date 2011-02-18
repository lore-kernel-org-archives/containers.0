From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: userns: targeted capabilities v5
Date: Thu, 17 Feb 2011 19:53:37 -0800
Message-ID: <m1vd0i6lry.fsf__49648.5574440614$1298001322$gmane$org@fess.ebiederm.org>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217162146.1b8e45e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110217162146.1b8e45e0.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (Andrew
	Morton's message of "Thu, 17 Feb 2011 16:21:46 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> On Thu, 17 Feb 2011 15:02:24 +0000
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
>
>> Here is a repost of my previous user namespace patch, ported onto
>> last night's git head.
>> 
>> It fixes several things I was doing wrong in the last (v4)
>> posting, in particular:
>> 
>> 	1. don't set uts_ns->user_ns to current's when !CLONE_NEWUTS
>> 	2. add a ipc_ns->user_ns which owns ipc_ns, and use that to
>> 	   decide CAP_IPC_OWNER
>> 	3. fix logic flaw caused by bad parantheses
>> 	4. allow do_prlimit to current
>> 	5. don't always give root full privs to init_user_ns
>> 
>> The expected course of development for user namespaces is laid out
>> at https://wiki.ubuntu.com/UserNamespace.
>
> Seems like a nice feature to be developing.
>
> I worry about the maturity of it all at this stage.  How far along is
> it *really*?
>
> Is anyone else working with you on developing and reviewing this work?

I did a lot of the initial design and I have been reviewing as I have
time.

Andrew at a practical level we have to merge this incrementally.
Anything much bigger than Serge's current patchset will be too big to
review.  The first really bit step is making capabilities local to the
user namespace, and that is what this patchset does along with using
that localness in some good places.

Eric
