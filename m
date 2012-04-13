From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/11] blkcg: make request_queue bypassing on allocation
Date: Fri, 13 Apr 2012 16:55:01 -0400
Message-ID: <20120413205501.GL26383@redhat.com>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
	<1334347895-6268-8-git-send-email-tj@kernel.org>
	<20120413203205.GI26383@redhat.com>
	<20120413203726.GE12233@google.com>
	<20120413204446.GK26383@redhat.com>
	<20120413204710.GF12233@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413204710.GF12233-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 13, 2012 at 01:47:10PM -0700, Tejun Heo wrote:
> On Fri, Apr 13, 2012 at 04:44:46PM -0400, Vivek Goyal wrote:
> > On Fri, Apr 13, 2012 at 01:37:26PM -0700, Tejun Heo wrote:
> > 
> > [..]
> > > blk_cleanup_queue() doesn't use blk_queue_bypass_start() to enter
> > > bypass mode.
> > 
> > Oh now elevator_exit() has been moved into blk_release_queue(). But
> > problem will still be there, isn't it? During driver init, most likely driver
> > is holding last reference of the queue and blk_release_queue() will be called
> > in the context of blk_cleanup_queue() causing the overhead?
> 
> Hmmm?  blk_cleanup_queue() will put the queue into bypassing mode
> without going through synchronize_rcu() and all the following
> bypassing operations just inc/decs bypass_depth without any draining
> operation.

Ok, this is non-obivirious part. The very reason you could do the
optimzation of synchronize_rcu(), was the fact that either somebody
has already called synchronize_rcu() (first caller of blk_bypass_start())
or we know that it is not needed (as we are instanciating queue and no
IO could be going on).

But neither seems to be the case here. So to make sure that blkg_lookup()
under rcu will see the updated value of queue flag (bypass), are we
relying on the fact that caller should see the DEAD flag and not go
ahead with blkg_lookup()?  If yes, atleast it is not obivious.

Thanks
Vivek
