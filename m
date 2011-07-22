From: "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Fri, 22 Jul 2011 11:07:18 +0100
Message-ID: <20110722100718.GC2519@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
	<20110721143622.GB2454@redhat.com>
	<20110721145202.GL17632@redhat.com>
	<20110721161703.GD19140@tango.0pointer.de>
	<20110721205850.GH12373@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>,
	Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721205850.GH12373@redhat.com>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: fedora-devel-list@redhat.com, mclasen@redhat.co, cg-manager-developers@lists.fedorahosted.org, Linda Wang <lwang@redhat.com>, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 04:58:50PM -0400, Vivek Goyal wrote:
> On Thu, Jul 21, 2011 at 06:17:03PM +0200, Lennart Poettering wrote:
> > On Thu, 21.07.11 15:52, Daniel P. Berrange (berrange@redhat.com) wrote:
> > 
> > > > I think its a question of do we want to make users go to a bunch of
> > > > different front end tools, which don't communicate with each other to
> > > > configure the system? I think it makes sense to have libvirt or
> > > > virt-manager and systemd front-end be able to configure cgroups, but I
> > > > think it would be also nice if they could know when the step on each
> > > > other. I think it would also be nice if there was a way to help better
> > > > understand how the various system components are making use of cgroups
> > > > and interacting. I liked to see an integrated desktop approach - not one
> > > > where separate components aren't communicating with each other. 
> > > 
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
> > 
> > systemd (when run as the user) does exactly the same thing btw. It will
> > discover the group it is urnning in, and will create all its groups
> > beneath that.
> > 
> > In fact, right now the cgroup hierarchy is not virtualized. To make sure
> > systemd works fine in a container we employ the very same logic here: if
> > the container manager started systemd in specific cgroup, then system
> > will do all its stuff below that, even if it is PID 1.
> 
> How does the cgroup hierarchy look like in case of containers? I thought
> libvirtd will do all container management and libvirtd is one of the services
> started by systemd.

If we assume systemd placed libvirtd into $LIBVIRT_ROOT, then libvirtd
will create the following hierarchy below that point:

    $LIBVIRT_ROOT  (Where libvirtd lives)
      |
      +- libvirt   (Root for all virtual machines & containers)
          |
          +- lxc   (Root for all LXC containers)
          |   |
          |   +- c1   (Root for container with name c1)
          |   +- c2   (Root for container with name c2)
          |   +- c3   ...
          |   +- ...
          |
          +- qemu  (Root for all QEMU virtual machines)
              |
              +- v1   (Root for virtual machine with name v1)
              +- v2   (Root for virtual machine with name v2)
              +- v3   ...
              +- ...

In the future we might introduce the concept of virtual machine groups
into the API, at which point we might also have separate cgroups to
match those VM groups. That is still TBD.

Primarily the libvirt API is providing you control over the 3rd level
in this hierarchy, eg the individual VM groups. The other levels in
the heirarchy are primarily there so that we can ensure a unique namespace
because we only validate VM name uniqueness within a driver. ie LXC can
have a container called 'demo' and so can QEMU at the same time.

Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
