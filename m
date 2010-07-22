From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Thu, 22 Jul 2010 14:48:21 -0700
Message-ID: <20100722214821.GB14303__2864.00916888869$1279835442$gmane$org@count0.beaverton.ibm.com>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de>
	<AANLkTimbcuzH6_bBhYX0U6vqftYgRwE0ZTmcbaRNzXef@mail.gmail.com>
	<20100722185301.GA528@suse.de>
	<AANLkTik07hZot_x0p7xJuY8s4f8pGRd2Mn1+jYfHH2iq@mail.gmail.com>
	<20100722191200.GA5609@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100722191200.GA5609-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 22, 2010 at 12:12:00PM -0700, Greg KH wrote:
> On Thu, Jul 22, 2010 at 12:07:43PM -0700, Paul Menage wrote:
> > On Thu, Jul 22, 2010 at 11:53 AM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> > >
> > > If you are using /dev/cgroup/ that's nice, but I don't think that people
> > > are expecting a whole filesystem under a /dev/ subdirectory.
> > 
> > Sure - as I said that's just for historical reasons from when we
> > migrated from cpusets which were traditionally mounted at /dev/cpuset,
> > so it involved less change. There's no particular reason to mount it
> > there (although having said that, what about /dev/pts and /dev/shm?).
> 
> Yeah, /dev/pts and /dev/shm are long-time users of the /dev filesystem.
> I don't know if we want to encourage that as a mount point, do you?

Makes sense. cgroups don't share any of the distinctive characteristics
that make pts filesystems such a natural fit in /dev: They're
not made to look like a dynamic set of character devices, there are
user-made subdirectories, there aren't any device nodes, and probably
more I'm forgetting.

In my opinion, the primary purpose of cgroups is allowing an admin/user
to organize tasks in ways they personally find useful -- so too much
"standardization" could easily be detrimental. A single standard mount
point is the first small step on that slippery slope.

If we really want to standardize then perhaps it should be based on the
names of the tools that make assumptions about how cgroups are organized.
Forgive me if my recollection is wrong, but I seem to recall systemd
imposed a certain scheme for organization of cgroups -- at least at the
top level of the subsystem(s). (That's not a bad thing. Distros/admins
that choose to use systemd are implicitly approving of systemd's
organizational scheme and any limitations it imposes). So I'd suggest
those cgroup mounts go in /var/run/systemd/cgroup or something like that.

Suppose we also have a daemon for managing applications with the freezer to
improve runtime power consumption. It might only care about the freezer
cgroup subsystem so it might choose to mount the freezer at:

/var/run/runtime_powerd/freezer

and then it would organize its cgroups according to its own schemes
(e.g. "trusted" vs "untrusted").

But if systemd and the runtime_powerd both want the freezer subsystem
then one would fail to mount it. That ensures that we don't have two
management daemons which make contradictory assumptions about cgroup
organization making a mess instead of keeping order.

Other tools that are agnostic about the organization of cgroups
shouldn't rely on a 'standard' mount point -- that way they can work
well with either of these example organizations (systemd or runtime_powerd).
They should work with an existing cgroup and its descendants -- usually
not destroying pre-existing cgroups that it did not create.

At least that's my perspective on how things can be done sanely while
giving users the flexibility to manage their own cgroups. It's also why
I think the lure of standardizing these mounts may be something to be
wary of.

Cheers,
	-Matt Helsley
