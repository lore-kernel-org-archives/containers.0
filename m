From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: a room for blkio-cgroup in struct page_cgroup
Date: Thu, 3 Sep 2009 01:32:24 +0530
Message-ID: <661de9470909021302ge86d01s5d107dc2b5cffbc5__27557.2559134618$1251921872$gmane$org@mail.gmail.com>
References: <20090902.205137.71100180.ryov@valinux.co.jp>
	<ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ff13736137802f78cf492d13c43c1af1.squirrel-n3SY6/QrmYVJe+uFzlzAcYO9/linGGC/AL8bYrjMMd8@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

2009/9/2 KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>:
> Ryo Tsuruta wrote:
>> Hi Kamezawa-san,
>>
>> As you wrote before (http://lkml.org/lkml/2009/7/22/65)
>>> To be honest, what I expected in these days for people of blockio
>>> cgroup is like following for getting room for themselves.
>> <<snip>>
>>> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
>>> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
>>> @@ -13,7 +13,7 @@
>>> =A0struct page_cgroup {
>>> =A0 =A0 =A0 unsigned long flags;
>>> =A0 =A0 =A0 struct mem_cgroup *mem_cgroup;
>>> - =A0 =A0 struct page *page;
>>> + =A0 =A0 /* block io tracking will use extra unsigned long bytes */
>>> =A0 =A0 =A0 struct list_head lru; =A0 =A0 =A0 /* per cgroup LRU list */
>>> };
>>
>> Have you already added a room for blkio_cgroup in struct page_cgroup?
> No.
>

The diff above is unclear, are you removing struct page from page_cgroup?

Balbir Singh
