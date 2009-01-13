From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] Relax ns_can_attach checks to allow attaching
	to	grandchild cgroups
Date: Tue, 13 Jan 2009 09:44:36 +0800
Message-ID: <496BF204.3090206@cn.fujitsu.com>
References: <20090106222536.GA25228@eskarina.localdomain.pl>
	<20090112163729.774b5b50.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090112163729.774b5b50.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

>>  /**
>> - * cgroup_is_descendant - see if @cgrp is a descendant of current task's cgrp
>> + * cgroup_is_descendant - see if @cgrp is a descendant of @task's cgrp
>>   * @cgrp: the cgroup in question
>> + * @task: the task in question
>>   *
>> - * See if @cgrp is a descendant of the current task's cgroup in
>> - * the appropriate hierarchy.
>> + * See if @cgrp is a descendant of @task's cgroup in the appropriate
>> + * hierarchy.
>>   *
>>   * If we are sending in dummytop, then presumably we are creating
>>   * the top cgroup in the subsystem.
>>   *
>>   * Called only by the ns (nsproxy) cgroup.
>>   */
>> -int cgroup_is_descendant(const struct cgroup *cgrp)
>> +int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task)
>>  {
>>  	int ret;
>>  	struct cgroup *target;
>> @@ -3125,7 +3126,7 @@ int cgroup_is_descendant(const struct cgroup *cgrp)
>>  		return 1;
>>  
>>  	get_first_subsys(cgrp, NULL, &subsys_id);
>> -	target = task_cgroup(current, subsys_id);
>> +	target = task_cgroup(task, subsys_id);
> 
> What locking prevents *task from vanishing here?
> 

As *task is passed to this function, I think it's the caller's responsibility to
insure this ?

>>  	while (cgrp != target && cgrp!= cgrp->top_cgroup)
>>  		cgrp = cgrp->parent;
>>  	ret = (cgrp == target);
>> diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
>> index 43c2111..890691a 100644
>> --- a/kernel/ns_cgroup.c
>> +++ b/kernel/ns_cgroup.c
>> @@ -35,7 +35,7 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
>>  
>>  /*
>>   * Rules:
>> - *   1. you can only enter a cgroup which is a child of your current
>> + *   1. you can only enter a cgroup which is a descendant of your current
>>   *     cgroup
>>   *   2. you can only place another process into a cgroup if
>>   *     a. you have CAP_SYS_ADMIN
>> @@ -46,21 +46,15 @@ int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
>>  static int ns_can_attach(struct cgroup_subsys *ss,
>>  		struct cgroup *new_cgroup, struct task_struct *task)
>>  {
>> -	struct cgroup *orig;
>> -
>>  	if (current != task) {
>>  		if (!capable(CAP_SYS_ADMIN))
>>  			return -EPERM;
>>  
>> -		if (!cgroup_is_descendant(new_cgroup))
>> +		if (!cgroup_is_descendant(new_cgroup, current))
>>  			return -EPERM;
>>  	}
>>  
>> -	if (atomic_read(&new_cgroup->count) != 0)
>> -		return -EPERM;
>> -
>> -	orig = task_cgroup(task, ns_subsys_id);
> 
> Same question applied to the previous code.
> 

It's called by cgroup core, and cgroup guarantees the task won't vanish. (by get_task_struct)

>> -	if (orig && orig != new_cgroup->parent)
>> +	if (!cgroup_is_descendant(new_cgroup, task))
>>  		return -EPERM;
>>  
>>  	return 0;
>> @@ -78,7 +72,7 @@ static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
>>  
>>  	if (!capable(CAP_SYS_ADMIN))
>>  		return ERR_PTR(-EPERM);
>> -	if (!cgroup_is_descendant(cgroup))
>> +	if (!cgroup_is_descendant(cgroup, current))
>>  		return ERR_PTR(-EPERM);
>>  
>>  	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
