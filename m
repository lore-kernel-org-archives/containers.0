From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Wed, 20 Jul 2011 16:59:59 -0400
Message-ID: <20110720205959.GG10079@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110720202831.GA11395@tango.0pointer.de>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Lennart Poettering <mzerqung@0pointer.de>
Cc: fedora-devel-list@redhat.com, containers@lists.osdl.org, duffy@redhat.com, cg-manager-developers@lists.fedorahosted.org
List-Id: containers.vger.kernel.org

On Wed, Jul 20, 2011 at 10:28:32PM +0200, Lennart Poettering wrote:

[..]
> systemd is and will always have to maintain its own hierarchy
> independently of everybody else.

In the presentation today, you mentioned that you would like to create
cgroups for users by default in cpu hierarchy (once RT time allocation
issue is resolved). I am wondering what happens if an admin wants to
change the policy a bit. Say give higher cpu shares to a specific
user.

Generally one should have been able to do this with the help of GUI
tool. Show the system view and allow to change the parameters (which
are persistent across reboot).

How is one supposed to do that. As it looks like that part of the
control lies with systemd (as it is the one creates user group under
cpu) and part of the control lies with GUItool/cgconfig.

Thanks
Vivek
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
