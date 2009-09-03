From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: a room for blkio-cgroup in struct page_cgroup
Date: Thu, 3 Sep 2009 09:30:05 +0900 (JST)
Message-ID: <fa721014d75b6e193623349bfde28124.squirrel__9055.68928360498$1251937888$gmane$org@webmail-b.css.fujitsu.com>
References: <20090902.205137.71100180.ryov@valinux.co.jp>
	<ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
	<661de9470909021302ge86d01s5d107dc2b5cffbc5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <661de9470909021302ge86d01s5d107dc2b5cffbc5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> 2009/9/2 KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>:
>> Ryo Tsuruta wrote:
>>> Hi Kamezawa-san,
>>>
>>> As you wrote before (http://lkml.org/lkml/2009/7/22/65)
>>>> To be honest, what I expected in these days for people of blockio
>>>> cgroup is like following for getting room for themselves.
>>> <<snip>>
>>>> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
>>>> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
>>>> @@ -13,7 +13,7 @@
>>>> &#160;struct page_cgroup {
>>>> &#160; &#160; &#160; unsigned long flags;
>>>> &#160; &#160; &#160; struct mem_cgroup *mem_cgroup;
>>>> - &#160; &#160; struct page *page;
>>>> + &#160; &#160; /* block io tracking will use extra unsigned long
bytes */
>>>> &#160; &#160; &#160; struct list_head lru; &#160; &#160; &#160; /*
per cgroup LRU list */
>>>> };
>>>
>>> Have you already added a room for blkio_cgroup in struct page_cgroup?
>> No.
>>
>
> The diff above is unclear, are you removing struct page from page_cgroup?
>
I said him "if you want a room, plz get by youself, consider more"
And offered this change.
 http://lkml.org/lkml/2009/7/22/65
you were CC'd.
Because page_cgroup's layout is same to memmap, we can use similar function
as
  page_cgroup_to_pfn(), pfn_to_page_cgroup().
And, we don't access page_cgroup->page in fast path. (maybe)
But as I wrote, we're busy. I'll not do this until all performance fixes
go ahead.

Thanks,
-Kame
