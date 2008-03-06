From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Supporting overcommit with the memory controller
Date: Thu, 06 Mar 2008 12:07:57 +0300
Message-ID: <47CFB46D.3040409@openvz.org>
References: <6599ad830803051617w7835d9b2l69bbc1a0423eac41@mail.gmail.com>	<20080306100158.a521af1b.kamezawa.hiroyu@jp.fujitsu.com>	<6599ad830803051854x5ee204bej7212d9c1e444e4d0@mail.gmail.com>	<47CFB193.3040501@openvz.org>
	<20080306180541.404bfd12.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080306180541.404bfd12.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Memory Management List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Thu, 06 Mar 2008 11:55:47 +0300
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> 
>>>>  Can Balbir's soft-limit patches help ?
>> [snip]
>>
>>> Yes, that could be a useful part of the solution - I suspect we'd need
>>> to have kswapd do the soft-limit push back as well as in
>>> try_to_free_pages(), to avoid the high-priority jobs getting stuck in
>>> the reclaim code. It would also be nice if we had:
>> BTW, one of the way OpenVZ users determine how much memory they
>> need for containers is the following: they set the limits to
>> maximal values and then check the "maxheld" (i.e. the maximal level
>> of consumption over the time) value.
>>
>> Currently, we don't have such in res_counters and I'm going to
>> implement this. Objections?
>>
> Basically, no objection.
> 
> BTW, which does it means ? 
> - create a new cgroup to accounting max memory consumption, etc...
> or
> - add new member to mem_cgroup
> or
> - add new member to res_counter

The third one - new member on res_counter. This will cost us 8 more
bytes on mem_cgroup and no performance impact, since the new field
is about to be touched only together with the limit and usage ones,
and thus is in one cacheline.

> Thanks,
> -Kame
> 
> 
