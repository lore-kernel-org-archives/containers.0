From: Lennart Poettering <mzerqung-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 18:36:55 +0200
Message-ID: <20110721163654.GE19140@tango.0pointer.de>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
	<20110721143622.GB2454@redhat.com>
	<20110721145202.GL17632@redhat.com>
	<20110721152845.GD12373@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110721152845.GD12373-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: fedora-devel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, mclasen-H+wXaHxf7aJhl2p70BpVqQ@public.gmane.org, cg-manager-developers-TuqUDEhatI7GMZAyRF5v151Ccm5ICvs9@public.gmane.org, lwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, duffy-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 21.07.11 11:28, Vivek Goyal (vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:

> > It is already possible for different applications to use cgroups
> > without stepping on each other, and without requiring every app
> > to communicate with each other.
> > 
> > As an example, when it starts libvirt will look at what cgroup
> > it has been placed in, and create the VM cgroups below this point.
> > So systemd can put libvirtd in an arbitrary location and set an
> > overall limits for the virtualization service, and it will cap
> > all VMs. No direct communication between systemd & libvirt is
> > required.
> > 
> > If applications similarly take care to honour the location in
> > which they were started, rather than just creating stuff directly
> > in the root cgroup, they too will interoperate nicely.
> > 
> > This is one of the nice aspects to the cgroups hierarchy, and
> > why having tools/daemons which try to arbitrarily re-arrange
> > cgroups systemwide are not very desirable IMHO.
> 
> This will work as long as somebody has done the top level setup and
> planning. For example, if somebody is running bunch of virtual machines
> and hosting some native applications and services also on the machine,
> then he might decide that all the virt machines can only use 8 out of
> 10 cpus and keep 2 cpus free for native services.
> 
> In that case an admin ought to be able to do this top level planning
> before handing out control of sub-hierarchies to respective applications.
> Does systemd allow that as of today?

Right now, systemd only offers you to place services in the cgroups of
your choice, it will not configure any settings on those cgroups. (This
is very likely to change soon though as there is a patch pending that
makes a number of popular controls available as native config options in
systemd.)

For the controllers like "cpuset" or the RT part of "cpu" where you
assign resources from a limited pool we currently have no solution at
all to deal with conflicts. Neither in libcgroup and friends, not in
systemd, not in libvirt.

However, I do think that figuring out the conflicts here is something to
fix at the UI level -- and systemd itself (or libvirt) should not have to
deal with this at all. The UIs should figure that out between
themselves. I think it should be possible to come up with really simple
schemes to deal with this however. For example, have every UI drop in
some dir /var/lib or so a file encoding which resources have been taken
and should not available in the other UIs anymore, maybe with a
descriptive stirng, so that those UIs can show who took it away.

However, I believe that adding something like that should be the last
step to care for in a UI. So far systemd doesn't have any comprehensive
UI. How to deal with conflicts between resource assignments is not a
central problem that would justify moving all the consumers of cgroups
on some additional middleware.

> To allow that I think systemd should either provide native configuration
> capability or build on top of existing libcgroups constructs like
> cgconfig, cgrules.conf to decide how an admin has planned the resource
> management and in what cgroups services have to be launched, IMHO.

For the systemd case I'd assume that a UI which wants to enable the
admin to control cgroup limits would just place a unit file for the
respective service in /etc/systemd/system, use ".include" to pull in the
original unit file, and set the setting it wants to set.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
