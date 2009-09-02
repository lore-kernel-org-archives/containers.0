From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: a room for blkio-cgroup in struct page_cgroup
Date: Wed, 02 Sep 2009 20:51:37 +0900 (JST)
Message-ID: <20090902.205137.71100180.ryov__8029.61405502192$1251892429$gmane$org@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Kamezawa-san,

As you wrote before (http://lkml.org/lkml/2009/7/22/65)
> To be honest, what I expected in these days for people of blockio
> cgroup is like following for getting room for themselves.
<<snip>>
> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
> @@ -13,7 +13,7 @@
>  struct page_cgroup {
>       unsigned long flags;
>       struct mem_cgroup *mem_cgroup;
> -     struct page *page;
> +     /* block io tracking will use extra unsigned long bytes */
>       struct list_head lru;       /* per cgroup LRU list */
> };

Have you already added a room for blkio_cgroup in struct page_cgroup?
If not, I would like you to apply the above change to mmotm.

The latest blkio-cgroup has reflected the comments you pointed out.
I would also like you to give me any comments on it and consider
merging blkio-cgroup to mmotm.

Thank you for your help in advance.
Ryo Tsuruta
