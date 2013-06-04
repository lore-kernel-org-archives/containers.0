From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Tue, 4 Jun 2013 13:19:47 -0700
Message-ID: <20130604201947.GE14916__40501.6530109153$1370377201$gmane$org@htj.dyndns.org>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130604111556.GA4963-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hey, Daniel.

On Tue, Jun 04, 2013 at 12:15:56PM +0100, Daniel P. Berrange wrote:
> With libvirt and KVM we require the ability to put different threads

I really don't think cgroup has ever been intended (if there were ever
any such overall intending) or is suited for something as fine grained
as in-process resource management.  There already are existing
per-thread interfaces for that.  Please use them instead.  cgroup
simply doesn't fit.

> in different cgroups for the "cpu", "cpuset" & "cpuacct" controllers.

cpu and cpuacct are in the process of being merged.  The scheduler
people hate the duplicate accounting the separation causes and cpuacct
is generally considered a mistake that we shouldn't repeat.  So, umm,
you're really depending on a lot of things which are considered big
mistakes in cgroup.

> This is to allow us to control schedular tunables / placement for
> QEMU vCPU threads, independantly of limits for QEMU I/O threads. So
> requiring all threads of a process to be in the same cgroup isn't
> sufficiently flexible for our needs.

It was never suited to that level of flexibility and it will never be
and things like that will be clearly forbidden rather than being left
in the current "not fully supported but kinda works" state.  The
existing stuff won't break but new things won't keep the support.  If
you're fine with staying with the old interface, which will be around
for the foreseeable future, that's fine too, but if you intend to move
onto the new interface when it finally becomes ready, whenever that
is, please move on.

Thanks.

-- 
tejun
