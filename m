From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 2/4] Block I/O tracking
Date: Tue, 18 Mar 2008 21:15:05 +0900 (JST)
Message-ID: <20080318.211505.93059628.taka@valinux.co.jp>
References: <20080318192233.89c5cc3e.kamezawa.hiroyu@jp.fujitsu.com>
	<20080318.203422.45236787.taka@valinux.co.jp>
	<20080318205501.59877972.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080318205501.59877972.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > > And, blist seems to be just used for force_empty.
> > > Do you really need this ? no alternative ?
> > 
> > I selected this approach because it was the simplest way for the
> > first implementation.
> > 
> > I've been also thinking about what you pointed.
> > If you don't mind taking a long time to remove a bio cgroup, it will be
> > the easiest way that you can scan all pages to find the pages which
> > belong to the cgroup and delete them. It may be enough since you may
> > say it will rarely happen. But it might cause some trouble on machines
> > with huge memory.
> > 
> Hmm, force_empty itself is necessary ?

It is called when bio cgroups are removed.
With the current implementation, when you delete a bio cgroup, 
the bio_cgroup members of page_cgroups which point the cgroup
have to be cleared.

So I'm looking for another way like:
  - Use some kind of id instead of a pointer to a bio cgroup,
    so you can check whether the id is valid before you use it.
  - Don't free the bio cgroup until all the pages referring to
    the cgroup.

I also want to implement that if you find a page whose cgroup is
already removed, the page should be assigned to a new cgroup.


Thank you,
Hirokazu Takahashi.
