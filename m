From: Tomasz Buchert <Tomasz.Buchert-MZpvjPyXg2s@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Thu, 12 Aug 2010 02:53:25 +0200
Message-ID: <4C634605.50301__27897.4538705826$1281574621$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<20100810215741.GC2927@count0.beaverton.ibm.com>
	<4C61D044.2060703@inria.fr>
	<20100811042738.GH2927@count0.beaverton.ibm.com>
	<4C6252CF.1090100@inria.fr>
	<20100812002154.GJ2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100812002154.GJ2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Matt Helsley a =E9crit :
> On Wed, Aug 11, 2010 at 09:35:43AM +0200, Tomasz Buchert wrote:
>> Matt Helsley a =E9crit :
>>> On Wed, Aug 11, 2010 at 12:18:44AM +0200, Tomasz Buchert wrote:
>>>> Matt Helsley a =E9crit :
>>>>> On Tue, Aug 10, 2010 at 09:53:21PM +0200, Tomasz Buchert wrote:
>>>>>> Writing 'FROZEN' to freezer.state file does not
>>>>>> forbid the task to be moved away from its cgroup
>>>>>> (for a very short time). Nevertheless the moved task
>>>>>> can become frozen OUTSIDE its cgroup which puts
>>>>>> discussed task in a permanent 'D' state.
>>>>>>
>>>>>> This patch forbids migration of either FROZEN
>>>>>> or FREEZING tasks.
>>>>>>
>>>>>> This behavior was observed and easily reproduced on
>>>>>> a single core laptop. Program and instructions how
>>>>>> to reproduce the bug can be fetched from:
>>>>>> http://pentium.hopto.org/~thinred/repos/linux-misc/freezer_bug.c
>>>>> Thanks for the report and the test code.
>>>>>
>>>>> I'm will try to reproduce this race in the next few hours and analyze
>>>>> it since I'm not sure the patch really fixes the race -- it may only
>>>>> make the race trigger less frequently.
>>>>>
>>>>> At the very least the patch won't break the current code since it's
>>>>> essentially a more-strict version of is_task_frozen_enough() -- it le=
ts
>>>>> fewer tasks attach/detach to/from frozen cgroups.
>>>>>
>>>>> Cheers,
>>>>> 	-Matt Helsley
>>>> Hi Matt!
>>>> I am a novice if it comes to the kernel and I find the cgroup_freezer
>>>> code especially complicated, so definetely this may be not enough to f=
ix that.
>>>> Notice also that if you uncomment the line 55 in my testcase this will=
 also
>>>> trigger the race! This, however, makes sense since process may not be =
in the cgroup anymore
>>>> and consequently won't be thawed.
>>> OK, I triggered it with that. Interesting.
>>>
>> Good!
>>
>>>> I think that this patch fixes these problems because it does the flag =
checking in a right order:
>>>> first freezing() is used and then frozen() which assures (see frozen_p=
rocess()) that
>>>> the race will not happen. Right? :)
>>> I see what you mean. It still seems like it wouldn't actually fix the r=
ace -- just make it
>>> harder to trigger. I think you're saying this is what happens without t=
he patch:
>>>
>>> Time	"bug" goes through these states		cgroup code checks for these stat=
es
>>> -----------------------------------------------------------------------=
------------
>>> |	freezing
>>> |						is_frozen? Nope.
>>> |	frozen
>>> |						is_freezing? Nope.
>>> |						<move>
>>> V
>>>
>> My first scenario was a bit different:
>> Time	"bug" goes through these states		cgroup code checks for these states
>> ------------------------------------------------------------------------=
-----------
>> |	freezing
>> |						is_task_frozen_enough? Nope.
>> |						<move>
>> |	frozen
>> V
>> but the problem is the same.
> =

> I think I found a bug in the cgroup freezer which your patch fixes.
> However I don't think it's a race.
> =

> /* Task is frozen or will freeze immediately when next it gets woken */
> static bool is_task_frozen_enough(struct task_struct *task)
> {
>         return frozen(task) ||
>                 (task_is_stopped_or_traced(task) && freezing(task));
> }
> =

> So it will only refuse to attach freezing tasks which have been stopped
> or traced! Yet for attach we need to refuse to move _any_ freezing tasks.
> =

> Though stopped/traced _is_ relevant to the cgroup freezer state itself.
> If we uses frozen(task) || freezing(task) to determine whether a cgroup
> is frozen then it would be possible for the task to still be active
> when the cgroup is finally reported FROZEN. However that's not possible
> when the task is stopped/traced *and* freezing since even if woken it
> won't exit the kernel before entering the refrigerator.
> =

>>> But, without having carefully investigated the details, this could just=
 as easily happen
>>> with your patch:
>>>
>>> Time	"bug" goes through these states		cgroup code checks for these stat=
es
>>> -----------------------------------------------------------------------=
------------
>>> |						is_freezing? Nope.
>>> |						is_frozen? Nope.
>>> |	freezing
>>> |						<move>
>>> |	frozen
>>> V
>>>
>> This can't happen as far as I know because there is cgroup_lock around t=
he code in freezer_write()
>> and freezer_can_attach().
>> The task can't enter 'freezing' state when can_attach is executed.
> =

> You're right, cgroup_mutex should protect against that. However presumably
> that same logic applies to the first case. So again I don't think the bug
> is a race.
> =

> <snipped the remaining cases which should be the same>
> =

> At this point I think the bug description in your patch needs to change
> but the patch itself is perfect. Assuming you agree with my assessment
> of the bug I think the process is: you'll rewrite the description, add -s=
table
> maintaners to your current Cc's (since this bug is simple, exists in prev=
ious
> versions, and is somewhat nasty), add:
> =

> Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> =

> and send it to Andrew Morton. Hopefully then (if not before) Paul and Li
> will ack it.
> =

> Thanks!
> =

> Cheers,
> 	-Matt Helsley

I agree with your assessment, Matt. The wrong the definition of being 'froz=
en enough'
allows a task to sneak out of its freezing cgroup.
The problem is that I found another, closely related bug. Right now, I have
a new queue of 3 patches to fix both bugs in a more general setting. They a=
re not well tested
yet but I'm fairly confident that they do the right thing. I'm going to tes=
t them tomorrow.
Do you still want me to push the first patch? I propose to let me work a bi=
t on
the new patches and prepare the code for the incoming fix to the related bu=
g.
What is your opinion?

Tomasz
