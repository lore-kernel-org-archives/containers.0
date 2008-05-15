From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Thu, 15 May 2008 15:23:18 +0900 (JST)
Message-ID: <20080515062318.5F1BA5A07@siro.lan>
References: <6599ad830805140144k583f7426k4024dd17a6cd3eb8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Wed, 14 May 2008 01:44:38 -0700"
	<6599ad830805140144k583f7426k4024dd17a6cd3eb8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> On Tue, May 13, 2008 at 8:21 PM, YAMAMOTO Takashi
> <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> >  >
> >  > Could you please mention what the limitations are? We could get those fixed or
> >  > take another serious look at the mm->owner patches.
> >
> >  for example, its callback can't sleep.
> >
> 
> You need to be able to sleep in order to take mmap_sem, right?

yes.
besides that, i prefer not to hold a spinlock when traversing PTEs
as it can take somewhat long.

> Of course, having lots of datapath operations also take cgroup_mutex
> would be really painful, so it's not practical to use for things that
> can become non-attachable due to a process consuming some resources.
> This is part of the reason that I started working on the lock-mode
> patches that I sent out yesterday, in order to make finer-grained
> locking simpler. I'm going to rework those to make the locking more
> explicit, and I'll bear this use case in mind while I'm doing it.

thanks.

> A few comments on the patch:
> 
> - you're not really limiting swap usage, you're limiting swapped-out
> address space. So it looks as though if a process has swapped out most
> of its address space, and forks a child, the total "swap" charge for
> the cgroup will double. Is that correct?

yes.

> If so, why is this better
> than charging for actual swap usage?

its behaviour is more determinstic and it uses less memory.
(than nishimura-san's one, which charges for actual swap usage.)

> - what will happen if someone creates non-NPTL threads, which share an
> mm but not a thread group (so each of them is a thread group leader)?

a thread which is most recently assigned to a cgroup will "win".

> - if you were to store a pointer in the page rather than the

"a pointer"?  a pointer to what?

> swap_cgroup pointer, then (in combination with mm->owner) you wouldn't
> need to do the rebinding to the new swap_cgroup when a process moves
> to a different cgroup - you could instead keep a "swapped pte" count
> in the mm, and just charge that to the new cgroup and uncharge it from
> the old cgroup. You also wouldn't need to keep ref counts on the
> swap_cgroup.

PTE walking in my patch is for locking, not for "rebinding".
ie. to deal with concurrent swap activities.
the fact that each page table pages have their own locks (pte_lockptr)
complicated it.

> - ideally this wouldn't actually start charging until it was bound on
> to a cgroups hierarchy, although I guess that the performance of this
> is less important than something like the virtual address space
> controller, since once we start swapping we can expect performance to
> be bad anyway.

i agree.

YAMAMOTO Takashi
