From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroup: remove tasklist_lock from cgroup_attach_proc
Date: Fri, 23 Dec 2011 10:40:28 +0800
Message-ID: <4EF3EA1C.4000806__36577.250812161$1324607912$gmane$org@cn.fujitsu.com>
References: <1324601873-20773-1-git-send-email-msb@chromium.org>
	<20111223022742.GA28309@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111223022742.GA28309-oHC15RC7JGTpAmv0O++HtFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 1042b3c..032139d 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -2102,21 +2102,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>>  	if (retval)
>>  		goto out_free_group_list;
>>  
>> -	/* prevent changes to the threadgroup list while we take a snapshot. */
>> -	read_lock(&tasklist_lock);
>> -	if (!thread_group_leader(leader)) {
>> -		/*
>> -		 * a race with de_thread from another thread's exec() may strip
>> -		 * us of our leadership, making while_each_thread unsafe to use
>> -		 * on this task. if this happens, there is no choice but to
>> -		 * throw this task away and try again (from cgroup_procs_write);
>> -		 * this is "double-double-toil-and-trouble-check locking".
>> -		 */
>> -		read_unlock(&tasklist_lock);
>> -		retval = -EAGAIN;
>> -		goto out_free_group_list;
>> -	}
>> -
>>  	tsk = leader;
>>  	i = 0;
>>  	do {
>> @@ -2145,7 +2130,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>>  	group_size = i;
>>  	tset.tc_array = group;
>>  	tset.tc_array_len = group_size;
>> -	read_unlock(&tasklist_lock);
> 
> You still need rcu_read_lock()/rcu_read_unlock() around
> 	do {
> 
> 	} while_each_thread()
> 
> because threadgroup_lock() doesn't lock the part that remove a thread from
> its group on exit.
> 

and inside rcu critical section, you can't call kmalloc(GFP_KERNEL)!!
