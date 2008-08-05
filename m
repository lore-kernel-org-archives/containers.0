From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Tue, 05 Aug 2008 10:23:04 +0530
Message-ID: <4897DCB0.4020105@linux.vnet.ibm.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<489752AA.9060500@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0808042226430.4300@blonde.site>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808042226430.4300-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
> On Tue, 5 Aug 2008, Balbir Singh wrote:
>> Hugh Dickins wrote:
>> [snip]
>>> BUG: unable to handle kernel paging request at 6b6b6b8b
>>> IP: [<7817078f>] memrlimit_cgroup_uncharge_as+0x18/0x29
>>> Pid: 22500, comm: swapoff Not tainted (2.6.26-rc8-mm1 #7)
>>>  [<78161323>] ? exit_mmap+0xaf/0x133
>>>  [<781226b1>] ? mmput+0x4c/0xba
>>>  [<78165ce3>] ? try_to_unuse+0x20b/0x3f5
>>>  [<78371534>] ? _spin_unlock+0x22/0x3c
>>>  [<7816636a>] ? sys_swapoff+0x17b/0x37c
>>>  [<78102d95>] ? sysenter_past_esp+0x6a/0xa5
>> I am unable to reproduce the problem,
> 
> Me neither, I've spent many hours trying 2.6.27-rc1-mm1 and then
> back to 2.6.26-rc8-mm1.  But I've been SO stupid: saw it originally
> on one machine with SLAB_DEBUG=y, have been trying since mostly on
> another with SLUB_DEBUG=y, but never thought to boot with
> slub_debug=P,task_struct until now.
> 

Unfortunately, I've not tried on 32 bit and not at all with SLAB_DEBUG=y. I'll
give the latter a trial run and see what I get.

>> but I do have an initial hypothesis
>>
>> CPU0					CPU1
>> 					try_to_unuse
>> task 1 stars exiting			look at mm = task1->mm
>> ..					increment mm_users
>> task 1 exits
>> mm->owner needs to be updated, but
>> no new owner is found
>> (mm_users > 1, but no other task
>> has task->mm = task1->mm)
>> mm_update_next_owner() leaves
>>
>> grace period
>> 					user count drops, call mmput(mm)
>> task 1 freed
>> 					dereferencing mm->owner fails
> 
> Yes, that looks right to me: seems obvious now.  I don't think your
> careful alternation of CPU0/1 events at the end matters: the swapoff
> CPU simply dereferences mm->owner after that task has gone.
> 
> (That's a shame, I'd always hoped that mm->owner->comm was going to
> be good for use in mm messages, even when tearing down the mm.)
> 

The problem we have is that tasks are independent of mm_struct's (in some ways)
and are associated almost like a database associates two entities through keys.

>> I do have a potential solution in mind, but I want to make sure my
>> hypothesis is correct.
> 
> It seems wrong that memrlimit_cgroup_uncharge_as should be called
> after mm->owner may have been changed, even if it's to something safe.
> But I forget the mm/task exit details, surely they're tricky.
> 

The fix would be to uncharge when a new owner can no longer be found (I am yet
to code/test it though).

> By the way, is the ordering in mm_update_next_owner the best?
> Would there be less movement if it searched amongst siblings before
> it searched amongst children?  Ought it to make a first pass trying
> to stay within the same cgroup?

Yes, we need to make a first pass at keeping it in the same cgroup. You might be
right about the sibling optimization.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
