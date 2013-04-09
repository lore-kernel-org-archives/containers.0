From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Tue, 9 Apr 2013 16:04:22 -0500
Message-ID: <20130409210422.GA31120@sergelap>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<20130409095024.GI25576@redhat.com>
	<20130409193851.GJ6186@mtj.dyndns.org>
	<20130409194640.GK6186@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130409194640.GK6186-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> A bit of addition.
> 
> On Tue, Apr 09, 2013 at 12:38:51PM -0700, Tejun Heo wrote:
> > > We need to make the distribute approach work in order to support
> > > containers, which requiring them to have a back-channel open to
> > > the host userspace. If we can do that, then we've solved the problem
> 
> Why is back-channel such a bad thing?  Even fully virtualized
> environments do special things to communicate with the host (the whole
> stack of virt drivers).  It is sub-optimal and pointless to make
> everything completely transparent.  There's nothing wrong with the
> basesystem knowing that they're inside a container or a virtualized
> environment, so I don't understand why a back-channel is such a big
> problem.

Agreed, that's fine so long as it will be a consistent interface.
Ideally, we could do it in a way that the container monitor can
transparently proxy between userspace inside the container and the
library on the host - so that userspace can 'use cgroups' the same
way no matter where it is.

So for instance if there is a dbus call saying "please create cgroup
/x with (some constraints) and put $$ into it", "something" in the
container can convert that into "please create cgroup /lxc/c1/x
and put (host_uid($$)) into it" and pass that to the host's (or
parent container's) "something".

So perhaps it is best if the container monitor, living in the parent
namespaces, opens a socket '@cgroup_monitor' in the container
namespace (through setns), listens for container-userpsace requests
there, and passes them on to the host's monitor (which hopefully
also listens on '@cgroup_monitor', @ being '\0').  Note that my
mentino of converting pids requires a new kernel feature which we
don't currently have (but have wanted for a long time).

-serge
