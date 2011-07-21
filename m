From: Lennart Poettering <mzerqung@0pointer.de>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 18:11:25 +0200
Message-ID: <20110721161124.GC19140@tango.0pointer.de>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110721142053.GA2454@redhat.com>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110721142053.GA2454@redhat.com>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Jason Baron <jbaron@redhat.com>
Cc: fedora-devel-list@redhat.com, cg-manager-developers@lists.fedorahosted.org, dwalsh@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, 21.07.11 10:20, Jason Baron (jbaron@redhat.com) wrote:

> > Quite frankly, I think cgrulesd is a really bad idea, since it applies
> > control group limits after a process is already running. This is
> > necessarily racy (and adds quite a burden too, since you ask for
> > notifications on each exec()). I'd claim that cgrulesd is broken by
> > design and cannot be fixed.
> 
> I'm not going to claim that cgrulesd is perfect, but in the case where
> you have untrusted users, you can start their login session in a
> cgroup, and they can't break out of it. I agree it can be racy in the
> case where you want to then further limit that user at run-time (fork
> vs. re-assignment race). Another point, is that the current situation
> can be no worse then the current unconstrained (no cgroup) case,
> especially when you take into account the fact that system services or
> 'trusted services' are going to be properly assigned. Perhaps, the
> authors of cgrulesd can further comment on this issue... 

placing users in cgroups is note done by cgrulesd afaik. The PAM module
does that. (and systemd can do that for you, too).

> > systemd is and will always have to maintain its own hierarchy
> > independently of everybody else.
> 
> My suggestion here was that systemd starts its own hierarchy in some
> default way, and then once configuration info is available it can move
> processes around as required (in most cases there would probably be no
> movement since we don't expect most users to override the defaults). 
> Doesn't it have to do this now, if the user requests some sort of
> customized cgroup configuration?

I'd expect people to just tell systemd about their preferred grouping
(if the default of sticking each service into a group of its own is not
good enough) using the ControlGroup= setting in unit files. This is
trivial to do, and will put things right from the beginning with no
complex moving around.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
