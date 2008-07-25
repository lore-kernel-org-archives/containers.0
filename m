From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Fri, 25 Jul 2008 09:32:30 -0400
Message-ID: <4889D5EE.4010601@linux.vnet.ibm.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0807251004570.31120-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
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
> On Fri, 25 Jul 2008, Paul Menage wrote:
>> So I think we'd be complicating some of the vm paths in mainline with
>> a feature that isn't likely to get a lot of real use.
>>
>> What do you (and others on the containers list) think? Should we ask
>> Andrew/Linus to hold off on this for now? My preference would be to do
>> that until we have someone who can stand up with a concrete scenario
>> where they want to use this in a real environment.
> 
> I see Andrew has already acted, so it's now moot.  But I'd like to
> say that I do agree with you and the conclusion to hold off for now.
> 
> I was a bit alarmed earlier to see those patches sailing on through;
> but realized that I'd done very little to substantiate my "hatred of
> the whole thing", and decided that I didn't feel strongly enough to
> stand in the way now.  But I am glad you've stepped in, thank you.
> 
> (Different topic, but one day I ought to get around to saying again
> how absurd I think a swap controller; whereas a mem+swap controller
> makes plenty of sense.  I think Rik and others said the same.)
> 

We will have a memory+swap controller working together.

> By the way, here's a BUG I got from CONFIG_CGROUP_MEMRLIMIT_CTLR=y
> but no use of it, when doing swapoff a week ago.  Not investigated
> at all, I'm afraid, but at a guess it might come from memrlimit work
> placing too much faith in the mm_users count - swapoff is only one
> of several places which have to inc/dec mm_users for some reason.
> 

I'll try and reproduce the problem right away. I've been running some kernbench
on top of memrlimit (but not with a lot of stress or trying to swapoff the swap
device).

> BUG: unable to handle kernel paging request at 6b6b6b8b
> IP: [<7817078f>] memrlimit_cgroup_uncharge_as+0x18/0x29
> *pde = 00000000 
> Oops: 0000 [#1] PREEMPT SMP 
> last sysfs file: /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map
> Modules linked in: acpi_cpufreq snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device thermal ac battery button
> 
> Pid: 22500, comm: swapoff Not tainted (2.6.26-rc8-mm1 #7)
> EIP: 0060:[<7817078f>] EFLAGS: 00010206 CPU: 0
> EIP is at memrlimit_cgroup_uncharge_as+0x18/0x29
> EAX: 6b6b6b6b EBX: 7963215c ECX: 7c032000 EDX: 0025e000
> ESI: 96902518 EDI: 9fbb1aa0 EBP: 7c033e9c ESP: 7c033e9c
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process swapoff (pid: 22500, ti=7c032000 task=907e2b70 task.ti=7c032000)
> Stack: 7c033edc 78161323 9fbb1aa0 0000025e ffffff77 7c033ecc 96902518 00000000 
>        ffffffff 7c033ec8 00000000 00000089 7963215c 9fbb1aa0 9fbb1b28 a272f040 
>        7c033ef4 781226b1 9fbb1aa0 9fbb1aa0 790fa884 a272f0c8 7c033f80 78165ce3 
> Call Trace:
>  [<78161323>] ? exit_mmap+0xaf/0x133
>  [<781226b1>] ? mmput+0x4c/0xba
>  [<78165ce3>] ? try_to_unuse+0x20b/0x3f5
>  [<78371534>] ? _spin_unlock+0x22/0x3c
>  [<7816636a>] ? sys_swapoff+0x17b/0x37c
>  [<78102d95>] ? sysenter_past_esp+0x6a/0xa5
>  =======================
> Code: 24 0c 00 00 8b 40 20 52 83 c0 0c 50 e8 ad a6 fd ff c9 c3 55 89 e5 8b 45 08 8b 55 0c 8b 80 30 02 00 00 c1 e2 0c 8b 80 24 0c 00 00 <8b> 40 20 52 83 c0 0c 50 e8 e6 a6 fd ff 58 5a c9 c3 55 89 e5 8b 
> EIP: [<7817078f>] memrlimit_cgroup_uncharge_as+0x18/0x29 SS:ESP 0068:7c033e9c
> 
> Hugh

I'll try and recreate the problem and fix it. If memrlimit_cgroup_uncharge_as()
created the problem, it's most likely related to mm->owner not being correct and
we are dereferencing the wrong memory.

Thanks for the bug report, I'll look further.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
