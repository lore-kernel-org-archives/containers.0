From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 15/15] Hooks over the code to show correct values to user
Date: Mon, 30 Jul 2007 10:49:10 +0400
Message-ID: <46AD89E6.1030607@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B6AD.4000307@openvz.org>
	<20070729143136.GH120@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070729143136.GH120-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
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
>> int
>> kill_proc(pid_t pid, int sig, int priv)
>> {
>> -	return kill_proc_info(sig, __si_special(priv), pid);
>> +	int ret;
>> +
>> +	rcu_read_lock();
>> +	ret = kill_pid_info(sig, __si_special(priv), find_pid(pid));
>> +	rcu_read_unlock();
>> +	return ret;
>> }
> 
> I think this is wrong. kill_proc() should behave the same as kill_proc_info(),
> so this change is not needed. With this patch they use different namespaces
> to find the task, this is not consistent.

Actually, callers of this use tsk->pid (global pid) as an argument, so
find_vpid() might return wrong value.

> (sadly, this patch is huge, very difficult to review).

This is *very* huge, but all it does is just replace tsk->pid, find_task_by_pid,
pd_nr, etc with appropriate task_pid_nr(), pid_nr_ns() and find_task_by_vpid() etc.

> Oleg.

Thanks,
Pavel
