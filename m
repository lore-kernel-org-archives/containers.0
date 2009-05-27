From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] io-controller: Add io group reference handling for request
Date: Wed, 27 May 2009 15:56:31 +0900 (JST)
Message-ID: <20090527.155631.226800550.ryov__8854.33995067633$1243407435$gmane$org@valinux.co.jp>
References: <20090518140114.GB27080@redhat.com> <20090518143921.GE3113@linux>
	<20090526.203424.39179999.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090526.203424.39179999.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Andrea and Vivek,

Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> Hi Andrea and Vivek,
> 
> From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Subject: Re: [PATCH] io-controller: Add io group reference handling for request
> Date: Mon, 18 May 2009 16:39:23 +0200
> 
> > On Mon, May 18, 2009 at 10:01:14AM -0400, Vivek Goyal wrote:
> > > On Sun, May 17, 2009 at 12:26:06PM +0200, Andrea Righi wrote:
> > > > On Fri, May 15, 2009 at 10:06:43AM -0400, Vivek Goyal wrote:
> > > > > On Fri, May 15, 2009 at 09:48:40AM +0200, Andrea Righi wrote:
> > > > > > On Fri, May 15, 2009 at 01:15:24PM +0800, Gui Jianfeng wrote:
> > > > > > > Vivek Goyal wrote:
> > > > > > > ...
> > > > > > > >  }
> > > > > > > > @@ -1462,20 +1462,27 @@ struct io_cgroup *get_iocg_from_bio(stru
> > > > > > > >  /*
> > > > > > > >   * Find the io group bio belongs to.
> > > > > > > >   * If "create" is set, io group is created if it is not already present.
> > > > > > > > + * If "curr" is set, io group is information is searched for current
> > > > > > > > + * task and not with the help of bio.
> > > > > > > > + *
> > > > > > > > + * FIXME: Can we assume that if bio is NULL then lookup group for current
> > > > > > > > + * task and not create extra function parameter ?
> > > > > > > >   *
> > > > > > > > - * Note: There is a narrow window of race where a group is being freed
> > > > > > > > - * by cgroup deletion path and some rq has slipped through in this group.
> > > > > > > > - * Fix it.
> > > > > > > >   */
> > > > > > > > -struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
> > > > > > > > -					int create)
> > > > > > > > +struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
> > > > > > > > +					int create, int curr)
> > > > > > > 
> > > > > > >   Hi Vivek,
> > > > > > > 
> > > > > > >   IIUC we can get rid of curr, and just determine iog from bio. If bio is not NULL,
> > > > > > >   get iog from bio, otherwise get it from current task.
> > > > > > 
> > > > > > Consider also that get_cgroup_from_bio() is much more slow than
> > > > > > task_cgroup() and need to lock/unlock_page_cgroup() in
> > > > > > get_blkio_cgroup_id(), while task_cgroup() is rcu protected.
> > > > > > 
> > > > > 
> > > > > True.
> > > > > 
> > > > > > BTW another optimization could be to use the blkio-cgroup functionality
> > > > > > only for dirty pages and cut out some blkio_set_owner(). For all the
> > > > > > other cases IO always occurs in the same context of the current task,
> > > > > > and you can use task_cgroup().
> > > > > > 
> > > > > 
> > > > > Yes, may be in some cases we can avoid setting page owner. I will get
> > > > > to it once I have got functionality going well. In the mean time if
> > > > > you have a patch for it, it will be great.
> > > > > 
> > > > > > However, this is true only for page cache pages, for IO generated by
> > > > > > anonymous pages (swap) you still need the page tracking functionality
> > > > > > both for reads and writes.
> > > > > > 
> > > > > 
> > > > > Right now I am assuming that all the sync IO will belong to task
> > > > > submitting the bio hence use task_cgroup() for that. Only for async
> > > > > IO, I am trying to use page tracking functionality to determine the owner.
> > > > > Look at elv_bio_sync(bio).
> > > > > 
> > > > > You seem to be saying that there are cases where even for sync IO, we
> > > > > can't use submitting task's context and need to rely on page tracking
> > > > > functionlity? 
> 
> I think that there are some kernel threads (e.g., dm-crypt, LVM and md
> devices) which actually submit IOs instead of tasks which originate the
> IOs. When IOs are submitted from such kernel threads, we can't use
> submitting task's context to determine to which cgroup the IO belongs.
> 
> > > > > In case of getting page (read) from swap, will it not happen
> > > > > in the context of process who will take a page fault and initiate the
> > > > > swap read?
> > > > 
> > > > No, for example in read_swap_cache_async():
> > > > 
> > > > @@ -308,6 +309,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
> > > >  		 */
> > > >  		__set_page_locked(new_page);
> > > >  		SetPageSwapBacked(new_page);
> > > > +		blkio_cgroup_set_owner(new_page, current->mm);
> > > >  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
> > > >  		if (likely(!err)) {
> > > >  			/*
> > > > 
> > > > This is a read, but the current task is not always the owner of this
> > > > swap cache page, because it's a readahead operation.
> > > > 
> > > 
> > > But will this readahead be not initiated in the context of the task taking
> > > the page fault?
> > > 
> > > handle_pte_fault()
> > > 	do_swap_page()
> > > 		swapin_readahead()
> > > 			read_swap_cache_async()
> > > 
> > > If yes, then swap reads issued will still be in the context of process and
> > > we should be fine?
> > 
> > Right. I was trying to say that the current task may swap-in also pages
> > belonging to a different task, so from a certain point of view it's not
> > so fair to charge the current task for the whole activity. But ok, I
> > think it's a minor issue.
> > 
> > > 
> > > > Anyway, this is a minor corner case I think. And probably it is safe to
> > > > consider this like any other read IO and get rid of the
> > > > blkio_cgroup_set_owner().
> > > 
> > > Agreed.
> > > 
> > > > 
> > > > I wonder if it would be better to attach the blkio_cgroup to the
> > > > anonymous page only when swap-out occurs.
> > > 
> > > Swap seems to be an interesting case in general. Somebody raised this
> > > question on lwn io controller article also. A user process never asked
> > > for swap activity. It is something enforced by kernel. So while doing
> > > some swap outs, it does not seem too fair to charge the write out to
> > > the process page belongs to and the fact of the matter may be that there
> > > is some other memory hungry application which is forcing these swap outs.
> > > 
> > > Keeping this in mind, should swap activity be considered as system
> > > activity and be charged to root group instead of to user tasks in other
> > > cgroups?
> > 
> > In this case I assume the swap-in activity should be charged to the root
> > cgroup as well.
> > 
> > Anyway, in the logic of the memory and swap control it would seem
> > reasonable to provide IO separation also for the swap IO activity.
> > 
> > In the MEMHOG example, it would be unfair if the memory pressure is
> > caused by a task in another cgroup, but with memory and swap isolation a
> > memory pressure condition can only be caused by a memory hog that runs
> > in the same cgroup. From this point of view it seems more fair to
> > consider the swap activity as the particular cgroup IO activity, instead
> > of charging always the root cgroup.
> > 
> > Otherwise, I suspect, memory pressure would be a simple way to blow away
> > any kind of QoS guarantees provided by the IO controller.
> > 
> > >   
> > > > I mean, just put the
> > > > blkio_cgroup_set_owner() hook in try_to_umap() in order to keep track of
> > > > the IO generated by direct reclaim of anon memory. For all the other
> > > > cases we can simply use the submitting task's context.
> 
> I think that only putting the hook in try_to_unmap() doesn't work
> correctly, because IOs will be charged to reclaiming processes or
> kswapd. These IOs should be charged to processes which cause memory
> pressure.

Consider the following case:

  (1) There are two processes Proc-A and Proc-B.
  (2) Proc-A maps a large file into many pages by mmap() and writes
      many data to the file.
  (3) After (2), Proc-B try to get a page, but there are no available
      pages because Proc-A has used them.
  (4) kernel starts to reclaim pages, call try_to_unmap() to unmap
      a page which is owned by Proc-A, then blkio_cgroup_set_owner()
      sets Proc-B's ID on the page because the task's context is Proc-B.
  (5) After (4), kernel writes the page out to a disk. This IO is
      charged to Proc-B.

In the above case, I think that the IO should be charged to a Proc-A,
because the IO is caused by Proc-A's memory pressure. 
I think we should consider in the case without memory and swap
isolation.

Thanks,
Ryo Tsuruta

> > > > BTW, O_DIRECT is another case that is possible to optimize, because all
> > > > the bios generated by direct IO occur in the same context of the current
> > > > task.
> > > 
> > > Agreed about the direct IO optimization.
> > > 
> > > Ryo, what do you think? would you like to do include these optimizations
> > > by the Andrea in next version of IO tracking patches?
> > >  
> > > Thanks
> > > Vivek
> > 
> > Thanks,
> > -Andrea
> 
> Thanks,
> Ryo Tsuruta
