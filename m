From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroups: enhance task_cgroup()
Date: Sat, 22 Nov 2008 10:23:33 +0800
Message-ID: <49276D25.5020001__10608.2517806955$1227320924$gmane$org@cn.fujitsu.com>
References: <4926762A.7000602@cn.fujitsu.com>
	<6599ad830811211058q3fe12e5coa62436e777b60f1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830811211058q3fe12e5coa62436e777b60f1a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Fri, Nov 21, 2008 at 12:49 AM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> task_cgroup() calls cgroup_subsys_state().
> 
> No, it calls task_subsys_state()
> 
>> and we must use rcu_read_lock() to protect cgroup_subsys_state().
>> so we must use rcu_read_lock() to protect task_cgroup().
>>
>> but it'll not so friendly to caller: the callers of task_cgroup() have
>> held cgroup_lock(). it means that struct cgroup will not be freed.
>>
>> So this patch add rcu_read_lock() in task_cgroup() to enhance task_cgroup().
>> And we do NOT NEED FIX task_cgroup()'s callers, and cgroup_lock()
>> can protect task_cgroup().
> 
> Is there a reason to add an implicit rcu_read_lock() in task_cgroup()
> and not directly in task_subsys_state() ?

Yes.

The caller have held the cgroup_lock() when it calls task_cgroup().
After we add an implicit rcu_read_lock() in task_cgroup(),
we don't need rcu_read_lock()/task_lock() for using task_cgroup().

For cgroup_exit() will change tsk->cgroups, if we don't
add an implicit rcu_read_lock() in task_cgroup(), we have to fix 7
places which using task_cgroup().


task_subsys_state() is different, it is used in fast path,
If we add an implicit rcu_read_lock() in task_subsys_state(),
we still need rcu_read_lock()/task_lock() for using it,
so it's redundant rcu_read_lock(), and slower the fast path a little.


Lai.

> 
> Paul
> 
