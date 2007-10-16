From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH][ just for review] memory controller enhancements [1/5]
 force empty
Date: Tue, 16 Oct 2007 09:15:49 +0900 (JST)
Message-ID: <20071016001549.298441BF482@siro.lan>
References: <20071011185128.63af3b74.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Thu, 11 Oct 2007 18:51:28 +0900"
	<20071011185128.63af3b74.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> Index: devel-2.6.23-rc8-mm2/mm/memcontrol.c
> ===================================================================
> --- devel-2.6.23-rc8-mm2.orig/mm/memcontrol.c
> +++ devel-2.6.23-rc8-mm2/mm/memcontrol.c
> @@ -469,6 +469,7 @@ void mem_cgroup_uncharge(struct page_cgr
>  		page = pc->page;
>  		/*
>  		 * get page->cgroup and clear it under lock.
> +		 * force-empty can drop page->cgroup without checking refcnt.

force_empty

> +	char buf[2] = "0";

it should be static const unless you want a runtime assignment.

YAMAMOTO Takashi
