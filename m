From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH] Make access to taks's nsproxy liter
Date: Thu, 09 Aug 2007 11:12:19 +0400
Message-ID: <46BABE53.6050604@openvz.org>
References: <46B9E321.6070602@openvz.org>
	<20070808164854.GB28455@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070808164854.GB28455-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

[snip]

>> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
>> index 525d8fc..74f21fe 100644
>> --- a/include/linux/nsproxy.h
>> +++ b/include/linux/nsproxy.h
>> @@ -32,8 +32,14 @@ struct nsproxy {
>> };
>> extern struct nsproxy init_nsproxy;
>>
>> +static inline struct nsproxy *task_nsproxy(struct task_struct *tsk)
>> +{
>> +	return rcu_dereference(tsk->nsproxy);
>> +}
> 
> Looks like a very nice cleanup as well.  But please add a comment
> above task_nsproxy() that it must be called under rcu_read_lock()
> or task_lock(task) (though I'll admit the rcu_dereference may make that
> obvious)

I will, but I think that rcu_dereference implies this. Anyway.

[snip]

>> +	if (ns == new)
>> +		return;
>> +
>> +	if (new)
>> +		get_nsproxy(new);
>> +	rcu_assign_pointer(p->nsproxy, new);
>> +
>> +	if (ns && atomic_dec_and_test(&ns->count)) {
>> +		/*
>> +		 * wait for others to get what they want from this
>> +		 * nsproxy. cannot release this nsproxy via the
>> +		 * call_rcu() since put_mnt_ns will want to sleep
>> +		 */
>> +		synchronize_rcu();
>> +		free_nsproxy(ns);
>> +	}
>> +}
> 
> Also a comment above switch_task_namespaces() that it must be called
> with task_lock held.

no! no locks here! free_nsproxy() may sleep when putting mnt_ns and
maybe some other. see - there's a hunk in sys_unshare that move the
task_lock() after switch_task_namespaces().

> thanks,
> -serge
