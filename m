From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/5] cgroups: revamp subsys array
Date: Thu, 10 Dec 2009 11:18:06 +0800
Message-ID: <4B20686E.3070907__49784.4967562289$1260415163$gmane$org@cn.fujitsu.com>
References: <20091204085349.GA18867@andrew.cmu.edu>
	<20091204085508.GA18912@andrew.cmu.edu>
	<4B1E0283.70108@cn.fujitsu.com>
	<20091209055016.GA12342@andrew.cmu.edu>
	<4B1F3EB9.6080502@cn.fujitsu.com>
	<20091209082729.GA14114@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091209082729.GA14114-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

>>>>> @@ -1291,6 +1324,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>>>>>  	struct cgroupfs_root *new_root;
>>>>>  
>>>>>  	/* First find the desired set of subsystems */
>>>>> +	down_read(&subsys_mutex);
>>>> Hmm.. this can lead to deadlock. sget() returns success with sb->s_umount
>>>> held, so here we have:
>>>>
>>>> 	down_read(&subsys_mutex);
>>>>
>>>> 	down_write(&sb->s_umount);
>>>>
>>>> On the other hand, sb->s_umount is held before calling kill_sb(),
>>>> so when umounting we have:
>>>>
>>>> 	down_write(&sb->s_umount);
>>>>
>>>> 	down_read(&subsys_mutex);
>>> Unless I'm gravely mistaken, you can't have deadlock on an rwsem when
>>> it's being taken for reading in both cases? You would have to have at
>>> least one of the cases being down_write.
>>>
>> lockdep will warn on this..
> 
> Hm. Why did I not see this warning...?
> 

Because you haven't triggered it. ;)

The scripts below can trigger the warning (at least for me):

# cat test1.sh
#! /bin/sh
for ((; ;))
{
        mount -t cgroup -o devices xxx /cgroup1
        umount /cgroup1
}

# cat test2.sh
#! /bin/sh
for ((; ;))
{
        mount -t cgroup -o devices xxx /cgroup2
        umount /cgroup2
}


>> And it can really lead to deadlock, though not so obivously:
>>
>>   thread 1       thread 2        thread 3
>> -------------------------------------------
>> | read(A)        write(B)
>> |
>> |                                write(A)
>> |
>> |                read(A)
>> |
>> | write(B)
>> |
>>
>> t3 is waiting for t1 to release the lock, then t2 tries to
>> acquire A lock to read, but it has to wait because of t3,
>> and t1 has to wait t2.
>>
>> Note: a read lock has to wait if a write lock is already
>> waiting for the lock.
> 
> Okay, clever, the deadlock happens because of a behavioural optimization
> of the rwsems. Good catch on the whole issue.
> 
> How does this sound as a possible solution, in cgroup_get_sb:
> 
> 1) Take subsys_mutex
> 2) Call parse_cgroupfs_options()
> 3) Drop subsys_mutex
> 4) Call sget(), which gets sb->s_umount without subsys_mutex held
> 5) Take subsys_mutex
> 6) Call verify_cgroupfs_options()
> 7) Proceed as normal
> 
> In which verify_cgroupfs_options will be a new function that ensures the
> invariants that rebind_subsystems expects are still there; if not, bail
> out by jumping to drop_new_super just as if parse_cgroupfs_options had
> failed in the first place.
> 

The current code doesn't need this verify_cgroupfs_options, so why it
will become necessary? I think what we need is grab module refcnt in
parse_cgroupfs_options, and then we can drop subsys_mutex.

But why you are using a rw semaphore? I think a mutex is fine.
And why not just use cgroup_mutex to protect the subsys[] array?
The adding and spreading of subsys_mutex looks ugly to me.

> Another question: What's the justification for having an interface of
> seemingly symmetrical "initialize" and "destroy" functions, one of which
> has to take a lock and the other gets called with the lock already held?
> Seems like it's asking for trouble.
> 

Are you refering to get_sb() and kill_sb()? VFS is not my area, so I'm
not going to judge it. ;)
