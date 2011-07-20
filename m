From: Lennart Poettering <mzerqung@0pointer.de>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Wed, 20 Jul 2011 23:11:36 +0200
Message-ID: <20110720211135.GB14218@tango.0pointer.de>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110720205959.GG10079@redhat.com>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110720205959.GG10079@redhat.com>
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
Cc: fedora-devel-list@redhat.com, containers@lists.osdl.org, duffy@redhat.com, cg-manager-developers@lists.fedorahosted.org
List-Id: containers.vger.kernel.org

On Wed, 20.07.11 16:59, Vivek Goyal (vgoyal@redhat.com) wrote:

> 
> On Wed, Jul 20, 2011 at 10:28:32PM +0200, Lennart Poettering wrote:
> 
> [..]
> > systemd is and will always have to maintain its own hierarchy
> > independently of everybody else.
> 
> In the presentation today, you mentioned that you would like to create
> cgroups for users by default in cpu hierarchy (once RT time allocation
> issue is resolved). I am wondering what happens if an admin wants to
> change the policy a bit. Say give higher cpu shares to a specific
> user.

He can just go and do that. systemd assume to be the exclusive owner of
/sys/fs/cgroup/systemd, but the other hierarchies can be manipulated by
others too. That means that if people want to create a hierarchy there,
then they can do that. If people want systemd to stop mucking with the
cpu hierarchy for all users then this can be configured in a simple
config file.

> How is one supposed to do that. As it looks like that part of the
> control lies with systemd (as it is the one creates user group under
> cpu) and part of the control lies with GUItool/cgconfig.

Right now, systemd has few controls to actually make use of
controllers. It assumes that the limits on hte controllers are already
configured by something else.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
