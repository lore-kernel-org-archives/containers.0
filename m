From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH] Make access to taks's nsproxy liter
Date: Thu, 09 Aug 2007 11:09:55 +0400
Message-ID: <46BABDC3.9090608@openvz.org>
References: <46B9E321.6070602@openvz.org> <20070808163757.GA578@tv-sign.ru>
	<m14pjac61z.fsf@ebiederm.dsl.xmission.com>
	<20070808171955.GA655@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070808171955.GA655-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 08/08, Eric W. Biederman wrote:
>> Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:
>>
>>> On 08/08, Pavel Emelyanov wrote:
>>>> +void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
>>>> +{
>>>> +	struct nsproxy *ns;
>>>> +
>>>> +	might_sleep();
>>>> +
>>>> +	ns = p->nsproxy;
>>>> +	if (ns == new)
>>>> +		return;
>>>> +
>>>> +	if (new)
>>>> +		get_nsproxy(new);
>>>> +	rcu_assign_pointer(p->nsproxy, new);
>>>> +
>>>> +	if (ns && atomic_dec_and_test(&ns->count)) {
>>>> +		/*
>>>> +		 * wait for others to get what they want from this
>>>> +		 * nsproxy. cannot release this nsproxy via the
>>>> +		 * call_rcu() since put_mnt_ns will want to sleep
>>>> +		 */
>>>> +		synchronize_rcu();
>>>> +		free_nsproxy(ns);
>>>> +	}
>>>> +}
>>> (I may be wrong, Paul cc'ed)
>>>
>>> This is correct with the current implementation of RCU, but strictly speaking,
>>> we can't use synchronize_rcu() here, because write_lock_irq() doesn't imply
>>> rcu_read_lock() in theory.

void __lockfunc _write_lock(rwlock_t *lock)
{
        preempt_disable();
        rwlock_acquire(&lock->dep_map, 0, 0, _RET_IP_);
        LOCK_CONTENDED(lock, _raw_write_trylock, _raw_write_lock);
}

preempt_disable == rcu_read_lock() due to
#define rcu_read_lock() \
        do { \
                preempt_disable(); \
                __acquire(RCU); \
        } while(0)

so currently this is enough to write_lock()

>> But we should be able to do:
>>
>> write_lock_irq();
>> rcu_read_lock();
>> 	muck with other tasks nsproxy.
>> rcu_read_unlock();
>> write_unlock_irq();
>>
>> Which would make rcu fine.
> 
> Yes sure. I just meant that the patch looks incomplete. But we didn't
> hear Paul yet, perhaps I'm just wrong.
> 
>> The real locking we have is that only a task is allowed to modify it's
>> own nsproxy pointer.  Other processes are not.
>>
>> The practical question is how do we enable other processes to read
>> a particular tasks nsproxy or something pointed to by it?
> 
> task_lock(). The only problem we can't take it in do_notify_parent(),
> but if we add read_lock(tasklist) to sys_unshare, we can safely access
> ->parent->nsproxy.

we can safely access parent's nsproxy with this patch like this:

rcu_read_lock();
nsproxy = task_nsproxy(p->parent);
BUG_ON(nsproxy == NULL); /* parent should reparent us before exiting nsproxy */
pid_ns = nsproxy->pid_ns;
...
rcu_read_unlock();


> 
> Oleg.
> 
> 
