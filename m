From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Mon, 8 Apr 2013 15:46:31 -0400
Message-ID: <20130408194630.GH28292@redhat.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<20130408175925.GE28292@redhat.com>
	<20130408181607.GI3021@htj.dyndns.org>
	<20130408191105.GG28292@redhat.com>
	<20130408192024.GL3021@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130408192024.GL3021-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 08, 2013 at 12:20:24PM -0700, Tejun Heo wrote:

[..]
> > For example, one might want to say that maximum IO bandwidth for 
> > virtual machine virt1 on disk sda should be 10MB/s. Now libvirt
> > should be able to save it in virtual machine specific configuration
> > easily and whenever virtual machine is started, create a children
> > cgroup, set the limits as specified.
> 
> Yes, sure, libvirt can *request* whatever it seems appropriate to the
> central authority, which will decide whether it'll be able to honor
> the request and grant it if possible and allowed by policies in
> effect.

10MB/s is an absolute limit. So I guess there is nothing to be requested
from an central authority here in terms of resources.

Even in the case of IO weight or cpu shares, there is nothing to be asked
from central authority. Well, there is. Creation of new croups changes
effective %share of peer groups. More below.

Where it makes sense though is if one says give a particular service
25% cpu. Then suddenly all the peer and parent entities become important.
IIUC, initial draft of workman does not address this issue.

It would be good to think more about it. How a user can ensure minimum
resources to a partition/service. Because in that case at every level
somebody needs to keep track how much of resources have been committed
as minimum requirements and more consumers can't be allowed at same level.
(This sounds like cpu RT time division among various cgroups).

Thanks
Vivek
