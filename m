From: Karel Zak <kzak@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Fri, 22 Jul 2011 12:13:47 +0200
Message-ID: <20110722101347.GS22568@nb.net.home>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110721142053.GA2454@redhat.com>
	<20110721161124.GC19140@tango.0pointer.de>
	<20110721230836.GM22568@nb.net.home>
	<20110722003208.GB16928@tango.0pointer.de>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110722003208.GB16928@tango.0pointer.de>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Development discussions related to Fedora <devel@lists.fedoraproject.org>, Jason Baron <jbaron@redhat.com>, fedora-devel-list@redhat.com, containers@lists.osdl.org, cg-manager-develo
List-Id: containers.vger.kernel.org

On Fri, Jul 22, 2011 at 02:32:08AM +0200, Lennart Poettering wrote:
> a) Your app can just place a simple unit file in /run/systemd/system, and
>    issue Reload() on the manager D-Bus object. Then, you can start it
>    via D-Bus, and stop it, and introspect it, and all other
>    operations. When you want to get rid of it again, stop it, then
>    remove the file, issue another Reload().
> 
> b) Write a "generator". This are small binaries you can drop into
>    /lib/systemd/system-generators. They are spawned in parallel every
>    time systemd loads its configuration. These generators can
>    dynamically generate unit files from other configuration

 Nice, this is the right way to make it extendable. Thanks!

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
