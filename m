From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix incorrect using rcu_dereference() in
	cgroup_subsys_state()
Date: Mon, 24 Nov 2008 12:45:49 -0800
Message-ID: <6599ad830811241245v3b16853dw4c3abd0e36d40ea6__27647.1500438221$1227559703$gmane$org@mail.gmail.com>
References: <4926761E.8030002@cn.fujitsu.com>
	<6599ad830811211007s43f0c683s9d56e0aed3af938@mail.gmail.com>
	<49277AF7.3090000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49277AF7.3090000-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 21, 2008 at 7:22 PM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> No, if you use cgroup_lock() you can do this for any task.
>> cgroup_lock() is the cgroups equivalent of the BKL, and definitely
>> prevents all task movement between groups.
>
> cgroup_exit() will defeat you.

Ah, good point. You should mention that in your description of the
locking rules. But it would be nice if we could get rid of that
restriction.

Paul

>
>>>  static inline struct cgroup_subsys_state *task_subsys_state(
>>>        struct task_struct *task, int subsys_id)
>>>  {
>>> -       return rcu_dereference(task->cgroups->subsys[subsys_id]);
>>> +       /*
>>> +        * ->subsys[subsys_id] are read-only data, so we do not need
>>> +        * rcu_dereference() for it.
>>> +        */
>>> +       return rcu_dereference(task->cgroups)->subsys[subsys_id];
>>>  }
>>
>> Change looks OK but I think we can lose the additional comment.
>>
>> Paul
>>
>>
>>
>
> I just remembered I had deferred Li Zefan's patch.
> (I'm also RCU developer, I had been writing CGROUP VS RCU then,
> I thought these patches should be sent together, So I deferred his patch)
>
> From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Date: Mon, 25 Aug 2008 11:05:28 +0800
> Subject: [PATCH] cgroup: fix wrong rcu_dereference()
>
> It is tsk->cgroups which is protected by RCU.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  include/linux/cgroup.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index c98dd7c..d911dc7 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -355,7 +355,7 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
>  static inline struct cgroup_subsys_state *task_subsys_state(
>        struct task_struct *task, int subsys_id)
>  {
> -       return rcu_dereference(task->cgroups->subsys[subsys_id]);
> +       return rcu_dereference(task->cgroups)->subsys[subsys_id];
>  }
>
>  static inline struct cgroup* task_cgroup(struct task_struct *task,
>
>
