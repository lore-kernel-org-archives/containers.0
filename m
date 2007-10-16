From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][ just for review] memory controller enhancements [1/5]
 force empty
Date: Tue, 16 Oct 2007 15:32:11 +0900
Message-ID: <20071016153211.f42cc9be.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071011185128.63af3b74.kamezawa.hiroyu@jp.fujitsu.com>
	<20071016001549.298441BF482@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071016001549.298441BF482-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 16 Oct 2007 09:15:49 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > Index: devel-2.6.23-rc8-mm2/mm/memcontrol.c
> > ===================================================================
> > --- devel-2.6.23-rc8-mm2.orig/mm/memcontrol.c
> > +++ devel-2.6.23-rc8-mm2/mm/memcontrol.c
> > @@ -469,6 +469,7 @@ void mem_cgroup_uncharge(struct page_cgr
> >  		page = pc->page;
> >  		/*
> >  		 * get page->cgroup and clear it under lock.
> > +		 * force-empty can drop page->cgroup without checking refcnt.
> 
> force_empty
> 
> > +	char buf[2] = "0";
> 
> it should be static const unless you want a runtime assignment.
> 
Sure, thank you for pointing out.

Regards,
-Kame
