From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Mon, 26 Jul 2010 14:28:58 -0700
Message-ID: <20100726212858.GA15904__18408.821457024$1280179912$gmane$org@suse.de>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de>
	<AANLkTinsd2gWOHb3w9gzvKO5vdwLBT7DZOY+2xCUz_5_@mail.gmail.com>
	<AANLkTimm9XGvK2H55V7N76JPU05iHk_dY5JjOLifQTsr@mail.gmail.com>
	<AANLkTi=OMaKuk+ReeqCfBGes76BjKYyUdqxPOQfH8EcZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=OMaKuk+ReeqCfBGes76BjKYyUdqxPOQfH8EcZ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jul 26, 2010 at 11:13:14AM +0200, Dhaval Giani wrote:
> On Mon, Jul 26, 2010 at 11:12 AM, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org> wrot=
e:
> > On Mon, Jul 26, 2010 at 11:08, Dhaval Giani <dhaval.lists-4ks6kJTmIHHINaghk1cIrg@public.gmane.org>=
 wrote:
> >> On Thu, Jul 22, 2010 at 8:36 PM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> >>> On Thu, Jul 22, 2010 at 11:31:07AM -0700, Paul Menage wrote:
> >>>> On Thu, Jul 22, 2010 at 11:26 AM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> >>>> > We really shouldn't be asking userspace to create new root filesys=
tems.
> >>>> > So follow along with all of the other in-kernel filesystems, and p=
rovide
> >>>> > a mount point in sysfs.
> >>>> >
> >>>> > For cgroupfs, this should be in /sys/fs/cgroup/ =A0This change pro=
vides
> >>>> > that mount point when the cgroup filesystem is registered in the k=
ernel.
> >>>>
> >>>> But cgroups will typically have multiple mounts, with different
> >>>> resource controllers/options on each mount. That doesn't really fit =
in
> >>>> with this scheme.
> >>>
> >>> Really? =A0I see systems mounting it at /cgroups/ in the filesystem t=
oday.
> >>> Where are you expecting it to be mounted at?
> >>>
> >>
> >> Not really. It is getting mounted at /cgroups/<name of resource
> >> controller>/ at a number of places. Keeping it in sysfs loses us a lot
> >> of this flexibility. Unless you are ready to keep adding a new
> >> mountpoint for each subsystem, it will not really work out in the long
> >> term.
> >
> > As mentioned earlier in this thread, systemd already mounts a tmpfs at
> > the cgroup mountpoint. We need only a single directory. This should
> > not be an issue.
> >
> =

> Ah ok. I am catching up with email after over 3 weeks :-). Missed all
> this discussion. My apologies!

Ok, again, after all of this, who is going to be applying this patch to
their tree for the .36 merge window?

Or should I apply it to my driver-core one?

thanks,

greg k-h
