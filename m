From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Thu, 2 May 2013 14:17:48 -0400
Message-ID: <20130502181747.GH30020@redhat.com>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
	<20130502173428.GA4771@redhat.com>
	<20130502175701.GL19814@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130502175701.GL19814-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 02, 2013 at 10:57:01AM -0700, Tejun Heo wrote:
> Hey, Vivek.
> 
> On Thu, May 02, 2013 at 01:34:28PM -0400, Vivek Goyal wrote:
> > On Wed, May 01, 2013 at 05:39:18PM -0700, Tejun Heo wrote:
> > 
> > [..]
> > > While this patchset contains many patches, the implementation is
> > > pretty straight-forward.  throtl_grp's form a tree anchored at
> > > throtl_data and bios climb the tree as they get dispatched at each
> > > level.  The bios which reach the top of the tree - throl_data - are
> > > issued. 
> > 
> > Have a question here. Looks like when bio climbs from child group
> > to parent group, then parent group slice starts fresh if parent
> > was empty. So if we have a parent with 1MB/s limit and a child with
> > 1MB/s limit and a bio gets queued in child, then looks like effective
> > IO rate would be .5MB/s and not 1MB/s?
> 
> Hmmm.... not that drastic but when the same limit is configured in
> both parent and its single active child, the child gets penalized by
> about 15%, which is not nice.

Sorry, did not understand how did you arrive at 15% penalty. I think
in worst case it will be 50%. Assume size of bio is 1MB. So it will
wait for 1 second in child group and then it will wait again for
another second in parent group. Assume next bio gets queued only
after first bio gets dispatched. 

That means each 1MB bio will wait for 2 second which will lead to
effective rate of .5MB/second.

> 
> > IOW, when child gets queued, we should start time accounting for
> > all parents in the hiearchy too.
> 
> I don't particularly like doing that as a separate step, maybe we can
> just push the child's start time to the parent while dispatching?
> Does that sound doable to you?

May be. But climbing the ladder has unfairness problems too. We might
have to rethink about the hierarchical algorithm altogether.

Thanks
Vivek
