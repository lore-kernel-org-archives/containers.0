From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/11] blkcg: make request_queue bypassing on allocation
Date: Fri, 13 Apr 2012 13:47:10 -0700
Message-ID: <20120413204710.GF12233__41840.3457072147$1334350045$gmane$org@google.com>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
	<1334347895-6268-8-git-send-email-tj@kernel.org>
	<20120413203205.GI26383@redhat.com>
	<20120413203726.GE12233@google.com>
	<20120413204446.GK26383@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413204446.GK26383-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 13, 2012 at 04:44:46PM -0400, Vivek Goyal wrote:
> On Fri, Apr 13, 2012 at 01:37:26PM -0700, Tejun Heo wrote:
> 
> [..]
> > blk_cleanup_queue() doesn't use blk_queue_bypass_start() to enter
> > bypass mode.
> 
> Oh now elevator_exit() has been moved into blk_release_queue(). But
> problem will still be there, isn't it? During driver init, most likely driver
> is holding last reference of the queue and blk_release_queue() will be called
> in the context of blk_cleanup_queue() causing the overhead?

Hmmm?  blk_cleanup_queue() will put the queue into bypassing mode
without going through synchronize_rcu() and all the following
bypassing operations just inc/decs bypass_depth without any draining
operation.

Thanks.

-- 
tejun
