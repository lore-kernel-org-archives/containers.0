From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Wed, 4 Apr 2012 12:50:48 -0400
Message-ID: <20120404165048.GF12676@redhat.com>
References: <4F7A261A.9000200@tao.ma> <20120402222504.GA2672@redhat.com>
	<4F7A2B21.5000907@tao.ma> <20120403153736.GI5913@redhat.com>
	<4F7B2708.6080504@tao.ma> <20120403164959.GJ5913@redhat.com>
	<4F7B32AE.7050900@tao.ma>
	<CANejiEU1qAsvogozY3MjZnpcrbYZO4CkRE8s73WGPc_R5LKV9g@mail.gmail.com>
	<20120404133705.GB12676@redhat.com> <4F7C7A91.8040707@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F7C7A91.8040707-d1IQDZat3X0@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 05, 2012 at 12:45:05AM +0800, Tao Ma wrote:

[..]
> > In iops_mode(), expire each cfqq after dispatch of 1 or bunch of requests
> > and you should get the same behavior (with slice_idle=0 and group_idle=0).
> > So why write a new scheduler.
> really? How could we config cfq to work like this? Or you mean we can
> change the code for it?

You can just put a few lines of code to expire queue after 1-2 requests
dispatched from the queue. Than run your workload with slice_idle=0
and group_idle=0 and see what happens.

I don't even know what your workload is. 

> > 
> > Only thing is that with above, current code will provide iops fairness only
> > for groups. We should be able to tweak queue scheduling to support iops
> > fairness also.
> OK, as I have said in another e-mail another my concern is the
> complexity. It will make cfq too much complicated. I just checked the
> source code of shaohua's original patch, fiops scheduler is only ~700
> lines, so with cgroup support added it would be ~1000 lines I guess.
> Currently cfq-iosched.c is around ~4000 lines even after Tejun's cleanup
> of io context...

I think a large chunk of that iops scheduler code will be borrowed from
CFQ code. All the cgroup logic, queue creation logic, group scheduling
logic etc. And that's the reason I was still exploring the possibility 
of having common code base.

Thanks
Vivek
