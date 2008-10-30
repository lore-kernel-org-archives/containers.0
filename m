From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based	checkpointing/restart
Date: Thu, 30 Oct 2008 13:45:25 -0400
Message-ID: <4909F2B5.7040907__15595.3956571922$1225389005$gmane$org@cs.columbia.edu>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
	<20081030114747.GL15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081030114747.GL15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Thu, Oct 30, 2008 at 10:02:44AM +0400, Andrey Mirkin wrote:
>>>> kernel. Also we will need a functionolity to create processes with
>>>> predefined PID. I think it is not very good to provide such ability to
>>>> user space. That is why we prefer in OpenVZ to do all the job in kernel.
>>> This is the weak side of creating the processes in user space -
>>> that we need such an interface. Note, however, that we can
>>> easily "hide" it inside the interface of the sys_restart() call,
>>> and restrict how it may be used.
>> Of course we can "hide" it somehow, but anyway we will have a hole and that is 
>> not good.
>>
>> Anyway we should ask everyone what they think about user- and kernel- based 
>> process creation.
>> Dave, Serge, Cedric, Daniel, Louis what do you think about that?
> 
> Frankly, I'm not convinced (yet) that one approach is better than the other one.
> I only *tend* to prefer kernel-based, for the reasons explained below. I know
> that there are arguments in favor of userspace (I've at least seen
> security-related ones), but I let their authors detail them (again).

I'm not convinced either. I think both implementation can eventually
work well.

> 
> In Kerrighed this is kernel-based, and will remain kernel-based because we
> checkpoint a distributed task tree, and want to restart it as mush as possible
> with the same distribution. The distributed protocol used for restart is
> currently too fragile and complex to rely on customized user-space
> implementations. That said, if someone brings very good arguments in favor of
> userspace implementations, we might consider changing this.

Zap also has distributed checkpoint which does not require strict
kernel-side ordering. Do you need that because you do SSI ?

> 
> Without taking distributed restart into account, I also tend to prefer
> kernel-based, mainly for two (not so strong) reasons:
> 1) this prevents userspace from doing weird things, like changing the task tree
> and let the kernel detect it and deal with the mess this creates (think about
> two threads being restarted in separate processes that do not even share their
> parents). But one can argue that userspace can change the checkpoint image as
> well, so that the kernel must check for such weird things anyway.

I don't really buy this argument. First, as you say, user can change
the checkpoint image file. Second, you can verify in the kernel that
the real relationships of the processes match those specified (and
expected from) the image file. That's pretty straightforward.

> 2) restart will be more efficient with respect to shared objects.

Can you elaborate on this ?  In what sense "more efficient" ?

Note that the topic in question is not whether to do the entire restart
from user space (and I argue that most work should be done in the kernel),
but rather whether process creation (and only that) should be done in
kernel or user space.

Quick thoughts of pros/cons of each approach are:

user space:

+ re-use existing api (fork)
+ easier to debug
+ will allow 'handmade' resources restart: it was mentioned before that
  one may want to reattach stdout to a different place after restart; a
  user based restart of processes can make this much easier: e.g. the
  user process can create the alternative resources, give them to the
  kernel and only then call sys_restart)
+ arch-independent code

- a bit slower than in kernel space
- requires a clone-with-specific-pid syscall or interface

kernel space:

+ a bit easier to control everything
+ a bit faster than user space
+ no need for user-visible interface for clone-with-...

- arch-dependent code
- needs special code to fight 'fork-bomb'

So, I'm not convinced, and I even think there may be room to both, for
the time being. I volunteer to support the user-space alternative while
we make up our minds.

Oren.
