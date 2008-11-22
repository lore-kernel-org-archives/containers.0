From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix incorrect using rcu_dereference() in
	cgroup_subsys_state()
Date: Sat, 22 Nov 2008 11:22:31 +0800
Message-ID: <49277AF7.3090000__39726.3442668647$1227324574$gmane$org@cn.fujitsu.com>
References: <4926761E.8030002@cn.fujitsu.com>
	<6599ad830811211007s43f0c683s9d56e0aed3af938@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830811211007s43f0c683s9d56e0aed3af938-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
>> It's task->cgroups protected by RCU. and struct css_set.subsys[subsys_id]
>> is readonly(after init). so we don't need rcu_dereference() for
>> struct css_set.subsys[subsys_id].
>>
>> the ways using cgroup_subsys_state() safely:
>>
>> #1:
>> rcu_read_lock() / task_lock();
>> c = cgroup_subsys_state(tsk, id);
>> use c;
>> rcu_read_unlock() / task_unlock();
> 
> You need to qualify that with the fact that if you're just using RCU,
> the subsys state may no longer be the state for the task that you're
> interested in, since we don't guarantee that the task won't move
> directly after you read the state pointer.
> 
>>
>> #2: use cgroup_lock() for _current_ task.
>> cgroup_lock();
>> c = cgroup_subsys_state(current, id);
>> use c;
>> cgroup_unlock();
> 
> No, if you use cgroup_lock() you can do this for any task.
> cgroup_lock() is the cgroups equivalent of the BKL, and definitely
> prevents all task movement between groups.

cgroup_exit() will defeat you.

>>  static inline struct cgroup_subsys_state *task_subsys_state(
>>        struct task_struct *task, int subsys_id)
>>  {
>> -       return rcu_dereference(task->cgroups->subsys[subsys_id]);
>> +       /*
>> +        * ->subsys[subsys_id] are read-only data, so we do not need
>> +        * rcu_dereference() for it.
>> +        */
>> +       return rcu_dereference(task->cgroups)->subsys[subsys_id];
>>  }
> 
> Change looks OK but I think we can lose the additional comment.
> 
> Paul
> 
> 
> 

I just remembered I had deferred Li Zefan's patch.
(I'm also RCU developer, I had been writing CGROUP VS RCU then,
I thought these patches should be sent together, So I deferred his patch)

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Mon, 25 Aug 2008 11:05:28 +0800
Subject: [PATCH] cgroup: fix wrong rcu_dereference()

It is tsk->cgroups which is protected by RCU.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c98dd7c..d911dc7 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -355,7 +355,7 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
 static inline struct cgroup_subsys_state *task_subsys_state(
 	struct task_struct *task, int subsys_id)
 {
-	return rcu_dereference(task->cgroups->subsys[subsys_id]);
+	return rcu_dereference(task->cgroups)->subsys[subsys_id];
 }
 
 static inline struct cgroup* task_cgroup(struct task_struct *task,
