From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Thu, 6 Jun 2013 14:14:10 -0700
Message-ID: <20130606211410.GF5045@htj.dyndns.org>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130606092055.GF30217-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, Jun 06, 2013 at 10:20:55AM +0100, Daniel P. Berrange wrote:
> Unless I'm mistaken there is no alternative that can work. With QEMU
> we need to apply scheduling controls to 
> 
>   1. Individual vCPU threads
>   2. All non-vCPU threads (ie QEMU's I/O threads)
> 
> We can use per-thread APIs for 1, but for 2 we require something that
> applies to the group of threads as a whole, without also impacting the
> controls set for the vCPU threads. AFAIK, nothing except cgroups as
> we use them today can satisfy that requirement ? Am I wrong ? Is there
> something else that can achieve this same setup ?

Can you please explain more about your requirements on !vCPU threads?

> I understand that having wildly distinct hiearchies across different
> controllers causes alot of pain for the kernel. Libvirt doesn't
> actually require that full level of flexibility though. Our needs
> are very much simpler. We're happy with the same core hierarchy
> across all controllers. We just want to be able to create an extra
> leaf node in some controllers to move threads about. 
> 
> It would be fine with us if the kernel required that the same directory
> hierarchy exists in all controllers, and mandated that threads can only
> be moved to a directory immediately below where the process is initially
> placed.

The problem is that it doesn't make any sense to split threads of the
same process for at least two major controllers and you end up with
situation where you can't identify a resource to be belonging to a
certain cgroup because such level of granularity is simply undefined.
As I wrote before, we can special case certain controllers but I'm
extremely reluctant.  If you need it, please convince me.

> > It was never suited to that level of flexibility and it will never be
> > and things like that will be clearly forbidden rather than being left
> > in the current "not fully supported but kinda works" state.  The
> > existing stuff won't break but new things won't keep the support.  If
> > you're fine with staying with the old interface, which will be around
> > for the foreseeable future, that's fine too, but if you intend to move
> > onto the new interface when it finally becomes ready, whenever that
> > is, please move on.
> 
> You say the old interface will be around for the forseeable future, but
> if systemd starts applying a different setup to comply with your new
> scheme, then libvirt does get given any option to continue to use the
> old scheme. So even if you leave old interfaces around, we're going to
> be forced to change. That's not really a back-compatibility story that
> works for applications.

Even after unified hierarchy, it will be possible to tell systemd to
not to do that and the system should be able to continue using
multiple hierarchies as before.  Nothing really should change in that
respect.  It may not be the prettiest but is still a workable
compatibility.

Thanks.

-- 
tejun
