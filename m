From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Thu, 22 Jul 2010 16:35:54 -0700
Message-ID: <20100722233554.GB442__36677.8078060181$1279841923$gmane$org@suse.de>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de> <20100722193741.GA2688@redhat.com>
	<20100722211856.GA1297@suse.de> <20100722212634.GC2688@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100722212634.GC2688-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 22, 2010 at 05:26:34PM -0400, Vivek Goyal wrote:
> On Thu, Jul 22, 2010 at 02:18:56PM -0700, Greg KH wrote:
> > On Thu, Jul 22, 2010 at 03:37:41PM -0400, Vivek Goyal wrote:
> > > On Thu, Jul 22, 2010 at 11:36:15AM -0700, Greg KH wrote:
> > > > On Thu, Jul 22, 2010 at 11:31:07AM -0700, Paul Menage wrote:
> > > > > On Thu, Jul 22, 2010 at 11:26 AM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> > > > > > We really shouldn't be asking userspace to create new root file=
systems.
> > > > > > So follow along with all of the other in-kernel filesystems, an=
d provide
> > > > > > a mount point in sysfs.
> > > > > >
> > > > > > For cgroupfs, this should be in /sys/fs/cgroup/ =A0This change =
provides
> > > > > > that mount point when the cgroup filesystem is registered in th=
e kernel.
> > > > > =

> > > > > But cgroups will typically have multiple mounts, with different
> > > > > resource controllers/options on each mount. That doesn't really f=
it in
> > > > > with this scheme.
> > > > =

> > > > Really?  I see systems mounting it at /cgroups/ in the filesystem t=
oday.
> > > > Where are you expecting it to be mounted at?
> > > > =

> > > =

> > > Greg,
> > > =

> > > [CCing few more folks who might be interested in this dicussion ]
> > > =

> > > We do want to retain facility to mount different controllers at diffe=
rent
> > > mount points. We were discussing the other day that in libvirt we mig=
ht
> > > want to mount block IO controller and network controller separately as
> > > by default we will not put a new virtual machine in a cgroup of its o=
wn
> > > because of the penatly involved.
> > =

> > That's fine, I'm not changing that ability at all.  We just need a
> > "default" mount point for "normal" users.
> > =

> > > For other controllers like cpu, memory etc, libvirt automatically puts
> > > each new virtual machine in a cgroup of own. So this is one use case
> > > where we might want to mount different controllers at different mount
> > > points.
> > > =

> > > For my testing I now always use /cgroup/ and create directories under=
 it
> > > /cgroup/blkio /cgroup/cpu etc and mount controllers on respective
> > > directories.
> > =

> > Lennart and Kay, is this what systemd is doing?  I really don't think we
> > should be adding a root /cgroup/ mount point to the system for something
> > like this.
> > =

> > Maybe /dev/cgroup/ is better to use, as that way users can create
> > sub-mount points easier.  They can't do that in /sys/fs/cgroup/
> =

> The only problem with /dev/cgroup seems to be that it seems little
> unintutive. To me, we have devices under /dev/ dir and cgroups are not
> devices.
> =

> I think people have floated similar threads in the past on lkml with
> various opinions and everybody had their own choices but nothing was
> conclusive. =

> =

> Polluting / definitely sounds odd but it does not look that bad once
> we can't find any other good choices.

I think /sys/fs/cgroup/ is a better choice than polluting /

thanks,

greg k-h
