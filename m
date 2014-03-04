From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: missing rcu read lock around task_css_set
Date: Tue, 04 Mar 2014 12:20:45 -0500
Message-ID: <53160B6D.8020501@oracle.com>
References: <1393729211-937-1-git-send-email-sasha.levin@oracle.com>
	<20140303223327.GB26523@mtj.dyndns.org>
	<5315057F.3030602@oracle.com>
	<20140303224505.GE26523@mtj.dyndns.org> <53150989.70307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53150989.70307-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/03/2014 06:00 PM, Sasha Levin wrote:
> On 03/03/2014 05:45 PM, Tejun Heo wrote:
>> On Mon, Mar 03, 2014 at 05:43:11PM -0500, Sasha Levin wrote:
>>> On 03/03/2014 05:33 PM, Tejun Heo wrote:
>>>> On Sat, Mar 01, 2014 at 10:00:11PM -0500, Sasha Levin wrote:
>>>>> rcu read lock should be held when calling and working with task_css_set.
>>>>>
>>>>> This patch also fixes a related lockdep warning.
>>>>
>>>> Hmmm... PF_EXITING should be visible at that point and cset can't
>>>> change anymore.  We prolly need to update lockdep annotation rather
>>>> than adding spurious rcu locking around it.  Against which branch is
>>>> it?  Can you please post the lockdep warning?
>>>
>>> I see it on -next.
>>
>> I think the right thing to do is using task_css_set_check() with
>> PF_EXITING check and add comment explaining that cset can no longer
>> change.  Can you please write up a patch?
>
> Hrm... there is a PF_EXITING check there already:
>
>      #define task_css_set_check(task, __c)            \
>          rcu_dereference_check((task)->cgroups,        \
>          lockdep_is_held(&cgroup_mutex) ||        \
>          lockdep_is_held(&css_set_rwsem) ||        \
>          ((task)->flags & PF_EXITING) || (__c))
>
> I see it's not happening on Linus's master so I'll run a bisection to figure out what broke it.

Hi Tejun,

It bisects down to your patch: "cgroup: drop task_lock() protection around task->cgroups". I'll
look into it later unless it's obvious to you.


Thanks,
Sasha
