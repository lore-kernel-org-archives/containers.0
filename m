From: Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node to
	world
Date: Fri, 3 Jun 2011 22:00:47 +0900
Message-ID: <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ__38382.2449403398$1307106096$gmane$org@mail.gmail.com>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
	<20110601123913.GC4266@tiehlicka.suse.cz>
	<4DE6399C.8070802@redhat.com>
	<20110601134149.GD4266@tiehlicka.suse.cz>
	<4DE64F0C.3050203@redhat.com>
	<20110601152039.GG4266@tiehlicka.suse.cz>
	<4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
	<4DE8D50F.1090406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4DE8D50F.1090406-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

2011/6/3 Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>:
> On 06/02/2011 01:10 AM, Hiroyuki Kamezawa wrote:
>>>
>>> pc =3D list_entry(list->prev, struct page_cgroup, lru);
>>
>> Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
>> before completion of
>> create() is not populated to userland and you never be able to rmdir()
>> it because you can't
>> find it.
>>
>>
>> =A0>26: =A0 e8 7d 12 30 00 =A0 =A0 =A0 =A0 =A0call =A0 0x3012a8
>> =A0>2b:* =A08b 73 08 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mov =A0 =A00x8(%ebx)=
,%esi<-- trapping
>> instruction
>> =A0>2e: =A0 8b 7c 24 24 =A0 =A0 =A0 =A0 =A0 =A0 mov =A0 =A00x24(%esp),%e=
di
>> =A0>32: =A0 8b 07 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mov =A0 =A0(%edi),=
%eax
>>
>> Hm, what is the call 0x3012a8 ?
>>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D list_entry(list->prev, struct page_=
cgroup, lru);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (busy =3D=3D pc) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&pc->lru, list);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zo=
ne->lru_lock, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, fl=
ags); <---- is
> =A0call 0x3012a8
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_move_parent(pc, mem, GF=
P_KERNEL);
>
> and =A0mov 0x8(%ebx),%esi
> is dereferencing of 'pc' in inlined mem_cgroup_move_parent
>
Ah, thank you for input..then panicd at accessing pc->page and "pc"
was 0xfffffff4.
it means list->prev was NULL.

> I've looked at vmcore once more and indeed there isn't any parallel task
> that touches cgroups code path.
> Will investigate if it is xen to blame for incorrect data in place.
>
> Thanks very much for your opinion.

What curious to me is that the fact "list->prev" is NULL.
I can see why you doubt the initialization code ....the list pointer never
contains NULL once it's used....
it smells like memory corruption or some to me. If you have vmcore,
what the problematic mem_cgroup_per_zone(node) contains ?

Thanks,
-Kame
