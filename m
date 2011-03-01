From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
Date: Tue, 1 Mar 2011 11:27:53 -0500
Message-ID: <20110301162753.GB2539__34388.2843656049$1298996954$gmane$org@redhat.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1298888105-3778-1-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:

[..]
> TODO
> ~~~~
>  - Consider to add the following new files in the blkio controller to allow the
>    user to explicitly limit async writes as well as sync writes:
> 
>    blkio.throttle.async.write_bps_limit
>    blkio.throttle.async.write_iops_limit

I am kind of split on this.

- One way of thinking is that blkio.throttle.read/write_limits represent
  the limits on requeuest queue of the IO which is actually passing
  through queue now. So we should not mix the two and keep async limits
  separately. This will also tell the customer explicitly that async
  throttling does not mean the same thing as throttling happens before
  entering the page cache and there can be/will be IO spikes later
  at the request queue.

  Also creating the separate files leaves the door open for future
  extension of implementing async control when async IO is actually
  submitted to request queue. (Though I think that will be hard as
  making sure all the filesystems, writeback logic, device mapper
  drivers are aware of throttling and will take steps to ensure faster
  groups are not stuck behind slower groups).

 So keeping async accounting separate will help differentiating that
 async control is not same as sync control. There are fundamental
 differences.


- On the other hand, it makes life a bit simple for user as they don't
  have to specify the async limits separately and there is one aggregate
  limit for sync and async (assuming we fix the throttling state issues
  so that throttling logic can handle both bio and task throttling out
  of single limit).

Any thoughts?

Thanks
Vivek
