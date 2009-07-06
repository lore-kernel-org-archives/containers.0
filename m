From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 09/25] io-controller: Common hierarchical fair queuing
	code in elevaotor layer
Date: Mon, 6 Jul 2009 10:16:50 -0400
Message-ID: <20090706141650.GD8279__21420.9946491339$1246890293$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-10-git-send-email-vgoyal@redhat.com>
	<4A51657B.7000008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A51657B.7000008-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 06, 2009 at 10:46:19AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +static struct io_group *
> > +io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
> > +{
> > +	struct io_cgroup *iocg;
> > +	struct io_group *iog, *leaf = NULL, *prev = NULL;
> > +	gfp_t flags = GFP_ATOMIC |  __GFP_ZERO;
> > +
> > +	for (; cgroup != NULL; cgroup = cgroup->parent) {
> > +		iocg = cgroup_to_io_cgroup(cgroup);
> > +
> > +		iog = io_cgroup_lookup_group(iocg, key);
> > +		if (iog != NULL) {
> > +			/*
> > +			 * All the cgroups in the path from there to the
> > +			 * root must have a io_group for efqd, so we don't
> > +			 * need any more allocations.
> > +			 */
> > +			break;
> > +		}
> > +
> > +		iog = kzalloc_node(sizeof(*iog), flags, q->node);
> > +		if (!iog)
> > +			goto cleanup;
> > +
> > +		iog->iocg_id = css_id(&iocg->css);
> 
>   Hi Vivek,
> 
>   IMHO, The io_cgroup id is nothing more than keeping track the corresponding iocg.
>   So why not just store iocg pointer in io_group and just get rid of this complexity.
>   I'd like to post a patch to do this change, what's your opinion?
> 

Hi Gui,

You can try that but I suspect that there not much to be gained in
terms of number of lines of code or code complexity. Do try it out though
and we can then have a look at the patch.

Thanks
Vivek
