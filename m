From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 15/20] io-controller: map async requests to appropriate
	cgroup
Date: Fri, 29 May 2009 12:17:37 +0900 (JST)
Message-ID: <20090529.121737.189708024.ryov__20025.7381926805$1243567120$gmane$org@valinux.co.jp>
References: <1243377729-2176-16-git-send-email-vgoyal@redhat.com>
	<20090528.182740.193697101.ryov@valinux.co.jp>
	<20090528165710.GB4335@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090528165710.GB4335-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jbaron-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, May 28, 2009 at 06:27:40PM +0900, Ryo Tsuruta wrote:
> > Hi Vivek,
> > 
> > > +#ifdef CONFIG_TRACK_ASYNC_CONTEXT
> > > +	if (elv_bio_sync(bio)) {
> > > +		/* sync io. Determine cgroup from submitting task context. */
> > > +		cgroup = task_cgroup(current, io_subsys_id);
> > > +		return cgroup;
> > > +	}
> > > +
> > > +	/* Async io. Determine cgroup from with cgroup id stored in page */
> > > +	bio_cgroup_id = get_blkio_cgroup_id(bio);
> > > +
> > > +	if (!bio_cgroup_id)
> > > +		return NULL;
> > > +
> > > +	cgroup = blkio_cgroup_lookup(bio_cgroup_id);
> > > +#else
> > > +	cgroup = task_cgroup(current, io_subsys_id);
> > > +#endif
> > > +	return cgroup;
> > > +}
> > 
> > There is a case where a kernel thread (such as device-mapper drivers)
> > submits a sync IO instead of a task which originates the IO. I think
> > you should always use get_blkio_cgroup_id() to determine cgroup.
> > 
> 
> Hi Ryo,
> 
> Ok. Can you give some examples of drivers which are submitting reads in
> different context al-together. You mentioned in the past that dm-crypt
> looks like the one. How does current CFQ takes care of that. So if a 
> BE prio 7 or an RT prio 0, task is submitting a READ, CFQ will not know it
> and it will put that READ in the queue of the READ submitting device
> mapper thread (may be BE prio 3 or 4)? 

In the case of READ, dm-raid1 submits read IOs in differenct context
under some conditions. dm-ioband also does it.

> Always determining the cgroup from bio, will make things slower at the 
> same time complicated from the CFQ point of view. Right now cfq creates
> and caches the queue pointer in the io context of the bio submitting task
> and assumes sync requests are coming from that task/io context. Currently
> there can only be one sync queue associated with one context. So if a single
> thread is submitting reads (may be a worker thread) on behalf of other
> processes, then we loose the io context information. In fact currently we
> don't even carry ioprio and io class information in bio.
> 
> So looks like we need to carry task io context information also in bio
> to be able to associate the bio to right queue at CFQ level. This makes
> it bit more complicated. For the time being I will keep it in my TODO
> list and handle it once other more severe problems have been taken care
> of.

There is a patchset which makes every bio points the iocontext of the
process which is originally generated an IO request.

  Date Tue, 22 Apr 2008 22:51:31 +0900 (JST)
  Subject [RFC][PATCH 1/10] I/O context inheritance
  From Hirokazu Takahashi <>
  http://lkml.org/lkml/2008/4/22/195

Thanks,
Ryo Tsuruta
