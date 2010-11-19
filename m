From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Fri, 19 Nov 2010 16:33:25 +0100
Message-ID: <4CE698C5.5060806@kernel.org>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
	<20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org>
	<20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org>
	<04F4899E-B5C7-4BAF-8F2F-05D507A91408@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <04F4899E-B5C7-4BAF-8F2F-05D507A91408-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On 11/19/2010 03:36 PM, Kirill Korotaev wrote:
> Can you imagine how many userland APIs are needed to make userspace C/R?
> 
> Do you really want APIs in user-space which allow to:
> - send signals with siginfo attached (kill() doesn't work...)

Doesn't rt_sigqueueinfo() already do this?

> - read inotify configuration

This would be nice even apart from CR.

> - insert SKB's into socket buffers

Can't we drain kernel buffers?  ie. Stop further writing and wait the
send-q to drop to zero.

> - setup all TCP/IP parameters for sockets

I _think_ most can be restored by talking to netfilter module.
Setting outgoing sequence number might be beneficial tho.

> - wait for AIO pending in other processes

I haven't looked at aio implementation for a while now but can't we
drain these upon checkpointing and just carry the completion status?
Also, if aio is what you're concerned about, I would say the problem
is mostly solved.

> - setting different statistics counters (like netdev stats etc.)
> and so on...

Why would this matter?

> For every small piece of functionality you will need to export ABI
> and maintain it forever.  It's thousands of APIs! And why the hell
> they are needed in user space at all?

I think it's actually quite the contrary.  Most things are already
visible to userland.  They _have_ to be and that's the reason why
userland implementation can already get most things working without
any change to the kernel with some amount of hackery.  To me in-kernel
CR seems to approach the problem from the exactly wrong direction -
rather than dealing with specific exceptions, it create a completely
new framework which is very foreign and not useful outside of CR.

Also, think about it.  Which one is better?  A kernel which can fully
show its ABI visible states to userland or one which dumps its
internal data structurs in binary blobs.  To me, the latter seems
multiple orders of magnitude uglier.

> BTW, HPC case you are talking about is probably the simplest
> one.

Yet, it is one of the the most important / relevant use cases.

> Last time I looked into it, IBM Meiosis c/r didn't even bother with
> tty's migration.  In OpenVZ we really do need much more then that
> like autofs/NFS support, preserve statistics, TTYs, etc. etc. etc.

Would it be impossible to preserve autofs/NFS and TTYs from userland?
Then, why so?  For statistics, I'm a bit lost.  Why does it matter and
even if it does would it justify putting the whole CR inside kernel?

Thank you.

-- 
tejun
