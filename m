From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Thu, 6 Jun 2013 10:20:55 +0100
Message-ID: <20130606092055.GF30217@redhat.com>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130604201947.GE14916-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 04, 2013 at 01:19:47PM -0700, Tejun Heo wrote:
> Hey, Daniel.
> 
> On Tue, Jun 04, 2013 at 12:15:56PM +0100, Daniel P. Berrange wrote:
> > With libvirt and KVM we require the ability to put different threads
> 
> I really don't think cgroup has ever been intended (if there were ever
> any such overall intending) or is suited for something as fine grained
> as in-process resource management.  There already are existing
> per-thread interfaces for that.  Please use them instead.  cgroup
> simply doesn't fit.

Unless I'm mistaken there is no alternative that can work. With QEMU
we need to apply scheduling controls to 

  1. Individual vCPU threads
  2. All non-vCPU threads (ie QEMU's I/O threads)

We can use per-thread APIs for 1, but for 2 we require something that
applies to the group of threads as a whole, without also impacting the
controls set for the vCPU threads. AFAIK, nothing except cgroups as
we use them today can satisfy that requirement ? Am I wrong ? Is there
something else that can achieve this same setup ?


> > in different cgroups for the "cpu", "cpuset" & "cpuacct" controllers.
> 
> cpu and cpuacct are in the process of being merged.  The scheduler
> people hate the duplicate accounting the separation causes and cpuacct
> is generally considered a mistake that we shouldn't repeat.  So, umm,
> you're really depending on a lot of things which are considered big
> mistakes in cgroup.

Merging cpu + cpuacct together is not a problem - they're already
co-mounted by systemd. What I'm saying is that for cpu, cpuset
and cpuacct we create

  /some/path/
    |
    +- domain-cgroup
        |
        +- vcpu0 - thread for cpu 0
        +- vcpu1 - thread for cpu 1
        +- emulator - all other non-vCPU threads

We can't leave the non-vcpu threads at the higher level, because
then limits applied at the 'domain-cgroup' level would impact on
the vcpu threads.

while for all other controllers (memory, blkio, etc) we create

  /some/path
    |
    +- domain-cgroup  -  all threads

The directory structure is the same in all controllers, except that
with the cpu, cpuset + cpuacct controllers, we create 2 further leaf
nodes.

I understand that having wildly distinct hiearchies across different
controllers causes alot of pain for the kernel. Libvirt doesn't
actually require that full level of flexibility though. Our needs
are very much simpler. We're happy with the same core hierarchy
across all controllers. We just want to be able to create an extra
leaf node in some controllers to move threads about. 

It would be fine with us if the kernel required that the same directory
hierarchy exists in all controllers, and mandated that threads can only
be moved to a directory immediately below where the process is initially
placed.

> > This is to allow us to control schedular tunables / placement for
> > QEMU vCPU threads, independantly of limits for QEMU I/O threads. So
> > requiring all threads of a process to be in the same cgroup isn't
> > sufficiently flexible for our needs.
> 
> It was never suited to that level of flexibility and it will never be
> and things like that will be clearly forbidden rather than being left
> in the current "not fully supported but kinda works" state.  The
> existing stuff won't break but new things won't keep the support.  If
> you're fine with staying with the old interface, which will be around
> for the foreseeable future, that's fine too, but if you intend to move
> onto the new interface when it finally becomes ready, whenever that
> is, please move on.

You say the old interface will be around for the forseeable future, but
if systemd starts applying a different setup to comply with your new
scheme, then libvirt does get given any option to continue to use the
old scheme. So even if you leave old interfaces around, we're going to
be forced to change. That's not really a back-compatibility story that
works for applications.

Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
