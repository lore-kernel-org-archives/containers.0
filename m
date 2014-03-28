From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: missing rcu read lock around task_css_set
Date: Fri, 28 Mar 2014 10:48:17 +0800
Message-ID: <5334E2F1.3040809@huawei.com>
References: <1393729211-937-1-git-send-email-sasha.levin@oracle.com>
	<20140303223327.GB26523@mtj.dyndns.org>
	<5315057F.3030602@oracle.com>
	<20140303224505.GE26523@mtj.dyndns.org>
	<53150989.70307@oracle.com> <53160B6D.8020501@oracle.com>
	<20140304194741.GA2204@htj.dyndns.org>
	<53167662.5000801@huawei.com> <5334452D.4080200@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5334452D.4080200-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014/3/27 23:35, Sasha Levin wrote:
> On 03/04/2014 07:57 PM, Li Zefan wrote:
>> On 2014/3/5 3:47, Tejun Heo wrote:
>>> On Tue, Mar 04, 2014 at 12:20:45PM -0500, Sasha Levin wrote:
>>>>> Hrm... there is a PF_EXITING check there already:
>>>>>
>>>>>      #define task_css_set_check(task, __c)            \
>>>>>          rcu_dereference_check((task)->cgroups,        \
>>>>>          lockdep_is_held(&cgroup_mutex) ||        \
>>>>>          lockdep_is_held(&css_set_rwsem) ||        \
>>>>>          ((task)->flags & PF_EXITING) || (__c))
>>>>>
>>>>> I see it's not happening on Linus's master so I'll run a bisection to figure out what broke it.
>>>>
>>>> Hi Tejun,
>>>>
>>>> It bisects down to your patch: "cgroup: drop task_lock() protection
>>>> around task->cgroups". I'll look into it later unless it's obvious
>>>> to you.
>>>
>>> Hmmm... maybe I'm confused and PF_EXITING is not set there and
>>> task_lock was what held off the lockdep warning.  Confused....
>>>
>>
>> Because this cgroup_exit() is called in a failure path in copy_process().
> 
> It seems there was no conclusion here and it still happens in -next, anything
> we can do about it?
> 

I'll send a patch to fix it. Thanks!
