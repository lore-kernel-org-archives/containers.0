From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Wed, 13 Aug 2008 16:15:05 +0900 (JST)
Message-ID: <20080813071505.930965A75__21826.2579445311$1218611851$gmane$org@siro.lan>
References: <1218116168.8625.38.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Thu, 07 Aug 2008 15:36:08 +0200"
	<1218116168.8625.38.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

> > @@ -485,7 +502,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >  		if (PageUnevictable(page) ||
> >  		    (PageActive(page) && !active) ||
> >  		    (!PageActive(page) && active)) {
> > -			__mem_cgroup_move_lists(pc, page_lru(page));
> > +			if (try_lock_page_cgroup(page)) {
> > +				__mem_cgroup_move_lists(pc, page_lru(page));
> > +				unlock_page_cgroup(page);
> > +			}
> >  			continue;
> >  		}
> 
> This chunk seems unrelated and lost....

it's necessary to protect from mem_cgroup_{set,clear}_dirty
which modify pc->flags without holding mz->lru_lock.

> I presonally dislike the != 0, == 0 comparisons for bitmask operations,
> they seem to make it harder to read somewhow. I prefer to write !(flags
> & mask) and (flags & mask), instead.
> 
> I guess taste differs,...

yes, it seems different. :)

YAMAMOTO Takashi
