From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IOPS based scheduler (Was: Re: [PATCH 18/21] blkcg: move
	blkio_group_conf->weight to cfq)
Date: Wed, 4 Apr 2012 11:10:14 -0400
Message-ID: <20120404151014.GD12676__44616.2042477683$1333552228$gmane$org@redhat.com>
References: <4F7A261A.9000200@tao.ma> <20120402222504.GA2672@redhat.com>
	<4F7A2B21.5000907@tao.ma> <20120403153736.GI5913@redhat.com>
	<4F7B2708.6080504@tao.ma> <20120403164959.GJ5913@redhat.com>
	<4F7B32AE.7050900@tao.ma>
	<CANejiEU1qAsvogozY3MjZnpcrbYZO4CkRE8s73WGPc_R5LKV9g@mail.gmail.com>
	<20120404133705.GB12676@redhat.com>
	<CANejiEVD6nFVqX8Jf_hmRHg8YyBvPxbTVjgEif3mO1aa925KkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANejiEVD6nFVqX8Jf_hmRHg8YyBvPxbTVjgEif3mO1aa925KkQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 04, 2012 at 07:52:24AM -0700, Shaohua Li wrote:

[..]
> Agreed, we can tweak cfq to make it support iops fairness because the two
> are conceptually the same. The problem is if this is a mess. CFQ is quite
> complicated already. In iops mode, a lot of code isn't required, like idle,
> queue merging, thinktime/seek detection and so on, as the scheduler
> will be only for ssd. With recent iocontext cleanup, the iops scheduler
> code is quite short actually.

Ok, this is somewhat a better reason to have a separate scheduler. I guess
we need to look that actual iops code and that can help decide whether
to keep it as a separate scheduler.

One question is still unanswered though. What real workload benefits
from it? If you are not doing idling in iops based scheduler, I doubt
you are doing to see much service differentiation on fast SSDs. As for
service differentiation IO queues have to be continuously backlogged and
total IOPS needed by applications need to be more than what disk can
offer. It becomes very hard to produe continuously backlogged queues
because real applications tend to read some data, proces data and then
generate more IO. 

Thanks
Vivek
