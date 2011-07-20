From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Wed, 20 Jul 2011 16:42:40 -0400
Message-ID: <20110720204240.GF10079@redhat.com>
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
> 
> > Right now, the gui assumes that the various hierarchies are mounted separately,
> > but that the cpu and cpuacct are co-mounted. Its my understanding that this
> > is consistent with how systemd is doing things. So that's great.
> 
> In F15 we mount all controllers enabled in the kernel separately. In F16
> we'll optionally mount some of them together, and we'll probably ship a
> default of mounting cpu and cpuacct together if they are both enabled.

Last time we talked about possibility of co-mounting memory and IO at some
point of time and you said it is a bad idea from applications programming
point of view.  Has that changed now?

Thanks
Vivek
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
