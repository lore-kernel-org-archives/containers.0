From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] pid: sys_wait... fixes (v2)
Date: Thu, 06 Dec 2007 12:11:20 -0700
Message-ID: <m1fxyfsko7.fsf@ebiederm.dsl.xmission.com>
References: <m17ijsv7iu.fsf@ebiederm.dsl.xmission.com>
	<20071206170145.GA10674@tv-sign.ru>
	<m1k5nrsn18.fsf_-_@ebiederm.dsl.xmission.com>
	<20071206184502.GA11752@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071206184502.GA11752-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> (Oleg Nesterov's message of
	"Thu, 6 Dec 2007 21:45:02 +0300")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:

> On 12/06, Eric W. Biederman wrote:
>> 
>> +static struct pid *task_pid_type(struct task_struct *task, enum pid_type
> type)
>> +{
>> +	struct pid *pid = NULL;
>> +	if (type == PIDTYPE_PID)
>> +		pid = task->pids[type].pid;
>> +	else if (type < PIDTYPE_MAX)
>> +		pid = task->group_leader->pids[type].pid;
>> +	return pid;
>> +}
>
> Looks like a useful helper regardless.

Sort of.  We don't have any place else that could use it yet.

>> +static int eligible_child(enum pid_type type, struct pid *pid, int options,
>> +			  struct task_struct *p)
>>  {
>>  	int err;
>> -	struct pid_namespace *ns;
>>  
>> -	ns = current->nsproxy->pid_ns;
>> -	if (pid > 0) {
>> -		if (task_pid_nr_ns(p, ns) != pid)
>> -			return 0;
>> -	} else if (!pid) {
>> -		if (task_pgrp_nr_ns(p, ns) != task_pgrp_vnr(current))
>> -			return 0;
>> -	} else if (pid != -1) {
>> -		if (task_pgrp_nr_ns(p, ns) != -pid)
>> +	if (type < PIDTYPE_MAX) {
>> +		if (task_pid_type(p, type) != pid)
>>  			return 0;
>>  	}
>
> Minor, minor nit.
>
> If type == PIDTYPE_MAX, pid must be == NULL. but task_pid_type(PIDTYPE_PID)
> also returns NULL. So we can just do
>
> 	if (task_pid_type(p, type) != pid)
> 		return 0;
>
> Not that it really makes a difference though.

No.

Your comments are good but I figure this patch is now correct and thus
good enough for me.

Eric
