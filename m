From: Matthias Clasen <mclasen@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Wed, 20 Jul 2011 19:01:30 -0400
Message-ID: <1311202891.5681.5.camel@planemask>
References: <20110720192029.GD2482@redhat.com>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
In-Reply-To: <20110720192029.GD2482@redhat.com>
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
Cc: fedora-devel-list@redhat.com, containers@lists.osdl.org, duffy@redhat.com, cg-manager-developers@lists.fedorahosted.org
List-Id: containers.vger.kernel.org

On Wed, 2011-07-20 at 15:20 -0400, Jason Baron wrote:
> Hi,
> 
> I've been working on a new gui tool for managing and monitoring cgroups, called
> 'cg-manager'. I'm hoping to get people interested in contributing to this
> project, as well as to add to the conversation about how cgroups should
> be configured and incorporated into distros.
> 

As a high-level comment, I don't think 'cgroup management' is a very
compelling rationale for an end-user graphical tool.

For most people it will be much better to expose cgroup information in
the normal process monitor. For people who want to use the specific
cgroup functionality of systemd, it will be better to have that
functionality available in a new service management frontend.

The only role I could see for this kind of dedicated cgroup UI would be
as a cgroup debugging aid, but is that really worth the effort,
considering most cgroup developers probably prefer to use cmdline tools
for the that purpose ?


Matthias


-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
