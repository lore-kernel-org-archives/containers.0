From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: 3.9-rc1 NULL pointer crash at find_pid_ns
Date: Thu, 07 Mar 2013 13:14:10 -0500
Message-ID: <5138D8F2.5020900@oracle.com>
References: <611667212.10748821.1362649031475.JavaMail.root@redhat.com>
	<513860E8.4080807@huawei.com> <876213wmwt.fsf@xmission.com>
	<5138D001.8000409@oracle.com>
	<1362678371.15793.218.camel@edumazet-glaptop>
	<5138D377.6040406@oracle.com> <87boavrspd.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87boavrspd.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/07/2013 01:05 PM, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org wrote:
> Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> writes:
> 
>> On 03/07/2013 12:46 PM, Eric Dumazet wrote:
>>> On Thu, 2013-03-07 at 12:36 -0500, Sasha Levin wrote:
>>>
>>>> Looks like the hlist change is probably the issue, though it specifically
>>>> uses:
>>>>
>>>> 	#define hlist_entry_safe(ptr, type, member) \
>>>>         	(ptr) ? hlist_entry(ptr, type, member) : NULL
>>>>
>>>> I'm still looking at the code in question and it's assembly, but I can't
>>>> figure out what's going wrong. I was also trying to see what's so special
>>>> about this loop in find_pid_ns as opposed to the rest of the kernel code
>>>> that uses hlist_for_each_entry_rcu() but couldn't find out why.
>>>>
>>>> Is it somehow possible that if we rcu_dereference_raw() the same thing twice
>>>> inside the same rcu_read_lock() section we'll get different results? That's
>>>> really the only reason for this crash that comes to mind at the moment, very
>>>> unlikely - but that's all I have right now.
>>>>
>>>
>>> Yep
>>>
>>> #define hlist_entry_safe(ptr, type, member) \
>>> 	(ptr) ? hlist_entry(ptr, type, member) : NULL
>>>
>>> Is not safe, as ptr can be evaluated twice, and thats not good at all...
>>
>> ptr is being evaluated twice, but in this case this is an
>> rcu_dereference_raw() value within the same rcu_read_lock() section.
>>
>> Is it still problematic?
> 
> Definitely.
> 
> Head in this instance the expression: &pid_hash[pid_hashfn(nr, ns)]
> 
> And the crash clearly shows that when hilst_entry is being evaluated the
> HEAD is NULL.

Okay, I'm even more confused now.

The expression in question is:

	hlist_entry_safe(rcu_dereference_bh(hlist_first_rcu(head)))

You're saying that "rcu_dereference_bh(hlist_first_rcu(head))" can change between
the two evaluations we do. That would mean that 'head' has changed in between, right?

In that case, the list itself has changed - which means that RCU has changed the
list underneath us.

hlist_first_rcu() doesn't have any side-effects, it doesn't modify the list whatsoever,
so the only thing that can change is 'head'. Why is it allowed to change if the list
is protected by RCU?


Thanks,
Sasha
