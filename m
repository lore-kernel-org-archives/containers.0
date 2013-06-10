From: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file
	as  insane
Date: Mon, 10 Jun 2013 13:08:25 +0200
Message-ID: <20130610110825.GB10627__46865.7376165085$1370862519$gmane$org@tango.0pointer.de>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
	<20130606211410.GF5045@htj.dyndns.org>
	<20130607051040.GA1364@tango.0pointer.de>
	<20130607200307.GA14781@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130607200307.GA14781-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 07.06.13 13:03, Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:

Heya,

> On Fri, Jun 07, 2013 at 07:10:40AM +0200, Lennart Poettering wrote:
> > Uhm. So I don't think we will support two ways to set this up for long
> > in systemd (if at all). And even if we did, the distributions would pick
> > one or the other as default, and if you are unlucky, then you couldn't
> > run libvirt on it without reconfiguration and rebooting to get the other
> > cgroup setup logic...
> 
> Hmmm... would that mean that people wouldn't be able to boot older
> kernel w/o unified hierarhcy with new systemd fairly soon too? 

Yeah, I guess. Or maybe only to the level we currently support
cgroup-less kernels: i.e. we print a big warning at boot, wait for a few
seconds, and then proceed but things might be very confused because we
cannot keep track of services anymore..

> We can make the new features which matter for management available for
> named mounts (w/o unified hierarchy) so that systemd can operate as if
> none of the actual controllers are enabled, which it should be able to
> handle anyway.  That wouldn't solve booting old kernels with new
> systemd problem but it should at least allow workable backward
> compatibility from userland side as long as the kernel keeps the
> compatibility, right?

The closer the kernel stays to its old interfaces the easier it would be
for us to stay compatibile for a while. But there are many levels of
compatbility possible here: as mentioned above, the one where we warn
and just don't make use of cgroups, or where we just use cgroups for
organizing things, but drop support for resource management and so on.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
