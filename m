From: "Michael H. Warfield" <mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org>
Subject: Re: Device Namespaces
Date: Mon, 30 Sep 2013 11:36:50 -0400
Message-ID: <1380555410.8786.85.camel__26031.1331753202$1380555977$gmane$org@mtking.wittsend.com>
References: <CAA2m6veny-7_ONMA973Wu36U4kz4gAuw0dpodkb8+GZDv6VNBQ@mail.gmail.com>
	<20130929200620.GA31304@kroah.com>
Reply-To: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4824000414389273633=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130929200620.GA31304-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


--===============4824000414389273633==
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-He13Dn6xVJ6ClqOIyib9"


--=-He13Dn6xVJ6ClqOIyib9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-09-29 at 13:06 -0700, Greg Kroah-Hartman wrote:=20
> On Sun, Sep 29, 2013 at 10:28:55PM +0300, Amir Goldstein wrote:
> >=20
> >=20
> >=20
> > On Thu, Sep 26, 2013 at 8:33 AM, Greg Kroah-Hartman <gregkh@linuxfounda=
tion.org
> > > wrote:
> >=20
> >     On Wed, Sep 25, 2013 at 02:34:54PM -0700, Eric W. Biederman wrote:
> >     > So the big issues for a device namespace to solve are filtering w=
hich
> >     > devices a container has access to and being able to dynamically c=
hange
> >     > which devices those are at run time (aka hotplug).
> >=20
> >     As _all_ devices are hotpluggable now (look, there's no CONFIG_HOTP=
LUG
> >     anymore, because it was redundant), I think you need to really thin=
k
> >     this through better (pci, memory, cpus, etc.) before you do anythin=
g in
> >     the kernel.
> >=20
> >     > After having thought about this for a bit I don't know if a pure
> >     > userspace solution is sufficient or actually a good idea.
> >     >
> >     > - We can manually manage a tmpfs with device nodes in userspace.
> >     >   (But that is deprecated functionality in the mainstream kernel)=
.
> >=20
> >     Yes, but I'm not going to namespace devtmpfs, as that is going to b=
e an
> >     impossible task, right?
> >=20
> >=20
> > That sounds like a challenge ;-)
> > Seriously, as Serge correctly noted, it would not be that different fro=
m devpts
> > if you start from an empty devtmpfs and populate it with devices that a=
re
> > "added in the context of that namespace".  The semantics in which
> > devices are "added in the context of a namespace" is the missing piece
> > of the puzzle.

> And the fact that these devices are almost all created before userspace
> starts up, is a non-trivial "piece of the puzzle" :)

That's putting it mildly.  As I said in the Containers session at Linux
Plumbers, I agree with you (wrt device namespaces), but we do have (a)
problem(s) to solve.  The more I've thought on this, the more I agree
with you and that there's got to be a better way.

I'm not going to address the Android use case issues here which Janne
raised (which are very valid), since I've got other fish to fry and I
haven't even begun to look at the complexities of Android in an LXC
container on a non-android host, much less Android on Android or other
on Android.  This may have some applicability to the Android case, I
just haven't thought it through yet.  Anything on a common kernel should
work and standard distributions seem to be no problem now, but Android
is a rather unique beast, to say the least.

I will disagree with you on one point, though, from that session.  When
I mentioned both persistent and dynamic devices, you said they were
mutually exclusive.  It may be a difference in semantics or terminology
but I would beg to differ there, so I'll explain that too...

In my "worst case, real world, right now" scenario of the USB sharing
device and multiple USB serial adapters for serial consoles, I have
several different issues that are illustrative of several problems I'm
trying to overcome.

With this sharing device, you get a "/dev/usbshare" HID device on all
the connected hosts which do NOT have the USB bus that's being shared.
The device that has control of the bus does NOT see the /dev/usbshare
device but does see all the USB devices (the serial port adapters
- /dev/ttyUSB* - in this case) which are connected to it.

So, when you switch the sharing from system A to system B, all the
shared serial devices disappear from A and the /dev/usbshare device
appears, while the usbshare device disappears from system B and all the
usb serial devices appear together.  Either system may (and do) have
other static usb serial devices attached so the numbering and order
of /dev/ttyUSB* may vary and can even change depending if a host had
been booted with the usb bus shared to it or not.

Ok...  That's the "dynamic" devices I was referring to.  They come and
go and may have differing names under differing circumstances.  Very
real world dynamic.

Now...  For consistency, I have udev rules that map those serial devices
to other names, based on their device USB serial numbers.  That naming
convention remains persistent on that system as the devices come and go
and remains consistent between the systems with those rules.

So that's my "dynamic" with "persistent" devices.  I have persistent
names on dynamic devices.  Perhaps I could have chosen my terminology
better but, that's what I was arguing for in that Plumbers session when
I used those terms.

Now, for the complications...  If I wish to (and I most certainly do)
divvy up these serial devices between containers, I have several things
which need to be managed.

The /dev/usbshare device needs to be mapped to ALL containers which may
wish to request the shared bus (plus the host).  It's generally only a
very momentary device access and collisions would be extremely rare and
non-harmful in any case (two containers both wanting the bus on the same
host - shrug...).  It's actually far less confusing and difficult than
merely the collisions and contention between systems, and that's been
easily managable, given the rarity of cross serial console access (the
real world use case).

The /dev/ttyUSB* devices need to be mapped to their specific containers
with or without removing them from the host and possibly allowing for
multiple containers.  Device access is easily managed by the device
driver for multiple access (EBUSY) and not a problem.  This could be
more complicated if, for example, we were talking about USB drives, loop
devices, or other devices which multiple access, but that's another
layer of complication.

The "persistent" udev symlinks also need to be mapped to the containers.
I think I can do this equally well in the host as the real devices...

> Good luck,

I'm scratching on an idea that started forming just after that session.
I told Serge that "I think I can do it and it will (should) suck less."
Basically, it exploits some of the properties of devtmpfs to accomplish
some of our goals.

You're right about the user space problem.  Something needs to manage
the devices in a coherent manner as devices come and go and as
containers come and go in asynchronous manner.  In my mind, the only
place for that is in the host.  "Non trivial" is a jaw dropping
understatement and I can see where you feel it would be impossible to
manage in applying namespaces to devtmpfs.  That leaves the user space
in the host.  I can see where it would be intractable in the kernel.

I may get beat mercilessly for suggesting this but, just as with
cgroups, if we create a subdirectory in devtmpfs for subsystem (LXC) and
container, we can then bind mount that subtree off of devtmpfs to the
container and then the host can map and manipulate the device subtree
into the container (even if the container is denied mknod capability).
That leaves the host to manage all the devices, which actually makes a
LOT of sense (to me) since it should be responsible for the devices and
the overall kernel operations.  That would be no different than needing
to configure device passthroughs for KVM / VirtualBox / VMware
hypervisors.

Example...  In the host I would have something like this...

/dev/lxc/
romulus
remus
gemini
janus

And then bind mount each of those subdirectories
to /var/lib/lxc/${Container}/rootfs/dev directory.  Then map the devices
from the host /dev to the container /dev with mknod in the host and
relative symlinks.

That also (I think) helps me deal with some of the (mis)behavior of
systemd where it contains unconfigurable behavior (mounting devtmpfs)
controlled by "magic cookies" (/dev mounted on another major/minor
from / to disable it mounting devtmpfs).  I initially recoiled in horror
of the thought of overloading the devtmpfs subtree with container based
subdirectories, devices, and symlinks but the idea grew on me that this
might be better than what we're dealing with now of mounting tmpfs on
the /dev mount point in all theses containers and then having to
populate them just to prevent systemd from creating collisions with
devtmpfs and the resulting violation of the container isolation.

It DOES still leave the problem of dealing with udev rules in the
container and subsidiary device syslinks in the container which may not
correspond to the rules in the host.  That's still problem in my mind
(but already present and miniscule to what we would be solving).  I
could pattern match everything coming out of udev in a trigger and map
devices and symlinks into the new subtree in the host but I have no way
to manage propagating the rules in the container down into the processor
in the host or a way to trigger those udev rules in the containers.
Suggestions there might be nice (as well as the cat calls).  I'm not
sure I have it clear in my head yet how I would deal with bringing up a
container and then mapping all the required existing devices over to it.
That's your user space problem in a nutshell.  That's easy to handle
with udev as things come and go but, when the user space comes after and
udev isn't processing triggers, how do I handle the mappings.  That's
also non-trivial in my mind.

Device creation would seem to be pretty trivial.  Device removal, not so
much.  If I create another node on devtmpfs and that major/minor gets
removed, will it also get removed?  I also have to remove the symlinks.
The removal process just feels more complicated in my mind.

Greg, I think you are absolutely right, this needs to be managed in user
space and not in kernel space and we do have the tools to do it.  I
think I can do some of it in a way that will suck less compared to how
we're (LXC is) doing it now.  I'm just not so sure how comprehensive the
solution will be or how well it will work.

I've still got several other takeaways from that session to put a bow on
before really testing this idea further.  I really have not fully
fleshed this idea out and it's going to take me some time.  There may
also me some other corner cases I haven't considered.  And then there's
Android.  Sigh...

And maybe I'm just totally off base and crazy.  Wouldn't be the first
time, won't be the last time.

> greg k-h

Regards,
Mike
--=20
Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
   /\/\|=3Dmhw=3D|\/\/          | (678) 463-0932 |  http://www.wittsend.com=
/mhw/
   NIC whois: MHW9          | An optimist believes we live in the best of a=
ll
 PGP Key: 0x674627FF        | possible worlds.  A pessimist is sure of it!

--=-He13Dn6xVJ6ClqOIyib9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEVAwUAUkmak8DrlnVnRif/AQhrtQf9HSRy2WAl1Vx80H90P0h8Hl4y5K+2WZnM
I6TSzljsp8x2yGpkAn5ZebubK9mgiJjUhpXCY/5igMA+NT+hfunk91W6Do1uuDBx
F7bDXuD8+KH9uM9JRvtwuTJt6ELsIl1DY96pKyMm5E8GJv7+eFEniPL1w2lRbLoM
JNv/TuAaCycyBruGtX4qp/iq8cx63M8nmytWt9uU4nx2nxRRV3AvxIVMg264WIdO
qiY+m4QXtZeCLr1Tp58UnJRWv+cIwiuvdcpfij6+r6PnjQrh2dcG38C9utZCWPSw
eCJTAtaYtWkp2vwTG0In95y+nqzg1FtT5ESNqQCBye95gCiDC+49yg==
=Ndp7
-----END PGP SIGNATURE-----

--=-He13Dn6xVJ6ClqOIyib9--


--===============4824000414389273633==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============4824000414389273633==--
