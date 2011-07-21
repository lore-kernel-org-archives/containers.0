From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 11:08:04 -0400
Message-ID: <20110721150804.GC12373@redhat.com>
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

On Thu, Jul 21, 2011 at 10:20:54AM -0400, Jason Baron wrote:

[..]
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

Agreed that cgrulesd reacts after the event and can be racy. It is a
best effort kind of situation. A more fool proof way is to launch the
task in right cgroup to begin with and that can be done with various
other mechianisms available.

	- pam plugin to put users in right cgroup upon login
	- cgexec command line tool to launch tasks in right cgroup
	- Applications make use of libcgroup API to launch/fork tasks in
	  desired cgroup. 

If none of the above is being used, then cgrulesengd works in the
background as best effort to enforce the rules and can easily be turned
off, if need be.

Thanks
Vivek
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
