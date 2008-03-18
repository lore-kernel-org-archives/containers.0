From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/4] Block I/O tracking
Date: Tue, 18 Mar 2008 19:22:33 +0900
Message-ID: <20080318192233.89c5cc3e.kamezawa.hiroyu__22802.6497796693$1205835623$gmane$org@jp.fujitsu.com>
References: <20080318.182251.93858044.taka@valinux.co.jp>
	<20080318.182906.104806991.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080318.182906.104806991.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 18 Mar 2008 18:29:06 +0900 (JST)
Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> Hi,
> 
> This patch implements the bio cgroup on the memory cgroup.
> 
> Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
> 
> --- linux-2.6.25-rc5.pagecgroup2/include/linux/memcontrol.h	2008-03-18 12:45:14.000000000 +0900
> +++ linux-2.6.25-rc5-mm1/include/linux/memcontrol.h	2008-03-18 12:55:59.000000000 +0900
> @@ -54,6 +54,10 @@ struct page_cgroup {
>  	struct list_head lru;		/* per cgroup LRU list */
>  	struct mem_cgroup *mem_cgroup;
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +#ifdef  CONFIG_CGROUP_BIO
> +	struct list_head blist;		/* for bio_cgroup page list */
> +	struct bio_cgroup *bio_cgroup;
> +#endif

Hmm, definition like this
==
enum {
#ifdef CONFIG_CGROUP_MEM_RES_CTLR
	MEM_RES_CTLR,
#endif
#ifdef CONFIG_CGROURP_BIO
	BIO_CTLR,
#endif
	NR_VM_CTRL,
};

	void	*cgroups[NR_VM_CGROUP];
==
Can save another #ifdefs ?

And, blist seems to be just used for force_empty.
Do you really need this ? no alternative ?


Thanks,
-Kame
