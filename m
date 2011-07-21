From: Karel Zak <kzak@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Fri, 22 Jul 2011 01:08:36 +0200
Message-ID: <20110721230836.GM22568@nb.net.home>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110721142053.GA2454@redhat.com>
	<20110721161124.GC19140@tango.0pointer.de>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721161124.GC19140@tango.0pointer.de>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Jason Baron <jbaron@redhat.com>, fedora-devel-list@redhat.com, containers@lists.osdl.org, cg-manager-developers@lists.fedorahosted.org, duffy@redhat.com, vgoyal@redhat.com, dwalsh@red
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 06:11:25PM +0200, Lennart Poettering wrote:
> I'd expect people to just tell systemd about their preferred grouping
> (if the default of sticking each service into a group of its own is not
> good enough) using the ControlGroup= setting in unit files. This is
> trivial to do, and will put things right from the beginning with no
> complex moving around.

 It would be nice to have a shared library (or D-BUS interface) to
 talk with systemd, then it would be possible to (on-the-fly)
 create/modify services and execute processes by systemd from another
 daemons (like crond).

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
