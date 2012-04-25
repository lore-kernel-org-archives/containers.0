From: Suresh Jayaraman <sjayaraman-IBi9RG/b67k@public.gmane.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Date: Wed, 25 Apr 2012 14:17:15 +0530
Message-ID: <4F97BA13.8060705__45604.8331027434$1335343665$gmane$org@suse.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com>
	<20120404185605.GC29686@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404191918.GK12676@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120404191918.GK12676-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 04/05/2012 12:49 AM, Vivek Goyal wrote:
> On Wed, Apr 04, 2012 at 11:56:05AM -0700, Tejun Heo wrote:
>> On Wed, Apr 04, 2012 at 10:36:04AM -0500, Steve French wrote:
>>>> How do you take care of thorottling IO to NFS case in this model? Current
>>>> throttling logic is tied to block device and in case of NFS, there is no
>>>> block device.
>>>
>>> Similarly smb2 gets congestion info (number of "credits") returned from
>>> the server on every response - but not sure why congestion
>>> control is tied to the block device when this would create
>>> problems for network file systems
>>
>> I hope the previous replies answered this.  It's about writeback
>> getting pressure from bdi and isn't restricted to block devices.
> 
> So the controlling knobs for network filesystems will be very different
> as current throttling knobs are per device (and not per bdi). So
> presumably there will be some throttling logic in network layer (network
> tc), and that should communicate the back pressure.

Tried to figure out potential use-case scenarios for controlling Network
I/O resource from netfs POV (which ideally should guide the interfaces).

- Is finer grained control of network I/O is desirable/useful or being
  able to control bandwidth at per server level is sufficient? Consider
  the case where there are different NFS volumes mounted from the same
  NFS/CIFS server,

    /backup
    /missioncritical_data
    /apps
    /documents

  admin being able to set bandwidth limits to the each of these
  mounts based on how important would be a useful feature. If we try to
  build the logic in the network layer using tc then this still
  wouldn't be possible to limit the tasks that are writing to more than
  one volumes? (need some logic in netfs as well?). Network filesystem
  clients typically are not bothered much about the actual device but
  about the exported share. So it appears that the controlling knobs
  could be different for netfs.

- Provide minimimum guarantees for the Network I/O to keep going
  irrespective of the overloaded workload situations. i.e. operations
  that are local to the machine should not hamper Network I/O or
  operations that are happening on one mount should not impact
  operations that are happening on another mount.

  IIRC, while we currently would be able to limit maximum usage, we
  don't guarantee the minimum quantity of the resource that would be
  available in general for all controllers. This might be important from
  QoS guarantee POV.

- What are the other use-cases where limiting Network I/O would be
  useful?

> I have tried limiting network traffic on NFS using network controller
> and tc but that did not help for variety of reasons.
> 

A quick look at the current net_tls implementation shows that it allows
setting priorities but doesn't seem to provide ways to limit the
throughput? Or is it still possible?
If not did you use a out-of-tree implementation to test this?

> - We again have the problem of losing submitter's context down the layer.

If the network layer is cgroup aware why this would be a problem?

> - We have interesting TCP/IP sequencing issues. I don't have the details
>   but if you throttle traffic from one group, it kind of led to some 
>   kind of multiple re-transmissions from server for ack due to some
>   sequence number issues. Sorry, I am short on details as it was long back
>   and nfs guys told me that pNFS might help here.
> 
>   The basic problem seemed to that that if you multiplex traffic from
>   all cgroups on single tcp/ip session and then choke IO suddenly from
>   one of them, that was leading to some sequence number issues and led
>   to really sucky performance.
> 
> So something to keep in mind while coming up ways for how to implement
> throttling for network file systems.
> 


Thanks
Suresh
