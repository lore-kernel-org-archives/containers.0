From: Lennart Poettering <mzerqung@0pointer.de>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Fri, 22 Jul 2011 02:32:08 +0200
Message-ID: <20110722003208.GB16928@tango.0pointer.de>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110721142053.GA2454@redhat.com>
	<20110721161124.GC19140@tango.0pointer.de>
	<20110721230836.GM22568@nb.net.home>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721230836.GM22568@nb.net.home>
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
Cc: fedora-devel-list@redhat.com, cg-manager-developers@lists.fedorahosted.org, dwalsh@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Fri, 22.07.11 01:08, Karel Zak (kzak@redhat.com) wrote:

> 
> On Thu, Jul 21, 2011 at 06:11:25PM +0200, Lennart Poettering wrote:
> > I'd expect people to just tell systemd about their preferred grouping
> > (if the default of sticking each service into a group of its own is not
> > good enough) using the ControlGroup= setting in unit files. This is
> > trivial to do, and will put things right from the beginning with no
> > complex moving around.
> 
>  It would be nice to have a shared library (or D-BUS interface) to
>  talk with systemd, then it would be possible to (on-the-fly)
>  create/modify services and execute processes by systemd from another
>  daemons (like crond).

You can actually do that, and there are a couple of hooks provided to
make this pretty:

a) Your app can just place a simple unit file in /run/systemd/system, and
   issue Reload() on the manager D-Bus object. Then, you can start it
   via D-Bus, and stop it, and introspect it, and all other
   operations. When you want to get rid of it again, stop it, then
   remove the file, issue another Reload().

b) Write a "generator". This are small binaries you can drop into
   /lib/systemd/system-generators. They are spawned in parallel every
   time systemd loads its configuration. These generators can
   dynamically generate unit files from other configuration, and place
   them in a special dir in /run/systemd. We currently use this to
   create the appropriate units for /etc/crypttab, or to generate a
   getty on the kernel console if the kernel was booted with a special
   one. Eventually we'll probably rip the currently built-in SysV compat
   code in systemd out and make a generator out of it. So that we just
   dynamically create a systemd unit file from each SysV script. These
   generators must be very simple, as they are started very early at
   boot. They may not do IPC and they may not access any files outside
   of the root dir. They are primarily useful to dynamically translate
   foreign configuration into systemd unit files.

c) In case you have a number of very similar dynamic services to run use
   a template.  i.e. as part of your package drop yourservice@.service  
   into /lib/systemd/system. Then, when you dynamically need an instance
   of this, just start "yourservice@someparam.service". In that unit
   file you can then access "someparam" with %i. If you need to change
   more than one parameter this won't be useful to you, however.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
