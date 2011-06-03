From: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
	to world
Date: Fri, 03 Jun 2011 14:35:27 +0200
Message-ID: <4DE8D50F.1090406__24740.3098539964$1307104720$gmane$org@redhat.com>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>	<20110601123913.GC4266@tiehlicka.suse.cz>	<4DE6399C.8070802@redhat.com>	<20110601134149.GD4266@tiehlicka.suse.cz>	<4DE64F0C.3050203@redhat.com>	<20110601152039.GG4266@tiehlicka.suse.cz>	<4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 06/02/2011 01:10 AM, Hiroyuki Kamezawa wrote:
>> pc = list_entry(list->prev, struct page_cgroup, lru);
> Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
> before completion of
> create() is not populated to userland and you never be able to rmdir()
> it because you can't
> find it.
>
>
>   >26:   e8 7d 12 30 00          call   0x3012a8
>   >2b:*  8b 73 08                mov    0x8(%ebx),%esi<-- trapping
> instruction
>   >2e:   8b 7c 24 24             mov    0x24(%esp),%edi
>   >32:   8b 07                   mov    (%edi),%eax
>
> Hm, what is the call 0x3012a8 ?
>
                 pc = list_entry(list->prev, struct page_cgroup, lru);
                 if (busy == pc) {
                         list_move(&pc->lru, list);
                         busy = 0;
                         spin_unlock_irqrestore(&zone->lru_lock, flags);
                         continue;
                 }
                 spin_unlock_irqrestore(&zone->lru_lock, flags); <---- 
is  call 0x3012a8
                 ret = mem_cgroup_move_parent(pc, mem, GFP_KERNEL);

and  mov 0x8(%ebx),%esi
is dereferencing of 'pc' in inlined mem_cgroup_move_parent

I've looked at vmcore once more and indeed there isn't any parallel task
that touches cgroups code path.
Will investigate if it is xen to blame for incorrect data in place.

Thanks very much for your opinion.
> Thanks,
> -Kame
