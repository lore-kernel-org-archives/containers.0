From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: --- replacement patch 4/4 (a)
Date: Thu, 04 Jun 2009 12:32:33 -0400
Message-ID: <4A27F721.9060100@cs.columbia.edu>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
	<20090603161840.GD7848@us.ibm.com>
	<Pine.LNX.4.64.0906031957110.19096@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0906032008490.19096@takamine.ncl.cs.columbia.edu>
	<20090604103418.GW9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090604103418.GW9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Wed, Jun 03, 2009 at 08:10:24PM -0400, Oren Laadan wrote:
>> From 6cdb7d9504a19ad88e6da8ad85374267c7acb1b2 Mon Sep 17 00:00:00 2001
>> From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Date: Wed, 3 Jun 2009 02:31:21 -0700
>> Subject: [PATCH] cgroup freezer: Add CHECKPOINTING state to safeguard container checkpoint
>>
>> The CHECKPOINTING state prevents userspace from unfreezing tasks until
>> sys_checkpoint() is finished. When doing container checkpoint userspace
>> will do:
>>
>> 	echo FROZEN > /cgroups/my_container/freezer.state
>> 	...
>> 	rc = sys_checkpoint( <pid of container root> );
>>
>> To ensure a consistent checkpoint image userspace should not be allowed
>> to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
>> during checkpoint.
>>
>> "CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkpoint
>> system call. Once in the "CHECKPOINTING" state, the cgroup may not leave until
>> the checkpoint system call is finished and ready to return. Then the
>> freezer state returns to "FROZEN". Writing any new state to freezer.state while
>> checkpointing will return EBUSY. These semantics ensure that userspace cannot
>> unfreeze the cgroup midway through the checkpoint system call.
>>
>> The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoint()
>> make relatively few assumptions about the task that is passed in. However the
>> way they are called in do_checkpoint() assumes that the root of the container
>> is in the same freezer cgroup as all the other tasks that will be
>> checkpointed.
>>
>> Matt Helsley's wrote the original patch.
>>
>> Changlog:
>>   [2009-Jun-03] change cgroup_freezer_{begin,end}_checkpoint() to take a
>>   		struct cgroup_subsys_state pointer
>> 		add struct cgroup_subsys_state *get_task_cgroup_freezer()
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
>>
>> Notes:
>>         As a side-effect this prevents the multiple tasks from entering the
>>                 CHECKPOINTING state simultaneously. All but one will get -EBUSY.
>> ---
>>  Documentation/cgroups/freezer-subsystem.txt |   10 ++
>>  include/linux/freezer.h                     |   10 ++
>>  kernel/cgroup_freezer.c                     |  149 +++++++++++++++++++--------
>>  3 files changed, 127 insertions(+), 42 deletions(-)
>>
>> diff --git a/Documentation/cgroups/freezer-subsystem.txt b/Documentation/cgroups/freezer-subsystem.txt
>> index 41f37fe..92b68e6 100644
>> --- a/Documentation/cgroups/freezer-subsystem.txt
>> +++ b/Documentation/cgroups/freezer-subsystem.txt
>> @@ -100,3 +100,13 @@ things happens:
>>  		and returns EINVAL)
>>  	3) The tasks that blocked the cgroup from entering the "FROZEN"
>>  		state disappear from the cgroup's set of tasks.
>> +
>> +When the cgroup freezer is used to guard container checkpoint operations the
>> +freezer.state may be "CHECKPOINTING". "CHECKPOINTING" can only be set on a
>> +"FROZEN" cgroup using the checkpoint system call. Once in the "CHECKPOINTING"
>> +state, the cgroup may not leave until the checkpoint system call returns the
>> +freezer state to "FROZEN". Writing any new state to freezer.state while
>> +checkpointing will return EBUSY. These semantics ensure that userspace cannot
>> +unfreeze the cgroup midway through the checkpoint system call. Note that,
>> +unlike "FROZEN" and "FREEZING", there is no corresponding "CHECKPOINTED"
>> +state.
>> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
>> index da7e52b..1402911 100644
>> --- a/include/linux/freezer.h
>> +++ b/include/linux/freezer.h
>> @@ -64,12 +64,22 @@ extern bool freeze_task(struct task_struct *p, bool sig_only);
>>  extern void cancel_freezing(struct task_struct *p);
>>
>>  #ifdef CONFIG_CGROUP_FREEZER
>> +struct cgroup_subsys_state;
>>  extern int cgroup_freezing_or_frozen(struct task_struct *task);
>> +extern struct cgroup_subsys_state *get_task_cgroup_freezer(struct task_struct *task);
>> +extern int cgroup_freezer_begin_checkpoint(struct cgroup_subsys_state *css);
>> +extern void cgroup_freezer_end_checkpoint(struct cgroup_subsys_state *css);
>>  #else /* !CONFIG_CGROUP_FREEZER */
>>  static inline int cgroup_freezing_or_frozen(struct task_struct *task)
>>  {
>>  	return 0;
>>  }
>> +static inline int cgroup_freezer_begin_checkpoint(struct task_struct *task)
>> +{
>> +	return -ENOTSUPP;
>> +}
>> +static inline void cgroup_freezer_end_checkpoint(struct task_struct *task)
>> +{}
> 
> With CONFIG_CHECKPOINT depending on CONFIG_FREEZER I don't see why these
> empty definitions are needed. Maybe it's just too late in the evening...
> 
>>  #endif /* !CONFIG_CGROUP_FREEZER */
>>
>>  /*
>> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
>> index 05795b7..4790fb9 100644
>> --- a/kernel/cgroup_freezer.c
>> +++ b/kernel/cgroup_freezer.c
>> @@ -25,6 +25,7 @@ enum freezer_state {
>>  	CGROUP_THAWED = 0,
>>  	CGROUP_FREEZING,
>>  	CGROUP_FROZEN,
>> +	CGROUP_CHECKPOINTING,
>>  };
>>
>>  struct freezer {
>> @@ -47,6 +48,18 @@ static inline struct freezer *task_freezer(struct task_struct *task)
>>  			    struct freezer, css);
>>  }
>>
>> +struct cgroup_subsys_state *get_task_cgroup_freezer(struct task_struct *task)
>> +{
>> +	struct cgroup_subsys_state *css;
>> +
>> +	task_lock(task);
>> +	css = task_subsys_state(task, freezer_subsys_id);
>> +	css_get(css); /* make sure freezer doesn't go away */
>> +	task_unlock(task);
>> +
>> +	return css;
>> +}
> 
> Seems like there should be a better way to do this than grabbing
> this reference. I'd prefer to just introduce:
> 
> int in_same_cgroup_freezer(struct task_struct *task1, 
> 				struct task_struct *task2);
> 
> In the external checkpoint case the root task is frozen and hence cannot
> change cgroups.

Yeah, you and Serge are right. This reference is not well justified.
So we can revert this change and only add in_same_cgroup_freezer().

I'll change it now in ckpt-v16-dev. Are you going to resubmit the
patchset ?  If you leave out the part that adds the calls to begin
and end a checkpoint, it would be relevant regardless of the c/r
patchset in question.

Thanks,

Oren.
