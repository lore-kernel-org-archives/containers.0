From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Mon, 18 Aug 2008 16:58:56 +0900
Message-ID: <20080818165856.0faeb0bb.kamezawa.hiroyu__410.783364395861$1219046101$gmane$org@jp.fujitsu.com>
References: <1218116168.8625.38.camel@twins>
	<20080813071505.930965A75@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080813071505.930965A75-Pcsii4f/SVk@public.gmane.org>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 13 Aug 2008 16:15:05 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> hi,
> 
> > > @@ -485,7 +502,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> > >  		if (PageUnevictable(page) ||
> > >  		    (PageActive(page) && !active) ||
> > >  		    (!PageActive(page) && active)) {
> > > -			__mem_cgroup_move_lists(pc, page_lru(page));
> > > +			if (try_lock_page_cgroup(page)) {
> > > +				__mem_cgroup_move_lists(pc, page_lru(page));
> > > +				unlock_page_cgroup(page);
> > > +			}
> > >  			continue;
> > >  		}
> > 
> > This chunk seems unrelated and lost....
> 
> it's necessary to protect from mem_cgroup_{set,clear}_dirty
> which modify pc->flags without holding mz->lru_lock.
> 

I'm now writing a patch to make page_cgroup->flags to be atomic_ops.
Don't worry about this.
(With remove-page-lock-cgroup patch, atomic_ops patch's performace is
 quite well.)

Thanks,
-Kame
