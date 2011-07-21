From: Jason Baron <jbaron@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 10:36:23 -0400
Message-ID: <20110721143622.GB2454@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<1311202891.5681.5.camel@planemask>
Reply-To: Development discussions related to Fedora
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
To: mclasen@redhat.co
Cc: fedora-devel-list@redhat.com, cg-manager-developers@lists.fedorahosted.org, lwang@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Hi,

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

I've thought that displaying at least the cgroup that a process is part of would
be nice in the system monitor as well.

I think its a question of do we want to make users go to a bunch of
different front end tools, which don't communicate with each other to
configure the system? I think it makes sense to have libvirt or
virt-manager and systemd front-end be able to configure cgroups, but I
think it would be also nice if they could know when the step on each
other. I think it would also be nice if there was a way to help better
understand how the various system components are making use of cgroups
and interacting. I liked to see an integrated desktop approach - not one
where separate components aren't communicating with each other. 


> 
> The only role I could see for this kind of dedicated cgroup UI would be
> as a cgroup debugging aid, but is that really worth the effort,
> considering most cgroup developers probably prefer to use cmdline tools
> for the that purpose ?
> 
> 

The reason I started looking at this was b/c there were requests to be
able to use a GUI to configure cgroups. Correct me if I'm wrong, but  the answer
is go to the virt-manager gui, then the systemd front end, and then hand edit
cgrules.conf for custom rules. And then hope you don't start services in
the wrong order.

thanks,

-Jason
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
