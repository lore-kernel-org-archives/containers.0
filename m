From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Sun, 9 Nov 2008 20:40:24 +1100
Message-ID: <20081109094024.GE2373__9985.02773368291$1226223872$gmane$org@disturbed>
References: <20081106153022.215696930@redhat.com>
	<1225986593.7803.4688.camel@twins>
	<20081106160154.GA7461@redhat.com>
	<1225988173.7803.4723.camel@twins>
	<20081106163957.GB7461@redhat.com>
	<1225990327.7803.4776.camel@twins> <491321ED.5010103@redhat.com>
	<1225991487.7803.4801.camel@twins>
	<20081107004131.GD2373@disturbed>
	<1226053904.7803.5856.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1226053904.7803.5856.camel@twins>
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

On Fri, Nov 07, 2008 at 11:31:44AM +0100, Peter Zijlstra wrote:
> On Fri, 2008-11-07 at 11:41 +1100, Dave Chinner wrote:
> > On Thu, Nov 06, 2008 at 06:11:27PM +0100, Peter Zijlstra wrote:
> > > On Thu, 2008-11-06 at 11:57 -0500, Rik van Riel wrote:
> > > > Peter Zijlstra wrote:
> > > > 
> > > > > The only real issue I can see is with linear volumes, but
> > > > > those are stupid anyway - non of the gains but all the
> > > > > risks.
> > > > 
> > > > Linear volumes may well be the most common ones.
> > > > 
> > > > People start out with the filesystems at a certain size,
> > > > increasing onto a second (new) disk later, when more space
> > > > is required.
> > > 
> > > Are they aware of how risky linear volumes are? I would
> > > discourage anyone from using them.
> > 
> > In what way are they risky?
> 
> You loose all your data when one disk dies, so your mtbf decreases
> with the number of disks in your linear span.  And you get non of
> the benefits from having multiple disks, like extra speed from
> striping, or redundancy from raid.

Fmeh. Step back and think for a moment. How does every major
distro build redundant root drives?

Yeah, they build a mirror and then put LVM on top of the mirror
to partition it. Each partition is a *linear volume*, but
no single disk failure is going to lose data because it's
been put on top of a mirror.

IOWs, reliability of linear volumes is only an issue if you don't
build redundancy into your storage stack.  Just like RAID0, a single
disk failure will lose data.  So, most people use linear volumes on
top of RAID1 or RAID5 to avoid such a single disk failure problem.
People do the same thing with RAID0 - it's what RAID10 and RAID50
do....

Also, linear volume performance scalability is on a different axis
to striping. Striping improves bandwidth, but each disk in a stripe
tends to make the same head movements. Hence striping improves
sequential throughput but only provides limited iops scalability.
Effectively, striping only improves throughput while the disks are
not seeking a lot. Add a few parallel I/O streams, and a stripe will
start to slow down as each disk seeks between streams.  i.e. disks
in stripes cannot be considered to be able to operate independently.

Linear voulmes create independent regions within the address space -
the regions can seek independently when under concurrent I/O and
hence iops scalability is much greater. Aggregate bandwidth is the
same a striping, it's just that a single stream is limited in
throughput. If you want to improve single stream throughput,
you stripe before you concatenate.

That's why people create layered storage systems like this:

	linear volume
	  |->stripe
	      |-> md RAID5
		   |-> disk
		   |-> disk
		   |-> disk
		   |-> disk
		   |-> disk
	      |-> md RAID5
		   |-> disk
		   |-> disk
		   |-> disk
		   |-> disk
		   |-> disk
	  |->stripe
	      |-> md RAID5
	      ......
	  |->stripe
	  ......

What you then need is a filesystem that can spread the load over
such a layout. Lets use, for argument's sake, XFS and tell it the
geometry of the RAID5 luns that make up the volume so that it's
allocation is all nicely aligned.  Then we match the allocation
group size to the size of each independent part of the linear
volume.  Now when XFS spreads it's inodes and data over multiple
AGs, it's spreading the load across disks that can operate
concurrently....

Effectively, linear volumes are about as dangerous as striping.
If you don't build in redundancy at a level below the linear
volume or stripe, then you lose when something fails.

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
