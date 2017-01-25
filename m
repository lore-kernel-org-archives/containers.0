From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] procfs: change the owner of non-dumpable and writeable
	files
Date: Wed, 25 Jan 2017 17:43:21 +1100
Message-ID: <f941dfa7-0398-f6f6-807b-52e528b67ceb@suse.de>
References: <20170118040159.4751-1-asarai@suse.de>
	<20170119092930.GJ30786@dhcp22.suse.cz>
	<e7137350-b8a8-c7e5-e35d-8218a7df1147@suse.de>
	<87r33yv6gk.fsf@xmission.com>
	<4025e285-9179-b98a-88c0-905f4f9c3ef8@suse.de>
	<87wpdqjqkx.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wpdqjqkx.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>> AKA it should be this fix that removes the need for your dumpable setting.
>>> bfedb589252c ("mm: Add a user_ns owner to mm_struct and fix ptrace permission checks")
>>
>> I will check, though from what I recall that patch doesn't fix the
>> ptrace_may_access checks. Not to mention it won't help if the
>> container doesn't have it's own user namespace.
>
> That change very much is to the ptrace_may_access checks.

Sorry, you're right. I misremembered the patch.

> You are not playing with setgroups if you don't have your own user
> namespace.  So I don't see how the other cases are relevant.

There's also oom_score_adj and a few others. User namespaces were just 
the first example that I hit.

> What I think I would do in the situation you describe is to
> join what you are going to join.  Limit yourself to creating pid
> namespaces with unshare.
>
> If you are joining a user namespace set undumpable.
> If you are creating a user namespace create it and then set undumpable.

I just tried to implement this, and it works _okay_. Except that 
oom_scoore_adj also is no longer writeable if the process is not 
dumpable -- and the "create container" and "modify process" stages in 
runC are very separate and there's no easy way of reconciling the two.

Ultimately this only affects rootless containers, where security is 
simply not a major concern. However it is a bit frustrating that a 
process which is not dumpable cannot even modify _its own_ 
/proc/self/... files.

My current fix is to just not set dumpable for rootless containers, as 
it seems there's no proper way of setting dumpable in this context. It 
appears as though the only way that dumpable works is by just using 
CAP_DAC_OVERRIDE and completely ignoring the dumpable restrictions.

>>> Clearing dumpable is to help not leak things
>>> into a container when you call setns on a user namespace.
>>
>> It is also to help not leak things into a container when you join
>> other namespaces. Most notably the PID namespace.
>
> Except that you don't strictly join a PID namespace.  You set a context
> for children to run in a different PID namespace.  So you are safe
> from PID namespaces as long as you don't call fork.

But you need to fork eventually if you want to set settings on the 
process which will eventually be the container process (PID 1 in the new 
container). You can't exec before then, you need to fork first.

>>> +	if (mode != (S_IFDIR|S_IRUGO|S_IXUGO)) {
>>
>> I'd just like to draw your attention to this special case -- why is
>> this special cased? What was the original reasoning behind it? Does it
>> make sense for a non-dumpable process to allow someone to change the
>> mode of some random /proc/[pid]/ directories?
>
> This has nothing at all to do with changing modes and is all about
> what uid/gid are set on the proc inode.   Usually it is the uid/gid
> of the process in question but occassionally for undumpable processes
> it is root/root to prevent people from accessing the files in question.

My question was "why are o+rx directories set to the process's e[ug]id 
but other inodes are set to the root [ug]id?". And it's the other way 
around -- only for two directories on my system is it the case that the 
process has /proc/pid/... inodes owned by the process's e[ug]id (the 
rest are owned by root).

And it is about modes, because once you're the owner of a file you can 
change its mode (allowing other processes to access the inodes). I'm not 
sure what other purpose changing the ownership *of a directory* serves 
-- you cannot create new files (or unlink files) under /proc/self/... 
directories so u+w permissions aren't actually "useful" (as far as I can 
tell).


>> I get the feeling that some of this logic is a bit iffy.
>
> It looks like I forgot to carry forward the comment that explains that
> case in my patch.  Something I need to fix before I merge it.
>
> /*
>  * Before the /proc/pid/status file was created the only way to read
>  * the effective uid of a /process was to stat /proc/pid.  Reading
>  * /proc/pid/status is slow enough that procps and other packages
>  * kept stating /proc/pid.  To keep the rules in /proc simple I have
>  * made this apply to all per process world readable and executable
>  * directories.
>  */
>
> Or in short.  I broke ps when I removed all of the special cases, and to
> fix ps I added the existing special case.  Not that the uid or gid of a
> directory that the whole world can access matters.

Okay, but why is it being applied to _all_ subdirectories of /proc/pid? 
Why not make it *only* set the owner of /proc/pid and nothing else? 
Looks like that was not intended given the reasons you just provided.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
