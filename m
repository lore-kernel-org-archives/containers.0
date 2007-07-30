From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 8/15] Helpers to find the task by its numerical ids
Date: Mon, 30 Jul 2007 10:15:22 +0400
Message-ID: <46AD81FA.10207@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B502.8070606@openvz.org>
	<20070729124045.GG120@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070729124045.GG120-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 07/26, Pavel Emelyanov wrote:
>> +#define find_pid(pid)	find_pid_ns(pid, &init_pid_ns)
> 
> Again, I think find_pid() should use current's active ns, not
> init_pid_ns. Just grep for find_pid/find_task_by_pid.
> 
>> --- linux-2.6.23-rc1-mm1.orig/kernel/pid.c	2007-07-26 16:34:45.000000000 +0400
>> +++ linux-2.6.23-rc1-mm1-7/kernel/pid.c	2007-07-26 16:36:37.000000000 +0400
>> @@ -204,19 +221,20 @@ static void delayed_put_pid(struct rcu_h
>>  	goto out;
>>  }
>>
>> -struct pid * fastcall find_pid(int nr)
>> +struct pid * fastcall find_pid_ns(int nr, struct pid_namespace *ns)
>>  {
>>  	struct hlist_node *elem;
>> -	struct pid *pid;
>> +	struct upid *pnr;
>> +
>> +	hlist_for_each_entry_rcu(pnr, elem,
>> +			&pid_hash[pid_hashfn(nr, ns)], pid_chain)
>> +		if (pnr->nr == nr && pnr->ns == ns)
>                                      ^^^^^^^^^^^^^
> Aha, that is why we need upid->ns.

That's it :)

> I am a bit surprised we don't move the global pid_hash into the
> "struct pid_namespace", this could speedup the search, and we
> don't need upid->ns.

Hm... Worth thinking about, but this hash itself is large enough and
its size depends on the node's number of pages, so we'll have

1. either to make per-namespace hash (much) smaller;
2. or to give (too) many memory for it.

>> -struct pid *find_ge_pid(int nr)
>> +struct pid *find_ge_pid(int nr, struct pid_namespace *ns)
>>  {
>>  	struct pid *pid;
>>
>>  	do {
>> -		pid = find_pid(nr);
>> +		pid = find_pid_ns(nr, ns);
>>  		if (pid)
>>  			break;
>> -		nr = next_pidmap(task_active_pid_ns(current), nr);
>> +		nr = next_pidmap(ns, nr);
>>  	} while (nr > 0);
>>
>>  	return pid;
> 
> This means we should fix the caller, next_tgid(), but this is done
> in 15/15.

Sorry :)

> Oleg.
> 
> 

Thank,
Pavel
