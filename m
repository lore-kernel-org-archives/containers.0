From: "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 11:03:08 +0100
Message-ID: <20110721100308.GC17632@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>,
	Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <1311202891.5681.5.camel@planemask>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Development discussions related to Fedora <devel@lists.fedoraproject.org>
Cc: fedora-devel-list@redhat.com, containers@lists.osdl.org, cg-manager-developers@lists.fedorahosted.org, duffy@redhat.com
List-Id: containers.vger.kernel.org

On Wed, Jul 20, 2011 at 07:01:30PM -0400, Matthias Clasen wrote:
> On Wed, 2011-07-20 at 15:20 -0400, Jason Baron wrote:
> > Hi,
> > 
> > I've been working on a new gui tool for managing and monitoring cgroups, called
> > 'cg-manager'. I'm hoping to get people interested in contributing to this
> > project, as well as to add to the conversation about how cgroups should
> > be configured and incorporated into distros.
> > 
> 
> As a high-level comment, I don't think 'cgroup management' is a very
> compelling rationale for an end-user graphical tool.
> 
> For most people it will be much better to expose cgroup information in
> the normal process monitor. For people who want to use the specific
> cgroup functionality of systemd, it will be better to have that
> functionality available in a new service management frontend.
> 
> The only role I could see for this kind of dedicated cgroup UI would be
> as a cgroup debugging aid, but is that really worth the effort,
> considering most cgroup developers probably prefer to use cmdline tools
> for the that purpose ?

I tend to agree. CGroups is really just a low level piece of infrastructure
to be used as a building block by higher level services like systemd or
libvirt. End users shouldn't know or care about cgroups directly, but
instead work off higher level concepts like

  "Allow this virtual machine a max 30% of total CPU time"

This kind of policy is best expressed in the virtualization management
tool, or in the system services configuration tool, or another high
level application.

An end user tool for directly managing low level cgroups is not only an
inappropriate level of abstraction for users, but it will make it trivial
for users to totally screw up the use cgroups by things like systemd /
libvirt by moving groups/processes to unexpected places.

Regards,
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
