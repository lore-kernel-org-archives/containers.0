From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Thu, 2 May 2013 14:45:14 -0400
Message-ID: <20130502184514.GI30020@redhat.com>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
	<20130502173428.GA4771@redhat.com>
	<20130502175701.GL19814@mtj.dyndns.org>
	<20130502181747.GH30020@redhat.com>
	<20130502182933.GN19814@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130502182933.GN19814-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On Thu, May 02, 2013 at 11:29:33AM -0700, Tejun Heo wrote:
> Hello, Vivek.
> 
> On Thu, May 02, 2013 at 02:17:48PM -0400, Vivek Goyal wrote:
> > Sorry, did not understand how did you arrive at 15% penalty. I think
> > in worst case it will be 50%. Assume size of bio is 1MB. So it will
> 
> Oh, that's the number I got by running test.
> 
> > wait for 1 second in child group and then it will wait again for
> > another second in parent group. Assume next bio gets queued only
> > after first bio gets dispatched. 
> > 
> > That means each 1MB bio will wait for 2 second which will lead to
> > effective rate of .5MB/second.
> 
> Then the scheduling algorithm is broken in itself regardless of
> hierarchy.  That means an issuer which issues at exact the exactly
> configured pace gets penalized, right?

I did not understand this point. In flat model, application issuing
at configured page will not get penalized.

This penalty is coming from the fact that we are moving bios after the
wait and make them wait in another queue.

In flat model there is no such problem. So to me, it is the problem
of how hierarchical scheduling is implemented. In flat model, I did
not have to deal with it.

> 
> > > I don't particularly like doing that as a separate step, maybe we can
> > > just push the child's start time to the parent while dispatching?
> > > Does that sound doable to you?
> > 
> > May be. But climbing the ladder has unfairness problems too. We might
> > have to rethink about the hierarchical algorithm altogether.
> 
> Meh, it's not different from flat case.  It gives workable enough
> fairness from the simple fact that the queues at each layer are FIFO.
> Beyond that, as long as the limits are honored, it's fine.  If this
> thing is going to be used for high-bandwidth applications, it should
> probably get reimplemented as per-cpu token distributing hierarchy,
> but blk-throttle is not gonna hold back the whole cgroup hierarchy
> support.  If you want to reimplement the whole thing, please feel free
> to do so afterwards.

Ok. Not having a perfect algorithm now is fine. We can always redo it
later.

Thanks
Vivek
