From: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
	to world
Date: Tue, 07 Jun 2011 15:25:59 +0200
Message-ID: <4DEE26E7.2060201__6023.68303011662$1307453483$gmane$org@redhat.com>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>	<20110601123913.GC4266@tiehlicka.suse.cz>	<4DE6399C.8070802@redhat.com>	<20110601134149.GD4266@tiehlicka.suse.cz>	<4DE64F0C.3050203@redhat.com>	<20110601152039.GG4266@tiehlicka.suse.cz>	<4DE66BEB.7040502@redhat.com>	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>	<4DE8D50F.1090406@redhat.com>
	<BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Sorry for late reply,

On 06/03/2011 03:00 PM, Hiroyuki Kamezawa wrote:
> 2011/6/3 Igor Mammedov<imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>:
>> On 06/02/2011 01:10 AM, Hiroyuki Kamezawa wrote:
>>>> pc = list_entry(list->prev, struct page_cgroup, lru);
>>> Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
>>> before completion of
>>> create() is not populated to userland and you never be able to rmdir()
>>> it because you can't
>>> find it.
>>>
>>>
>>>   >26:   e8 7d 12 30 00          call   0x3012a8
>>>   >2b:*  8b 73 08                mov    0x8(%ebx),%esi<-- trapping
>>> instruction
>>>   >2e:   8b 7c 24 24             mov    0x24(%esp),%edi
>>>   >32:   8b 07                   mov    (%edi),%eax
>>>
>>> Hm, what is the call 0x3012a8 ?
>>>
>>                 pc = list_entry(list->prev, struct page_cgroup, lru);
>>                 if (busy == pc) {
>>                         list_move(&pc->lru, list);
>>                         busy = 0;
>>                         spin_unlock_irqrestore(&zone->lru_lock, flags);
>>                         continue;
>>                 }
>>                 spin_unlock_irqrestore(&zone->lru_lock, flags);<---- is
>>   call 0x3012a8
>>                 ret = mem_cgroup_move_parent(pc, mem, GFP_KERNEL);
>>
>> and  mov 0x8(%ebx),%esi
>> is dereferencing of 'pc' in inlined mem_cgroup_move_parent
>>
> Ah, thank you for input..then panicd at accessing pc->page and "pc"
> was 0xfffffff4.
> it means list->prev was NULL.
>
yes, that's the case.
>> I've looked at vmcore once more and indeed there isn't any parallel task
>> that touches cgroups code path.
>> Will investigate if it is xen to blame for incorrect data in place.
>>
>> Thanks very much for your opinion.
> What curious to me is that the fact "list->prev" is NULL.
> I can see why you doubt the initialization code ....the list pointer never
> contains NULL once it's used....
> it smells like memory corruption or some to me. If you have vmcore,
> what the problematic mem_cgroup_per_zone(node) contains ?

it has all zeros except for last field:

crash> rd f3446a00 62
f3446a00:  00000000 00000000 00000000 00000000   ................
f3446a10:  00000000 00000000 00000000 00000000   ................
f3446a20:  00000000 00000000 00000000 00000000   ................
f3446a30:  00000000 00000000 00000000 00000000   ................
f3446a40:  00000000 00000000 00000000 00000000   ................
f3446a50:  00000000 00000000 00000000 00000000   ................
f3446a60:  00000000 00000000 00000000 00000000   ................
f3446a70:  00000000 00000000 f36ef800 f3446a7c   ..........n.|jD.
f3446a80:  f3446a7c f3446a84 f3446a84 f3446a8c   |jD..jD..jD..jD.
f3446a90:  f3446a8c f3446a94 f3446a94 f3446a9c   .jD..jD..jD..jD.
f3446aa0:  f3446a9c 00000000 00000000 00000000   .jD.............
f3446ab0:  00000000 00000000 00000000 00000000   ................
f3446ac0:  00000000 00000000 00000000 00000000   ................
f3446ad0:  00000000 00000000 00000000 00000000   ................
f3446ae0:  00000000 00000000 00000000 00000000   ................
f3446af0:  00000000 f36ef800

crash> struct mem_cgroup f36ef800
struct mem_cgroup {
...
info = {
     nodeinfo = {0xf3446a00}
   },
...

It looks like a very targeted corruption of the first zone except of
the last field, while the second zone and the rest are perfectly
normal (i.e. have empty initialized lists).


PS:
It most easily reproduced only on xen hvm 32bit guest under heavy
vcpus contention for real cpus resources (i.e. I had to overcommit
cpus and run several cpu hog tasks on host to make guest crash on
reboot cycle).
And from last experiments, crash happens only on on hosts that
doesn't have hap feature or if hap is disabled in hypervisor.

> Thanks,
> -Kame
