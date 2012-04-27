From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/11] blkcg: implement per-blkg request allocation
Date: Fri, 27 Apr 2012 10:25:19 -0700
Message-ID: <20120427172519.GB26595__9757.27474219657$1335547532$gmane$org@google.com>
References: <1335477561-11131-12-git-send-email-tj@kernel.org>
	<x49wr51usxi.fsf@segfault.boston.devel.redhat.com>
	<20120427150217.GK27486@google.com>
	<20120427154033.GJ10579@redhat.com>
	<20120427154502.GM27486@google.com>
	<20120427154841.GA16237@redhat.com>
	<20120427155140.GN27486@google.com>
	<20120427155612.GK10579@redhat.com>
	<20120427162012.GP27486@google.com>
	<20120427172110.GM10579@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120427172110.GM10579-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Apr 27, 2012 at 01:21:10PM -0400, Vivek Goyal wrote:
> For non-priviliged users, something along the lines of per session
> cpu autogroup might make sense.  But even then if some IO is submitted
> from that autoblkgroup, kernel can't claim that memory till IO is
> completed.
> 
> So per cgroup number of request will probably be a problem even if
> kenrel managed those completely.

My point was that trying to solve all the policy decisions in kernel
proper is not a very good idea.

> So are you planning to put a patch in kernel to disallow cgroup creation
> for non-priviliged users?

No, I'm not gonna break the current users.  It's just not the
direction I want to take cgroup towards and the current breakages will
remain broken.

Thanks.

-- 
tejun
