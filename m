From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/11] blkcg: implement per-blkg request allocation
Date: Fri, 27 Apr 2012 13:15:16 -0700
Message-ID: <20120427201516.GJ26595@google.com>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
	<1335477561-11131-12-git-send-email-tj@kernel.org>
	<20120427194654.GN10579@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120427194654.GN10579-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Vivek.

On Fri, Apr 27, 2012 at 03:46:54PM -0400, Vivek Goyal wrote:
> On Thu, Apr 26, 2012 at 02:59:21PM -0700, Tejun Heo wrote:
> 
> [..]
> > @@ -926,6 +936,7 @@ static struct request *__get_request(struct request_list *rl, int rw_flags,
> >  		goto fail_alloc;
> >  
> >  	blk_rq_init(q, rq);
> > +	blk_rq_set_rl(rq, rl);
> 
> Given the fact that we have established the rq and blkg releation at
> the time of allocation, should we modify CFQ to just use that relation
> instread of trying to lookup group again based on bio.

Maybe, given the lookup cache it shouldn't really matter tho.

> We avoid one lookup also we avoid duplicate creation of blkg in following
> corner case of bio==NULL
> 
> 	- blkg_get_rl()
> 	- request allocation fails. sleep, drop queue lock
> 	- process is moved to a different cgroup. origincal cgroup is
> 	  deleted. pre_destroy will cleanup all blkg on blkcg.
> 	- process wakes up, request allocated, set_request sets up new blkg
>  	  based on new cgroup. Now a request is queued in one blkg/cgroup and
>  	  it has come out of the quota of other blkg/cgroup.

I don't think it really matters as long as the request gets freed to
the right queue on completion.

> Well, I have a question. Ideally nobody should be linking any more blkg
> to a blkcg once blkg_pre_destroy() has been called? But can it happen
> that bio_associate_current() takes are reference to blkcg and bio is
> throttled. cgroup associated with bio is deleted resulting in
> pre_destroy(). Now bio is submitted to CFQ and it will try to create
> a new blkg for blkcg-queue pair and once IO is complete, bio will drop
> blkcg reference, which in turn will free up blkcg and associated blkg
> is still around and will not be cleaned up.
> 
> IOW, looks like we need a mechanism to mark a blkcg dead (set in
> pre_destroy() call) and any submissions to blkcg after that should result
> in bio being divered to root group?

Don't we already have that with css_tryget()?

Thanks.

-- 
tejun
