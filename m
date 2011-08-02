From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Tue, 2 Aug 2011 10:04:05 -0400
Message-ID: <20110802140405.GB6399@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
	<20110721143622.GB2454@redhat.com>
	<20110721145202.GL17632@redhat.com>
	<20110721152845.GD12373@redhat.com>
	<20110721163654.GE19140@tango.0pointer.de>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721163654.GE19140@tango.0pointer.de>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Lennart Poettering <mzerqung@0pointer.de>
Cc: fedora-devel-list@redhat.com, mclasen@redhat.co, cg-manager-developers@lists.fedorahosted.org, lwang@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 06:36:55PM +0200, Lennart Poettering wrote:
> On Thu, 21.07.11 11:28, Vivek Goyal (vgoyal@redhat.com) wrote:
> 
> > > It is already possible for different applications to use cgroups
> > > without stepping on each other, and without requiring every app
> > > to communicate with each other.
> > > 
> > > As an example, when it starts libvirt will look at what cgroup
> > > it has been placed in, and create the VM cgroups below this point.
> > > So systemd can put libvirtd in an arbitrary location and set an
> > > overall limits for the virtualization service, and it will cap
> > > all VMs. No direct communication between systemd & libvirt is
> > > required.
> > > 
> > > If applications similarly take care to honour the location in
> > > which they were started, rather than just creating stuff directly
> > > in the root cgroup, they too will interoperate nicely.
> > > 
> > > This is one of the nice aspects to the cgroups hierarchy, and
> > > why having tools/daemons which try to arbitrarily re-arrange
> > > cgroups systemwide are not very desirable IMHO.
> > 
> > This will work as long as somebody has done the top level setup and
> > planning. For example, if somebody is running bunch of virtual machines
> > and hosting some native applications and services also on the machine,
> > then he might decide that all the virt machines can only use 8 out of
> > 10 cpus and keep 2 cpus free for native services.
> > 
> > In that case an admin ought to be able to do this top level planning
> > before handing out control of sub-hierarchies to respective applications.
> > Does systemd allow that as of today?
> 
> Right now, systemd only offers you to place services in the cgroups of
> your choice, it will not configure any settings on those cgroups. (This
> is very likely to change soon though as there is a patch pending that
> makes a number of popular controls available as native config options in
> systemd.)
> 
> For the controllers like "cpuset" or the RT part of "cpu" where you
> assign resources from a limited pool we currently have no solution at
> all to deal with conflicts. Neither in libcgroup and friends, not in
> systemd, not in libvirt.

It is not just "cpuset" or "RT part of cpu". This resource thing can apply
to simple thing like cpu shares or blkio controller weigts. For example,
one notion people seem to have to be able view division of system
resources in terms of percentage. Currently we don't have any way to
deal with it and if we want to achieve it then one would require overall
view of the hierarchy to be able to tell whether a certain group has got
certain % of something or not. If there is a separate manager for separate
parts of hierarchy, it is hard to do so.

So if we want to offer more sophisticated features to admin, then design
becomes somewhat complex and I am not sure if it is worth or not.

Also there is a question what kind of interface should be exposed to a
user/admin when it comes to allocating resources to cgroup. Saying that
give a virtual machine/group a cpu weight of 512 does not mean much. If
one wants to translate this number to a certain %, then he needs the
gloabl view.

Similarly some absolute max limits like offered by some controllers like
blkio, cpu might not make much sense if parent has been throttled to even
a smaller limit.

All this raises the question of how the design of UI/command line look
like for configuring cgroups/limits on various things like
users/services/virtual machines. Right now libvirt seems to be allowing
to specify name of the guest domain and some cgroups parameters (cpu
shares, blkio weight etc) for that domain. Again, in an hierarchy
specifying that does not mean anything in absolute system picture until
and unless somebody has overall view of the system.

This also raises the interesting question how cgroup interface of other
UIs in the system should evolve. 

So I have lots of questions/concerns but do not have good answers.
Hopefully this discussion can lead to some of the answers.

Thanks
Vivek
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
