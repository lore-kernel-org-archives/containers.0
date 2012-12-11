From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: performance drop after using blkcg
Date: Tue, 11 Dec 2012 10:02:34 -0500
Message-ID: <20121211150234.GC5580__9791.67712289399$1355238190$gmane$org@redhat.com>
References: <CAFVn34SxqAJe_4P-WT8MOiG-kmKKD7ge96zoHXQuGqHWPgAt+A@mail.gmail.com>
	<20121211142518.GA5580@redhat.com>
	<20121211142742.GE7084@htj.dyndns.org>
	<20121211144336.GB5580@redhat.com>
	<20121211144718.GF7084@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121211144718.GF7084-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zhao Shuai <zhaoshuai-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Dec 11, 2012 at 06:47:18AM -0800, Tejun Heo wrote:
> Hello,
> 
> On Tue, Dec 11, 2012 at 09:43:36AM -0500, Vivek Goyal wrote:
> > I think if one sets slice_idle=0 and group_idle=0 in CFQ, for all practical
> > purposes it should become and IOPS based group scheduling.
> 
> No, I don't think it is.  You can't achieve isolation without idling
> between group switches.  We're measuring slices in terms of iops but
> what cfq actually schedules are still time slices, not IOs.

I think I have not been able to understand your proposal. Can you explain
a bit more.

This is what CFQ does in iops_mode(). It will calculate the number of
requests dispatched from a group and scale that number based on weight
and put the group back on service tree. So if you have not got your
fair share in terms of number of requests dispatched to the device,
you will be put ahead in the queue and given a chance to dispatch 
requests first. 

Now couple of things.

- There is no idling here. If device is asking for more requests (deep
  queue depth) then this group will be removed from service tree and
  CFQ will move on to serve other queued group. So if there is a dependent
  reader it will lose its share.

  If we try to idle here, then we have solved nothing in terms of
  performance problems.  Device is faster but your workload can't cope
  with it so you are artificially slowing down the device.

- But if all the contending workloads/groups are throwing enough IO
  traffic on the device and don't get expired, they they should be able
  to dispatch number of requests to device in proportion to their weight.

So this is effectively trying to keep track of number of reqeusts
dispatched from the group instead of time slice consumed by group and
then do the scheduling.

cfq_group_served() {
        if (iops_mode(cfqd))
                charge = cfqq->slice_dispatch;
	cfqg->vdisktime += cfq_scale_slice(charge, cfqg);
}

Isn't it effectively IOPS scheduling. One should get IOPS rate in proportion to
their weight (as long as they can throw enough traffic at device to keep
it busy). If not, can you please give more details about your proposal.

Thanks
Vivek
