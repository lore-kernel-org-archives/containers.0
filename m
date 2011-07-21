From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 11:28:45 -0400
Message-ID: <20110721152845.GD12373@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
	<20110721143622.GB2454@redhat.com>
	<20110721145202.GL17632@redhat.com>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721145202.GL17632@redhat.com>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: fedora-devel-list@redhat.com, mclasen@redhat.co, cg-manager-developers@lists.fedorahosted.org, lwang@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 03:52:03PM +0100, Daniel P. Berrange wrote:
> On Thu, Jul 21, 2011 at 10:36:23AM -0400, Jason Baron wrote:
> > Hi,
> > 
> > On Wed, Jul 20, 2011 at 07:01:30PM -0400, Matthias Clasen wrote:
> > > On Wed, 2011-07-20 at 15:20 -0400, Jason Baron wrote:
> > > > Hi,
> > > > 
> > > > I've been working on a new gui tool for managing and monitoring cgroups, called
> > > > 'cg-manager'. I'm hoping to get people interested in contributing to this
> > > > project, as well as to add to the conversation about how cgroups should
> > > > be configured and incorporated into distros.
> > > > 
> > > 
> > > As a high-level comment, I don't think 'cgroup management' is a very
> > > compelling rationale for an end-user graphical tool.
> > > 
> > > For most people it will be much better to expose cgroup information in
> > > the normal process monitor. For people who want to use the specific
> > > cgroup functionality of systemd, it will be better to have that
> > > functionality available in a new service management frontend.
> > 
> > I've thought that displaying at least the cgroup that a process is part of would
> > be nice in the system monitor as well.
> > 
> > I think its a question of do we want to make users go to a bunch of
> > different front end tools, which don't communicate with each other to
> > configure the system? I think it makes sense to have libvirt or
> > virt-manager and systemd front-end be able to configure cgroups, but I
> > think it would be also nice if they could know when the step on each
> > other. I think it would also be nice if there was a way to help better
> > understand how the various system components are making use of cgroups
> > and interacting. I liked to see an integrated desktop approach - not one
> > where separate components aren't communicating with each other. 
> 
> It is already possible for different applications to use cgroups
> without stepping on each other, and without requiring every app
> to communicate with each other.
> 
> As an example, when it starts libvirt will look at what cgroup
> it has been placed in, and create the VM cgroups below this point.
> So systemd can put libvirtd in an arbitrary location and set an
> overall limits for the virtualization service, and it will cap
> all VMs. No direct communication between systemd & libvirt is
> required.
> 
> If applications similarly take care to honour the location in
> which they were started, rather than just creating stuff directly
> in the root cgroup, they too will interoperate nicely.
> 
> This is one of the nice aspects to the cgroups hierarchy, and
> why having tools/daemons which try to arbitrarily re-arrange
> cgroups systemwide are not very desirable IMHO.

This will work as long as somebody has done the top level setup and
planning. For example, if somebody is running bunch of virtual machines
and hosting some native applications and services also on the machine,
then he might decide that all the virt machines can only use 8 out of
10 cpus and keep 2 cpus free for native services.

In that case an admin ought to be able to do this top level planning
before handing out control of sub-hierarchies to respective applications.
Does systemd allow that as of today?

Secondly not all applications are going to do the cgroup management. So
we still need a common system wide tool which can do the monitoring
to figure out the problems and also be able to do atlest top level
resource planning before it allows the applications to do their own
planning with-in their top level group.

To allow that I think systemd should either provide native configuration
capability or build on top of existing libcgroups constructs like
cgconfig, cgrules.conf to decide how an admin has planned the resource
management and in what cgroups services have to be launched, IMHO.

> 
> > > The only role I could see for this kind of dedicated cgroup UI would be
> > > as a cgroup debugging aid, but is that really worth the effort,
> > > considering most cgroup developers probably prefer to use cmdline tools
> > > for the that purpose ?
> > > 
> > > 
> > 
> > The reason I started looking at this was b/c there were requests to be
> > able to use a GUI to configure cgroups. Correct me if I'm wrong, but  the answer
> > is go to the virt-manager gui, then the systemd front end, and then hand edit
> > cgrules.conf for custom rules. And then hope you don't start services in
> > the wrong order.
> 
> My point is that 'configure cgroups' is not really a task users would
> need to. Going to virt-manager GUI, then systemd GUI, and so on is not
> likely to be a problem in the real world usage, because the users tasks
> do not require that they go through touch every single cgroup on the
> system at once.
> 
> People who are using virtualization, will already be using virt-manager
> to configure their VMs, so of course they expect to be able to control
> the VMs's resource utilization from there, rather than any external tool
> 
> People who are configuring system services and want to control the
> resources of a service on their system, would expect todo so in the
> same tool where they are enabling their service,.

Same thing can be extended to user configuraiton and resources also. One
big difference here as compared to libvirt is that there is no wrapper
tool to manage everything. There needs to be a tool to be able to provide
a way so that admin can set reousources for users/services and then
systemd should be able to read those policies and execute it.

Thanks
Vivek
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
