From: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 12/15] (RFC) IPC/semaphores: make use of
 RCU to free the sem_undo_list
Date: Thu, 31 Jan 2008 10:52:08 +0100
Message-ID: <47A19A48.4000005__9740.19556674666$1201773305$gmane$org@bull.net>
References: <20080129160229.612172683@bull.net>
	<20080129162131.743970100@bull.net>
	<20080130212650.GA8945@sergelap.austin.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080130212650.GA8945-6s5zFf/epYLPQpwDFJZrxFMas7LaWZ9n@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting pierre.peiffer-6ktuUTfB/bM@public.gmane.org (pierre.peiffer-6ktuUTfB/bM@public.gmane.org):
>> From: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
>>
>> Today, the sem_undo_list is freed when the last task using it exits.
>> There is no mechanism in place, that allows a safe concurrent access to
>> the sem_undo_list of a target task and protects efficiently against a
>> task-exit.
>>
>> That is okay for now as we don't need this.
>>
>> As I would like to provide a /proc interface to access this data, I need
>> such a safe access, without blocking the target task if possible. 
>>
>> This patch proposes to introduce the use of RCU to delay the real free of
>> these sem_undo_list structures. They can then be accessed in a safe manner
>> by any tasks inside read critical section, this way:
>>
>> 	struct sem_undo_list *undo_list;
>> 	int ret;
>> 	...
>> 	rcu_read_lock();
>> 	undo_list = rcu_dereference(task->sysvsem.undo_list);
>> 	if (undo_list)
>> 		ret = atomic_inc_not_zero(&undo_list->refcnt);
>> 	rcu_read_unlock();
>> 	...
>> 	if (undo_list && ret) {
>> 		/* section where undo_list can be used quietly */
>> 		...
>> 	}
>> 	...
> 
> And of course then
> 
> 	if (atomic_dec_and_test(&undo_list->refcnt))
> 		free_semundo_list(undo_list);
> 
> by that task.
> 

I will precise this too.

>> Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
> 
> Looks correct in terms of locking/refcounting.
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 

Thanks !

-- 
Pierre
