From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [3/6]
 add helper function for page_cgroup
Date: Wed, 10 Oct 2007 09:38:39 +0900
Message-ID: <20071010093839.f97d79da.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20071009185132.a870b0f0.kamezawa.hiroyu@jp.fujitsu.com>
	<470B617C.1060504@linux.vnet.ibm.com>
	<20071009202642.9f174445.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071009202642.9f174445.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 9 Oct 2007 20:26:42 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:

> > 
> > > +		 */
> > > +		if (clear_page_cgroup(page, pc) == pc) {
> > 
> > OK.. so we've come so far and seen that pc has changed underneath us,
> > what do we do with this pc?
> > 
> Hmm... How about this ?
> ==
>  if (clear_page_cgroup(page, pc) == pc) {
> 	/* do usual work */
>  } else {
> 	BUG();
>  }
> == or BUG_ON(clear_page_cgroup(page, pc) != pc)
> 
> I have no clear idea when this race will occur.
After good sleep, I noticed there is a race with force_reclaim (in patch 6).

force_reclaim doesn't check refcnt before clearing page->pc.

My final view will be
==
   if (clear_page_cgroup(page, pc) == pc) {
	/* do usual work */
   } else {
	/* force reclaim clears page->page_cgroup */
   }
==
Anyway, I'll add a meaningful comment here.

Thanks,
-Kame
