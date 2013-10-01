From: "Michael H. Warfield" <mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org>
Subject: Re: Device Namespaces
Date: Tue, 01 Oct 2013 18:19:23 -0400
Message-ID: <1380665963.8786.132.camel@mtking.wittsend.com>
References: <CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
	<CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrYV2RiMV7PcwEjFGFRBrz9XdZGs86Wau2a+6xpYN2aEHA@mail.gmail.com>
	<CALCETrWWoHzuJcnfEUY+cFpOgT5gnG8U1cVbCW0_8V7Z_v6DJw@mail.gmail.com>
	<20131001175345.GA4145@mail.hallyn.com> <87had0wz07.fsf@xmission.com>
Reply-To: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8524815676765205127=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87had0wz07.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============8524815676765205127==
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-CMW2lAPPG4loORn7ME1R"


--=-CMW2lAPPG4loORn7ME1R
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-10-01 at 12:51 -0700, Eric W. Biederman wrote:=20
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>=20
> > Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> >> On Tue, Oct 1, 2013 at 7:19 AM, Janne Karhunen <janne.karhunen@gmail.c=
om> wrote:
> >> > On Thu, Sep 26, 2013 at 8:33 AM, Greg Kroah-Hartman
> >> > <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> >> >
> >> >>> - We can relay a call of /sbin/hotplug from outside of a container
> >> >>>   to inside of a container based on policy.
> >> >>>   (But no one uses /sbin/hotplug anymore).
> >> >>
> >> >> That's right, they should be listening to libudev events, so why ca=
n't
> >> >> your daemon shuffle them off to the proper container, all in usersp=
ace?
> >> >
> >> > Which reminds me, one potential reason being..
> >> > http://lists.linuxfoundation.org/pipermail/containers/2013-May/03259=
1.html
> >> >
> >>=20
> >> Can't the daemon live outside the container and shuffle stuff in?
> >
> > That's exactly what Michael Warfield is suggesting, fwiw.

> Michael Warfields example of dynamically assigning serial ports to
> containers is a pretty good test case.  Serial ports are extremely well
> known kernel objects who evolution effectively stopped long ago.  When
> we need it we have ptys to virtual serial ports when we need it, but in
> general unprivileged users are safe to directly use a serial port
> device.

> Glossing over the details.  The general problem is some policy exists
> outside of the container that deciedes if an when a container gets a
> serial port and stuffs it in.

Actually, I don't necessarily see that as a problem as much as a
necessity.  If a container can decide when it gets a serial port or
other device, I would think that would constitute a security issue and
container isolation violation.  Restricting what container can have
access to what has to be determined in the host and, once you've drunk
that koolaid, you might as well stuff it in somewhere.  Policy has to be
in the host or you will never get the security corner cases right.

Ultimately, it is the host which is in charge of the hardware and is
managing the containers (it can start them up, shut them down, or manage
them) so, at its base level, is is the responsibility of the host to
manage those devices between the containers.

That being said, there is the additional issue of, what does the
container do when we hand it a device and how do we let it know.  That's
now classically the issue of udev and formerly hotplug and their
predecessors...

> The expectation is that system containers will then run the udev
> rules and send the libuevent event. =20

Which makes sense.  Something along the line of a socket into the
container to send selected events from the user space daemon in the host
would make some sense there.

> To make that all work without kernel modifications requires placing
> a faux-udev in the container, that listens for a device assignment from
> outside the container and then does exactly what udev would have done.

> The problems with this that I see are:

> - udev is a moving target making it hard to build a faux-udev that will
>   work everywhere.

Well, it is an it isn't.  Yeah the rules have been changing (I'm getting
tired of the "deprecated" rule warnings) but I've seen worse, much
worse.

> - On distro's running systemd and udev integration is sufficiently tight
>   that I am not certain a faux-udev is possible or will continue to be
>   possible.

Actually, I think that's a non-issue.  IIRC, systemd (now) discontinues
its udev operation when it detects it's in a container.  That was at the
heart of the entire Fedora 15/16 in a container meltdown with the broken
versions of systemd trying to run udev in the container.  What do we do
in place of it?  I don't know.

> - There are two other widely deployed solutions for managing hotplug
>   devices besides udev.

> So given these difficulties I do not believe that the evolution of linux
> device management is done, and that patches to udev, the kernel or both
> will be needed.  While it would be good for testing and understanding
> the problem I don't think a faux-udev will be a long term maintainable
> solution.

> I also understand the point that we aren't talking patches yet and just
> discussing ideas.  Right now it is my hope that if we talk this out we
> can figure out a general direction that has a hope of working.

> From where I am standing faking uevents instead of replacing
> udev/mdev/whatever looks simpler and more maintainable.

> Eric

Mike
--=20
Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
   /\/\|=3Dmhw=3D|\/\/          | (678) 463-0932 |  http://www.wittsend.com=
/mhw/
   NIC whois: MHW9          | An optimist believes we live in the best of a=
ll
 PGP Key: 0x674627FF        | possible worlds.  A pessimist is sure of it!

--=-CMW2lAPPG4loORn7ME1R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEVAwUAUktKbMDrlnVnRif/AQgy4AgAzQxcQkI21zouH2EzqvdnTzhzcTAMRp6b
uJ/wUPr7v9VlGF1eYz/gCWjIlzM53BCtycLAuJ2VYYt1K72LoTL4nea/X+ZDmhuX
HvGygGIa9nHuK1JkWgDTXMNhZQObMfSaWggHYMp+7zg0NvS56OBn0+ITmFFHxT7Q
WKU/91v2FCs4tKFcDVHu/MJl+2vA3kYZT35nsM71dT/1HOntPmXxltRyubJgwIEV
qQ46vXak9Vh6Jj7ESr7pkEEvcty9yeEbsfSvzi7KfEhxKbKU2SsnydBCyqf6Mmfr
3vdNhxcnpzGhjwH+5st7aFVZxkqk3Y1VgCOqxrG8mYbXqdH2FD4tHg==
=Cqr4
-----END PGP SIGNATURE-----

--=-CMW2lAPPG4loORn7ME1R--


--===============8524815676765205127==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8524815676765205127==--
