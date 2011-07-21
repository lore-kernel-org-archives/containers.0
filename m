From: Jason Baron <jbaron@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 16:15:46 -0400
Message-ID: <20110721201546.GD2454@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
	<20110721143622.GB2454@redhat.com>
	<20110721145202.GL17632@redhat.com>
	<20110721152845.GD12373@redhat.com>
	<20110721153620.GO17632@redhat.com>
	<20110721155312.GA19140@tango.0pointer.de>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721155312.GA19140@tango.0pointer.de>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: mzerqung@0pointer.de
Cc: fedora-devel-list@redhat.com, mclasen@redhat.co, cg-manager-developers@lists.fedorahosted.org, lwang@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 05:53:13PM +0200, Lennart Poettering wrote:
> On Thu, 21.07.11 16:36, Daniel P. Berrange (berrange@redhat.com) wrote:
> 
> > IIRC, you can already set cgroups configuration in the service's
> > systemd unit file, using something like:
> > 
> >  ControlGroup="cpu:/foo/bar mem:/wizz"
> > 
> > though I can't find the manpage right now.
> 
> Yes, this is supported in systemd (though without the "").
> 
> It's (tersely) documented in systemd.exec(5).
> 
> My guess is that we'll cover about 90% or so of the usecases of cgroups
> if we make it easy to assign cgroup-based limits to VMs, to system
> services and to users, like we can do with libvirt and systemd. There's
> still a big chunk of the 10% who want more complex setups with more
> arbitrary groupings, but I have my doubts the folks doing that are the
> ones who need a UI for that.
> 

Ok, if systemd is planning to add all these knobs and buttons to cover all of
these cgroups use cases, then yes, we probably don't need another management
layer nor the UI. I guess we could worry about the more complex setups when
we better understand what they are, once systemd has added more cgroup
support. (I only recently understood that systemd was adding all this
cgroups support). In fact, at that point we probably don't need
libcgroup either.

thanks,

-Jason
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
