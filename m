From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Date: Wed, 4 Apr 2012 15:19:18 -0400
Message-ID: <20120404191918.GK12676__5229.06773626364$1333567181$gmane$org@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com>
	<20120404185605.GC29686@dhcp-172-17-108-109.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120404185605.GC29686-RcKxWJ4Cfj1J2suj2OqeGauc2jM2gXBXkQQo+JxHRPFibQn6LdNjmg@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 04, 2012 at 11:56:05AM -0700, Tejun Heo wrote:
> On Wed, Apr 04, 2012 at 10:36:04AM -0500, Steve French wrote:
> > > How do you take care of thorottling IO to NFS case in this model? Current
> > > throttling logic is tied to block device and in case of NFS, there is no
> > > block device.
> > 
> > Similarly smb2 gets congestion info (number of "credits") returned from
> > the server on every response - but not sure why congestion
> > control is tied to the block device when this would create
> > problems for network file systems
> 
> I hope the previous replies answered this.  It's about writeback
> getting pressure from bdi and isn't restricted to block devices.

So the controlling knobs for network filesystems will be very different
as current throttling knobs are per device (and not per bdi). So
presumably there will be some throttling logic in network layer (network
tc), and that should communicate the back pressure.

I have tried limiting network traffic on NFS using network controller
and tc but that did not help for variety of reasons.

- We again have the problem of losing submitter's context down the layer.

- We have interesting TCP/IP sequencing issues. I don't have the details
  but if you throttle traffic from one group, it kind of led to some 
  kind of multiple re-transmissions from server for ack due to some
  sequence number issues. Sorry, I am short on details as it was long back
  and nfs guys told me that pNFS might help here.

  The basic problem seemed to that that if you multiplex traffic from
  all cgroups on single tcp/ip session and then choke IO suddenly from
  one of them, that was leading to some sequence number issues and led
  to really sucky performance.

So something to keep in mind while coming up ways for how to implement
throttling for network file systems.

Thanks
Vivek 
