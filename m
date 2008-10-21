From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/4] freezer_cg: remove redundant check in
	freezer_can_attach()
Date: Tue, 21 Oct 2008 17:29:23 +0800
Message-ID: <48FDA0F3.2070306__33709.4244234779$1224581511$gmane$org@cn.fujitsu.com>
References: <48FD26F5.1070809@cn.fujitsu.com>
	<48FD273F.3040505@cn.fujitsu.com> <48FD85A2.8090605@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FD85A2.8090605-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Li Zefan wrote:
>> It is sufficient to check if @task is frozen, and no need to check if
>> the original freezer is frozen.
> 
> hmm, a task being frozen does not mean that its freezer cgroup is 
> frozen.

If a task has being frozen, then can_attach() returns -EBUSY at once.
If a task isn't frozen, then we have orig_freezer->state == THAWED.

So we need to check the state of the task only.

> So the extra check seems valid but looking at the comment :
> 
> 	/*
> 	 * The call to cgroup_lock() in the freezer.state write method prevents
> 	 * a write to that file racing against an attach, and hence the
> 	 * can_attach() result will remain valid until the attach completes.
> 	 */
> 	static int freezer_can_attach(struct cgroup_subsys *ss,
> 
> how do we know that the task_freezer(task), which is not protected by
> the cgroup_lock(), is not going to change its state to CGROUP_FROZEN 
> it looks racy.
> 

Since freezer_can_attach() is called by cgroup core with cgroup_lock held, there is
no race with task attaching and state changing.

> C.
> 
>> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  kernel/cgroup_freezer.c |   16 +++++++---------
>>  1 files changed, 7 insertions(+), 9 deletions(-)
>>
>> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
>> index 7f54d1c..6fadafe 100644
>> --- a/kernel/cgroup_freezer.c
>> +++ b/kernel/cgroup_freezer.c
>> @@ -162,9 +162,13 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
>>  			      struct task_struct *task)
>>  {
>>  	struct freezer *freezer;
>> -	int retval;
>>  
>> -	/* Anything frozen can't move or be moved to/from */
>> +	/*
>> +	 * Anything frozen can't move or be moved to/from.
>> +	 *
>> +	 * Since orig_freezer->state == FROZEN means that @task has been
>> +	 * frozen, so it's sufficient to check the latter condition.
>> +	 */
>>  
>>  	if (is_task_frozen_enough(task))
>>  		return -EBUSY;
>> @@ -173,13 +177,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
>>  	if (freezer->state == CGROUP_FROZEN)
>>  		return -EBUSY;
>>  
>> -	retval = 0;
>> -	task_lock(task);
>> -	freezer = task_freezer(task);
>> -	if (freezer->state == CGROUP_FROZEN)
>> -		retval = -EBUSY;
>> -	task_unlock(task);
>> -	return retval;
>> +	return 0;
>>  }
>>  
>>  static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
> 
> 
