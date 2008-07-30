From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Wed, 30 Jul 2008 14:11:47 +0900
Message-ID: <20080730141147.837446aa.kamezawa.hiroyu@jp.fujitsu.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
	<20080729150111.f879c989.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0807300113200.14699@blonde.site>
	<20080730101719.5eb18635.kamezawa.hiroyu@jp.fujitsu.com>
	<20080730115226.3fec2540.kamezawa.hiroyu@jp.fujitsu.com>
	<20080730121115.b1e3a7be.kamezawa.hiroyu@jp.fujitsu.com>
	<20080730131407.526d323b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080730135803.a7750e21.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080730135803.a7750e21.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: Balbir-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Rik van Riel <riel-ebMLmSuQjDVBDgjK7y7TUQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 30 Jul 2008 13:58:03 +0900
Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:

> On Wed, 30 Jul 2008 13:14:07 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Wed, 30 Jul 2008 12:11:15 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > 
> > > On Wed, 30 Jul 2008 11:52:26 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > > mem+swap controller means a shrink to memory resource controller 
> > > > (try_to_free_mem_cgroup_pages()) should drop only file caches.
> > > > (Because kick-out-to-swap will never changes the usage.)
> > > > 
> > > > right ? only global-lru can make a swap.
> > > > maybe I can add optimization to do this. Hmm. I should see how OOM works
> > > > under some situation.
> > > > 
> I'm thinking mem+swap controller in a different way: an add-on to
> mem controller, just as current swap controller.
> I mean adding "memory.(mem+swap)_limit".
> 
Hmm ? adding a control file other than
 - memory.limit_in_bytes
?

Thanks,
-Kame
