From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Wed, 30 Jul 2008 12:11:15 +0900
Message-ID: <20080730121115.b1e3a7be.kamezawa.hiroyu@jp.fujitsu.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
	<20080729150111.f879c989.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0807300113200.14699@blonde.site>
	<20080730101719.5eb18635.kamezawa.hiroyu@jp.fujitsu.com>
	<20080730115226.3fec2540.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080730115226.3fec2540.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Rik van Riel <riel-ebMLmSuQjDVBDgjK7y7TUQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org" <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Andrew-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 30 Jul 2008 11:52:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> mem+swap controller means a shrink to memory resource controller 
> (try_to_free_mem_cgroup_pages()) should drop only file caches.
> (Because kick-out-to-swap will never changes the usage.)
> 
> right ? only global-lru can make a swap.
> maybe I can add optimization to do this. Hmm. I should see how OOM works
> under some situation.
> 
(I'm sorry that I'm not a good writer of e-mail.)

A brief summary about changes to mem controller.

 - mem+swap controller which limits the # sum of pages and swap_entries.
 - mem+swap controller just drops file caches when it reaches limit.
 - under mem+swap controller, recaliming Anon pages make no sense.
   Then,
      - LRU for Anon is not necessary.
      - LRU for tmpfs/shmem is not necessary.
      just showing account is better.
 - we should see try_to_free_mem_cgroup() again to avoid too much OOM.
   Maybe Retries=5 is too small because we never do swap under us.
   a problem like struck-into-ext3-journal can easily make file-cache reclaim
   difficult.
 - need some changes to documentation.
 - Should we have on/off switch of taking swap into account ?
   or should we implement mem+swap contoller in different name than
   "memory" controller ?
   If swap is not accounted, we need to do swap-out in memory reclaiming path,
   again.
   

Thanks,
-Kame
