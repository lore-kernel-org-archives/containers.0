From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 0/5] blk-throttle: writeback and swap IO control
Date: Wed, 23 Feb 2011 09:32:06 +0100
Message-ID: <20110223083206.GA2174__28838.7509565384$1298450116$gmane$org@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<20110222193403.GG28269@redhat.com>
	<20110222224141.GA23723@linux.develer.com>
	<20110223000358.GM28269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110223000358.GM28269-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 22, 2011 at 07:03:58PM -0500, Vivek Goyal wrote:
> > I think we should accept to have an inode granularity. We could redesign
> > the writeback code to work per-cgroup / per-page, etc. but that would
> > add a huge overhead. The limit of inode granularity could be an
> > acceptable tradeoff, cgroups are supposed to work to different files
> > usually, well.. except when databases come into play (ouch!).
> 
> Agreed. Granularity of per inode level might be accetable in many 
> cases. Again, I am worried faster group getting stuck behind slower
> group.
> 
> I am wondering if we are trying to solve the problem of ASYNC write throttling
> at wrong layer. Should ASYNC IO be throttled before we allow task to write to
> page cache. The way we throttle the process based on dirty ratio, can we
> just check for throttle limits also there or something like that.(I think
> that's what you had done in your initial throttling controller implementation?)

Right. This is exactly the same approach I've used in my old throttling
controller: throttle sync READs and WRITEs at the block layer and async
WRITEs when the task is dirtying memory pages.

This is probably the simplest way to resolve the problem of faster group
getting blocked by slower group, but the controller will be a little bit
more leaky, because the writeback IO will be never throttled and we'll
see some limited IO spikes during the writeback. However, this is always
a better solution IMHO respect to the current implementation that is
affected by that kind of priority inversion problem.

I can try to add this logic to the current blk-throttle controller if
you think it is worth to test it.

-Andrea
