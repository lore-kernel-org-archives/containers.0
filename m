From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH] Cleanup the new thread's creation
Date: Mon, 27 Aug 2007 10:43:24 +0400
Message-ID: <46D2728C.6080907@openvz.org>
References: <46CED326.3030606@openvz.org> <20070825165031.GA2644@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070825165031.GA2644-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
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
> On 08/24, Pavel Emelyanov wrote:
>> The major differences of creating a new thread from creating a
>> new process is that
>>
>> 1. newbie's tgid is set to leader's
>> 2. newbie's leader is set to leader
>> 3. newbie is added to leader's thread_list
> 
> (Surely, the are many other major differences, but from the pids virtualization
>  POV - yes ;)
> 
>> +static void setup_new_thread(struct task_struct *thr, struct task_struct 
>> *leader)
>> +{
>> +	thr->tgid = leader->tgid;
>> +	thr->group_leader = leader;
>> +	list_add_tail_rcu(&thr->thread_group, &leader->thread_group);
>> +}
> 
> Imho, this name is a bit "too generic". Not that I can suggest something
> better... copy_sub_thread/copy_group_leader ?
> 
>> @@ -1147,9 +1161,6 @@ static struct task_struct *copy_process(
>> 	}
>>
>> 	p->pid = pid_nr(pid);
>> -	p->tgid = p->pid;
>> -	if (clone_flags & CLONE_THREAD)
>> -		p->tgid = current->tgid;
> 
> I agree, it is absoulutely not clear why should we set ->tgid here, and it
> would be nice to consolidate "if (CLONE_THREAD)" checks, but do we really
> need the helpers above? There are very simple, and have the only one caller.
> Sometimes it is good to see what's going on without pressing C-]
> 
> Not that I against this patch, just I'm not sure it really simplifies things.
> Perhaps I missed something else you have in mind.

Me too, but while cleaning up the pid_t usage over the kernel I found
this place to be one of the most difficult from "how to make it better"
point of view. We need to hide the pid/tgid explicit usage somehow, but 
the problem is that pid and tgid are set in this place and de_thread() 
only and making helpers like set_task_tgid() doesn't sound reasonable.

> Oleg.
> 
> 

Thanks,
Pavel
