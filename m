From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 6 Nov 2008 11:39:57 -0500
Message-ID: <20081106163957.GB7461__4779.29400881312$1225989803$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
	<1225986593.7803.4688.camel@twins>
	<20081106160154.GA7461@redhat.com>
	<1225988173.7803.4723.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1225988173.7803.4723.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Nov 06, 2008 at 05:16:13PM +0100, Peter Zijlstra wrote:
> On Thu, 2008-11-06 at 11:01 -0500, Vivek Goyal wrote:
> 
> > > Does this still require I use dm, or does it also work on regular block
> > > devices? Patch 4/4 isn't quite clear on this.
> > 
> > No. You don't have to use dm. It will simply work on regular devices. We
> > shall have to put few lines of code for it to work on devices which don't
> > make use of standard __make_request() function and provide their own
> > make_request function. 
> > 
> > Hence for example, I have put that few lines of code so that it can work
> > with dm device. I shall have to do something similar for md too.
> > 
> > Though, I am not very sure why do I need to do IO control on higher level
> > devices. Will it be sufficient if we just control only bottom most
> > physical block devices?
> > 
> > Anyway, this approach should work at any level.
> 
> Nice, although I would think only doing the higher level devices makes
> more sense than only doing the leafs.
> 

I thought that we should be doing any kind of resource management only at
the level where there is actual contention for the resources.So in this case
looks like only bottom most devices are slow and don't have infinite bandwidth
hence the contention.(I am not taking into account the contention at 
bus level or contention at interconnect level for external storage,
assuming interconnect is not the bottleneck).

For example, lets say there is one linear device mapper device dm-0 on
top of physical devices sda and sdb. Assuming two tasks in two different
cgroups are reading two different files from deivce dm-0. Now if these
files both fall on same physical device (either sda or sdb), then they
will be contending for resources. But if files being read are on different
physical deivces then practically there is no device contention (Even on
the surface it might look like that dm-0 is being contended for). So if
files are on different physical devices, IO controller will not know it.
He will simply dispatch one group at a time and other device might remain
idle.

Keeping that in mind I thought we will be able to make use of full
available bandwidth if we do IO control only at bottom most device. Doing
it at higher layer has potential of not making use of full available bandwidth.

> Is there any reason we cannot merge this with the regular io-scheduler
> interface? afaik the only problem with doing group scheduling in the
> io-schedulers is the stacked devices issue.

I think we should be able to merge it with regular io schedulers. Apart
from stacked device issue, people also mentioned that it is so closely
tied to IO schedulers that we will end up doing four implementations for
four schedulers and that is not very good from maintenance perspective.

But I will spend more time in finding out if there is a common ground
between schedulers so that a lot of common IO control code can be used
in all the schedulers.

> 
> Could we make the io-schedulers aware of this hierarchy?

You mean IO schedulers knowing that there is somebody above them doing
proportional weight dispatching of bios? If yes, how would that help?

Thanks
Vivek
