From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Wed, 30 Jul 2008 11:52:26 +0900
Message-ID: <20080730115226.3fec2540.kamezawa.hiroyu@jp.fujitsu.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
	<20080729150111.f879c989.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0807300113200.14699@blonde.site>
	<20080730101719.5eb18635.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080730101719.5eb18635.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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

On Wed, 30 Jul 2008 10:17:19 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:

> On Wed, 30 Jul 2008 01:16:17 +0100 (BST)
> Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > On Tue, 29 Jul 2008, KAMEZAWA Hiroyuki wrote:
> > > On Fri, 25 Jul 2008 17:46:45 +0100 (BST)
> > > Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:
> > > 
> > > > IIRC Rik expressed the same by pointing out that a cgroup at its
> > > > swap limit would then be forced to grow in mem (until it hits its
> > > > mem limit): so controlling the less precious resource would increase
> > > > pressure on the more precious resource.  (Actually, that probably
> > > > bears little relation to what he said - sorry, Rik!)  I don't recall
> > > > what answer he got, perhaps I'd be persuaded if I heard it again.
> > > > 
> > > Added Nishimura to CC.
> > > 
> > > IMHO, from user point of view, both of
> > >  - having 2 controls as mem controller + swap controller
> > >  - mem + swap controller
> > > doesn't have much difference. The users will use as they like.
> > 
> > I'm not suggesting either one of those alternatives.
> > 
> > I'm suggesting we have a mem controller (the thing we already have)
> > and a mem+swap controller (which we don't yet have: a controller
> > for the total mem+swap of a cgroup); the mem+swap controller likely
> > making use of much that is in the mem controller, as Paul has said.
> > 
> Ah, what mem+swap controller means is limitiing mem+swap by 'a' limit ?
> It's a choice for me. From view of global LRU management, it's better.
> If we can avoid an accident that the swap is fully used by some silly program,
> anything is ok to me.
> 
Hmm.

mem+swap controller means a shrink to memory resource controller 
(try_to_free_mem_cgroup_pages()) should drop only file caches.
(Because kick-out-to-swap will never changes the usage.)

right ? only global-lru can make a swap.
maybe I can add optimization to do this. Hmm. I should see how OOM works
under some situation.

Thanks,
-Kame
