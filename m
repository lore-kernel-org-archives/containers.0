From: "Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] signals: kill(-1) should only signal processes in
	the same namespace
Date: Wed, 23 Jul 2008 18:09:40 +0200 (CEST)
Message-ID: <57249.192.168.101.12.1216829380.squirrel@intranet>
References: <487F5D6B.1090007@hozac.com> <20080723143411.GA2905@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080723143411.GA2905-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 07/17, Daniel Hokka Zakrisson wrote:
>>
>> +int task_in_pid_ns(struct task_struct *tsk, struct pid_namespace *ns)
>> +{
>> +	struct pid *pid = task_pid(tsk);
>> +
>> +	if (!pid)
>> +		return 0;
>> +
>> +	if (pid->level < ns->level)
>> +		return 0;
>> +
>> +	if (pid->numbers[ns->level].ns != ns)
>> +		return 0;
>> +
>> +	return 1;
>> +}
>> +
>>  static __init int pid_namespaces_init(void)
>>  {
>>  	pid_ns_cachep = KMEM_CACHE(pid_namespace, SLAB_PANIC);
>> diff --git a/kernel/signal.c b/kernel/signal.c
>> index 6c0958e..93713a5 100644
>> --- a/kernel/signal.c
>> +++ b/kernel/signal.c
>> @@ -1145,7 +1145,8 @@ static int kill_something_info(int sig, struct
>> siginfo *info, int pid)
>>  		struct task_struct * p;
>>
>>  		for_each_process(p) {
>> -			if (p->pid > 1 && !same_thread_group(p, current)) {
>> +			if (p->pid > 1 && !same_thread_group(p, current) &&
>> +			    task_in_pid_ns(p, current->nsproxy->pid_ns)) {
>>  				int err = group_send_sig_info(sig, info, p);
>>  				++count;
>>  				if (err != -EPERM)
>
> Do we really need all these complications? Afaics, we can make
> a simpler patch,
>
> 	--- kernel/signal.c
> 	+++ kernel/signal.c
> 	@@ -1136,7 +1136,7 @@ static int kill_something_info(int sig,
> 			struct task_struct * p;
>
> 			for_each_process(p) {
> 	-			if (p->pid > 1 && !same_thread_group(p, current)) {
> 	+			if (task_pid_vnr(p) > 1 && !same_thread_group(p, current)) {
> 					int err = group_send_sig_info(sig, info, p);
> 					++count;
> 					if (err != -EPERM)
>
>
> task_pid_vnr(p) returns 0 if "p" is not visible from the current's
> namespace. "> 1" ensures we don't kill the child reaper as well.
>
> No?
>
> Oleg.

You are absolutely right, that is sufficient and much cleaner.

-- 
Daniel Hokka Zakrisson
