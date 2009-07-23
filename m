From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Xen-devel] Re: [PATCH 7/9] blkio-cgroup-v9: Page tracking hooks
Date: Thu, 23 Jul 2009 16:49:35 +0900
Message-ID: <20090723164935.e97a3ccf.kamezawa.hiroyu__19051.0570690551$1248335561$gmane$org@jp.fujitsu.com>
References: <20090722111714.8af6c5d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090722.184055.226788113.ryov@valinux.co.jp>
	<20090723091841.81ff2432.kamezawa.hiroyu@jp.fujitsu.com>
	<20090723.153843.193704010.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723.153843.193704010.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 23 Jul 2009 15:38:43 +0900 (JST)
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Wed, 22 Jul 2009 18:40:55 +0900 (JST)
> > Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> > 
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > > On Tue, 21 Jul 2009 23:23:16 +0900 (JST)
> > > > Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> > > > 
> > > > > This patch contains several hooks that let the blkio-cgroup framework to know
> > > > > which blkio-cgroup is the owner of a page before starting I/O against the page.
> > > > 
> > > > > @@ -464,6 +465,7 @@ int add_to_page_cache_locked(struct page
> > > > >  					gfp_mask & GFP_RECLAIM_MASK);
> > > > >  	if (error)
> > > > >  		goto out;
> > > > > +	blkio_cgroup_set_owner(page, current->mm);
> > > > >  
> > > > 
> > > > This part is doubtful...Is this necessary ? 
> > > > I recommend you that the caller should attach owner by itself.
> > > 
> > > I think that it is reasonable to add the hook right here rather than
> > > to add many hooks to a variety of places.
> > > 
> > Why ? at writing, it's will be overwriten soon, IIUC. Then, this information
> > is misleading. plz add a hook like this when it means something. In this case,
> > read/write callers.
> > IMO, you just increase patch's readbility but decrease easiness of maintaince.
> 
> Even though the owner is overwritten soon at writing, I'm not sure why
> inserting the hook here causes the misleading. I think that it is easy
> to understand when and where the owner is set by blkio-cgroup, and it
> does not decrease maintainability, rather than put many hooks to each
> caller.
>  
Are there _many_ callers ? I don't think so. 
But okay, I don't say strong objections more if other ones say ok.

BTW, a sad information for you.
you can't call lock_page_cgroup() under radix_tree->lock.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e767e0561d7fd2333df1921f1ab4176211f9036b

plz update.

> > 
> > Consider following situation.
> > 
> > - A process "A" has big memory. When several threads requests memory, all 
> >   of them are caught by a blockio cgroup of "A".
> > - A process "B" has read big file caches. When several threads requests memory, 
> >   all  of them are caught by a blockio cgroup of "B".
> > 
> > If "A" and "B" 's threshold is small, you'll see big slow down.
> > But it's not _planned_ behavior in many cases.
> > 
> > If you charges agaisnt memory owner, the admin has to set _big_ priority of I/O
> > controller to "A" and "B" if it uses much memory. I think the admin can't design
> > his system. It's nonsense to say "plz set I/O limit propotional to memory usage of
> > your apps even if it never do I/O in usual."
> >
> > If this blockio cgroup is introduced, people will see *unexpected* very
> > terrible slow down and the user will see heartbeat warnings/failover by cluster
> > management software. Please do I/O at the priority of memory reclaiming requester.
> 
> dm-ioband gives high priority to I/O for swap-out by checking whether
> PG_swapcache flag is set on the I/O page, regardless of the assigned
> I/O bandwidth, and the bandwidth consumed for swap-out is charged to
> the owner of the pages as a debt.
> How about this approach?

I don't think it's reasonable. Why I/O device, scheduler should know about
such mm-related information ? I think layering is wrong.
And your approatch cannot be a workaround.

In follwing _typical_ case,
 
  - A process does small logging to /var/log/mylog, once in a sec.
    but it uses some amount of cold memory or shmem.

This process's logging will be delayed _unexpectedly_ by some buggy process
which does memory leak.


Thanks,
-Kame
