From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: memcg creates an unkillable task in 3.2-rc2
Date: Mon, 29 Jul 2013 01:54:01 -0700
Message-ID: <87ehahg312.fsf@xmission.com>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com> <20130729075939.GA4678@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130729075939.GA4678-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org> (Michal Hocko's message of
	"Mon, 29 Jul 2013 09:59:39 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> writes:

> On Sun 28-07-13 17:42:28, Eric W. Biederman wrote:
>> Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>> 
>> > Hello, Linus.
>> >
>> > This pull request contains two patches, both of which aren't fixes
>> > per-se but I think it'd be better to fast-track them.
>> >
>> Darn.  I was hoping to see a fix for the bug I just tripped over,
>> that results in a process stuck in short term disk wait.
>> 
>> Using the memory control group for it's designed function aka killing
>> processes that eats too much memory I just would up with an unkillable
>> process in 3.11-rc2.
>
> How many processes are in that group? Could you post stacks for all of
> them? Is the stack bellow stable?

Just this one, and yes the stack is stable.
And there was a pending sigkill.  Which is what is so bizarre.

> Could you post dmesg output?

Nothing interesting was in dmesg.

I lost the original hang but I seem to be able to reproduce it fairly
easily.

echo 0 > memory.oom_control is enough to unstick it.  But that does not
explain why the process does not die when SIGKILL is sent.

> You seem to have CONFIG_MEMCG_KMEM enabled. Have you set up kmem
> limit?

No kmem limits set.

>> I am really not certain what is going on although I haven't rebooted the
>> machine yet so I can look a bit further if someone has a good idea.
>> 
>> On the unkillable task I see.
>> 
>> /proc/<pid>/stack:
>> 
>> [<ffffffff8110342c>] mem_cgroup_iter+0x1e/0x1d2
>> [<ffffffff81105630>] __mem_cgroup_try_charge+0x779/0x8f9
>> [<ffffffff81070d46>] ktime_get_ts+0x36/0x74
>> [<ffffffff81104d84>] memcg_oom_wake_function+0x0/0x5a
>> [<ffffffff8110620c>] __mem_cgroup_try_charge_swapin+0x6c/0xac
>
> Hmm, mem_cgroup_handle_oom should be setting up the task for wait queue
> so the above is a bit confusing.

The mem_cgroup_iter looks like it is somethine stale on the stack.
The __mem_cgroup_try_charge is immediately after the schedule in
mem_cgroup_handle_oom.

I have played with it a little bit and added
	if (!fatal_signal_pending(current))
		schedule();

On the off chance that it was an ordering thing that was triggering
this.  And that does not seem to be the problem in this instance.
The missing test before the schedule still looks wrong.

> Anyway your group seems to be under OOM and the task is in the middle of
> mem_cgroup_handle_oom which tries to kill something. That something is
> probably not willing to die so this task will loop trying to charge the
> memory until something releases a charge or the limit for the group is
> increased.

And it is configured so that the manager process needs to send SIGKILL
instead of having the kernel pick a random process.

> It would be interesting to see what other tasks are doing. We are aware
> of certain deadlock situations where memcg OOM killer tries to kill a
> task which is blocked on a lock (e.g. i_mutex) which is held by a task
> which is trying to charge but failing due to oom.

The only other weird thing that I see going on is the manager process
tries to freeze the entire cgroup, kill the processes, and the unfreeze
the cgroup and the freeze is failing.  But looking at /proc/<pid>/status
there was a SIGKILL pending.

Given how easy it was to wake up the process when I reproduced this
I don't think there is anything particularly subtle going on.  But
somehow we are going to sleep having SIGKILL delivered and not waking
up.  The not waking up bugs me.

> Johannes (added to CC) has a patchset which deals with this long term
> issue http://www.kernelhub.org/?p=2&msg=300518

That does look interesting.

Eric
