From: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: 3.9-rc1 NULL pointer crash at find_pid_ns
Date: Thu, 07 Mar 2013 12:36:01 -0500
Message-ID: <5138D001.8000409@oracle.com>
References: <611667212.10748821.1362649031475.JavaMail.root@redhat.com>
	<513860E8.4080807@huawei.com> <876213wmwt.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <876213wmwt.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/07/2013 04:59 AM, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org wrote:
> Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> writes:
> 
>> Cc: sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
>> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Cc: container
>>
>> This is a second report... and the same address: 0xfffffffffffffff0 
> 
> Actually this is the third report I have seen with that address, and the
> others were on x86_64.
> 
> The obvious answer is that there is something subtlely wrong with:
> 
> commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
> Author: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Date:   Wed Feb 27 17:06:00 2013 -0800
> 
>     hlist: drop the node parameter from iterators
> 
> 
> This is the only change the pid namespace that I am aware of in 3.9-rc1.
> 
> If you can reproduce this somewhat readily can you please revert the
> hlist change and see if this continues to happen.  Right now there are
> no other code changes that I can see.  And the address
> 0xfffffffffffffff0 is consistent with a bug in hlist_for_each_entry_rcu.

Looks like the hlist change is probably the issue, though it specifically
uses:

	#define hlist_entry_safe(ptr, type, member) \
        	(ptr) ? hlist_entry(ptr, type, member) : NULL

I'm still looking at the code in question and it's assembly, but I can't
figure out what's going wrong. I was also trying to see what's so special
about this loop in find_pid_ns as opposed to the rest of the kernel code
that uses hlist_for_each_entry_rcu() but couldn't find out why.

Is it somehow possible that if we rcu_dereference_raw() the same thing twice
inside the same rcu_read_lock() section we'll get different results? That's
really the only reason for this crash that comes to mind at the moment, very
unlikely - but that's all I have right now.

Is this bug reproducible easily on your setup? I've managed to reproduce it
exactly 3 times in the past month or so, twice when I reported it and only
once since then - at some point I thought that it was a freak compiler issue
that went away when the code changed but since you're reporting it again
I guess that it isn't the case.


Paul, any chance you can give hlist_for_each_entry_rcu() a second look please?
I know you've already acked it before, but is it possible I missed a subtle
detail with RCU that causes this?


Thanks,
Sasha
