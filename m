From: "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Fri, 22 Jul 2011 11:01:41 +0100
Message-ID: <20110722100141.GB2519@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
	<20110721143622.GB2454@redhat.com>
	<20110721145202.GL17632@redhat.com>
	<20110721152845.GD12373@redhat.com>
	<20110721153620.GO17632@redhat.com>
	<20110721155312.GA19140@tango.0pointer.de>
	<20110721201546.GD2454@redhat.com>
	<20110721203252.GG12373@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>,
	Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721203252.GG12373@redhat.com>
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
Cc: fedora-devel-list@redhat.com, mclasen@redhat.co, cg-manager-developers@lists.fedorahosted.org, lwang@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 04:32:52PM -0400, Vivek Goyal wrote:
> On Thu, Jul 21, 2011 at 04:15:46PM -0400, Jason Baron wrote:
> > On Thu, Jul 21, 2011 at 05:53:13PM +0200, Lennart Poettering wrote:
> > > On Thu, 21.07.11 16:36, Daniel P. Berrange (berrange@redhat.com) wrote:
> > > 
> > > > IIRC, you can already set cgroups configuration in the service's
> > > > systemd unit file, using something like:
> > > > 
> > > >  ControlGroup="cpu:/foo/bar mem:/wizz"
> > > > 
> > > > though I can't find the manpage right now.
> > > 
> > > Yes, this is supported in systemd (though without the "").
> > > 
> > > It's (tersely) documented in systemd.exec(5).
> > > 
> > > My guess is that we'll cover about 90% or so of the usecases of cgroups
> > > if we make it easy to assign cgroup-based limits to VMs, to system
> > > services and to users, like we can do with libvirt and systemd. There's
> > > still a big chunk of the 10% who want more complex setups with more
> > > arbitrary groupings, but I have my doubts the folks doing that are the
> > > ones who need a UI for that.
> > > 
> > 
> > Ok, if systemd is planning to add all these knobs and buttons to cover all of
> > these cgroups use cases, then yes, we probably don't need another management
> > layer nor the UI. I guess we could worry about the more complex setups when
> > we better understand what they are, once systemd has added more cgroup
> > support. (I only recently understood that systemd was adding all this
> > cgroups support). In fact, at that point we probably don't need
> > libcgroup either.
> 
> So the model seems to be that there are various components which control
> their own children. 
> 
> So at top level is systemd which controls users, services and libvirtd
> and will provide interfaces/options to be able to configure cgroups
> and resources for its children.
> 
> Similarly libvirtd will provide interfaces/options to be able to configure
> cgroups/resources for its children (primary VMs and possibly containers at
> some point of time).

FYI, we already use CGroups for our Linux container driver, in fact
it is mandatory, while use of CGroups with KVM is still optional at
this time.

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
