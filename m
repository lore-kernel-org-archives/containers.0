From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Fri, 25 Mar 2011 22:14:01 -0400
Message-ID: <4D8D4BE9.8010605@cs.columbia.edu>
References: <20110225115507.GD3915@hawkmoon.kerlabs.com>
	<20110225190132.GA31300@us.ibm.com>
	<20110226135431.GA3251@kerlabs.com>
	<4D6BB499.7050602@cs.columbia.edu>
	<20110228150942.GD18970@hawkmoon.kerlabs.com>
	<4D6C1D58.5060400@cs.columbia.edu>
	<20110301153105.GD4410@hawkmoon.kerlabs.com>
	<4D6FB5D9.8010002@cs.columbia.edu>
	<20110303163531.GO21429@hawkmoon.kerlabs.com>
	<4D710E37.8000109@cs.columbia.edu>
	<20110304172914.GE3543@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110304172914.GE3543-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Luis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 03/04/2011 12:29 PM, Louis Rilling wrote:
> On 04/03/11 11:07 -0500, Oren Laadan wrote:
>> On 03/03/2011 11:35 AM, Louis Rilling wrote:
>>> On 03/03/11 10:38 -0500, Oren Laadan wrote:
>>>> On 03/01/2011 10:31 AM, Louis Rilling wrote:
>>>>> On 28/02/11 17:10 -0500, Oren Laadan wrote:
>>>>>> So looking at the code again, we could add one condition in exit.c
>>>>>> at wait_consider_task(), after the test of p->exit_state =3D=3D EXIT=
_DEAD,
>>>>>> to also test:
>>>>>>
>>>>>> inline static bool is_ghost_task(p)
>>>>>> {
>>>>>> 	return (p->flags & (PF_EXITING|PF_RESTARTING) =3D=3D
>>>>>> 		PF_EXITING|PF_RESTARTING) && task_detached(p)
>>>>>> }
>>>>>>
>>>>>> 	if (p->flags & is_ghost_task(p))
>>>>>> 		return 0;
>>>>>>
>>>>>> Or something along the lines (e.g. used EXIT_ZOMBIE comparison inste=
ad
>>>>>> of PF_EXITING). While requiring a kernel patch, it is relatively sho=
rt,
>>>>>> clean and easy to review.
>>>
>>> EXIT_ZOMBIE comparison would not optimize much imho, since p->flags mus=
t be
>>> checked anyway.
>>>
>>> Nit1: I don't think that checking p->flags saves anything before calling
>>> is_ghost_task().
>>
>> Hmm.. right -
>> That's a leftover from before I decided to introduce is_ghost_task()
>>
>>>
>>> Nit2: why would you like to check that PF_EXITING and PF_RESTARTING come
>>> together? Is it to make sure that no "real" restarted thread will be sk=
ipped
>>> this way?
>>
>> If wait() is called to get the state of stopped children, and for
>> whatever reason the ghost is stopped or being ptraced (we should
>> probably prevent that... but ok) - testing for the exiting/zombie =

>> condition is an extra safety measure: only skip this task when it
>> is actually exiting.
> =

> I don't see how a ghost task could be stopped or ptraced, since it calls
> do_exit() right after becoming detached, and thus identifiable as a ghost.
> Unless it gets ptraced right before calling sys_restart()? Even in that c=
ase,
> it's not reapable by ptrace since it's not in stopped state. OTOH, it may=
 still
> be reaped in wait_task_continued() (see below).
> =

>>
>> Do you not think it's needed ?
> =

> Not sure. As far as I can see, other restarting (with PF_RESTARTING) and
> detached tasks can only be sub-threads, and are mostly not reapable in an=
y way
> as long as PF_RESTARTING is set. They can surely be reaped neither by
> wait_task_zombie(), nor by wait_task_stopped(). The only possibility I se=
e is by
> wait_task_continued(), because a previous "wakeup from stopped" has not b=
een
> consumed before the checkpoint.
> =

> But, and I think that this is a good reason to check PF_EXITING (or
> ->exit_state), if threads are skipped this way, then wait() might incorre=
ctly
> return -ECHILD instead of sleeping.
> =

> Wait. Even with this, after ->exit_signal is set to -1, and before PF_EXI=
TING is
> set, wait_consider_task() can still consider the ghost as potentially rea=
pable
> in the future. Deadlock again.
> =

> In fact, it's probably much saner to have something atomic, like:
> =

> 	write_lock_irq(&tasklist_lock);
> 	p->flags |=3D PF_EXITING;
> 	p->exit_signal =3D -1;
> 	__wake_up_parent(p, p->parent);
> 	write_unlock_irq(&tasklist_lock);
> =

> Unfortunately this is not accepted by do_exit(). So two kinds of solution=
s:
> either set a new flag =E0 la PF_RESTART_GHOST, and only check for this fl=
ag in
> wait_consider_task(),
> or somewhere in do_exit() (latest in exit_notify()), have
> another mean to recognize ghost tasks, and do the ->exit_signal =3D -1 +
> __wake_up_parent() there.
> =

> What's your opinion?
> =


Doing it in wait_consider_task() may be a problem since we only mark
a task as ghost after it has lived for a while, so wait() would have
already considered it a valid child to wait for.

If I had to choose, then I'd do the snippet you suggest above - and
in particular where PF_EXITING is already set, which is exit_signals().

Adding a means to recognize ghost tasks is simple: we ran out of =

task->flags, but we can add a c/r related field to hold such a flag
(we already add one field to the task_struct).

Do you think that will do it ?

Thanks,

Oren.
