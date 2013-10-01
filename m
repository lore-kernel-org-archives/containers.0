From: "Michael H. Warfield" <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [lxc-devel] Device Namespaces
Date: Tue, 01 Oct 2013 18:59:48 -0400
Message-ID: <1380668388.8786.147.camel@mtking.wittsend.com>
References: <CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrYV2RiMV7PcwEjFGFRBrz9XdZGs86Wau2a+6xpYN2aEHA@mail.gmail.com>
	<CALCETrWWoHzuJcnfEUY+cFpOgT5gnG8U1cVbCW0_8V7Z_v6DJw@mail.gmail.com>
	<20131001175345.GA4145@mail.hallyn.com> <87had0wz07.fsf@xmission.com>
	<20131001204605.GA11894@tp>
Reply-To: "Michael H. Warfield" <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5793246283562211700=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131001204605.GA11894@tp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, "Michael H.Warfield" <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============5793246283562211700==
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-wr5rNnSX4ykv3ToY4jYH"


--=-wr5rNnSX4ykv3ToY4jYH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-10-01 at 15:46 -0500, Serge Hallyn wrote:=20
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> > "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> >=20
> > > Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> > >> On Tue, Oct 1, 2013 at 7:19 AM, Janne Karhunen <janne.karhunen@gmail=
.com> wrote:
> > >> > On Thu, Sep 26, 2013 at 8:33 AM, Greg Kroah-Hartman
> > >> > <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> > >> >
> > >> >>> - We can relay a call of /sbin/hotplug from outside of a contain=
er
> > >> >>>   to inside of a container based on policy.
> > >> >>>   (But no one uses /sbin/hotplug anymore).
> > >> >>
> > >> >> That's right, they should be listening to libudev events, so why =
can't
> > >> >> your daemon shuffle them off to the proper container, all in user=
space?
> > >> >
> > >> > Which reminds me, one potential reason being..
> > >> > http://lists.linuxfoundation.org/pipermail/containers/2013-May/032=
591.html
> > >> >
> > >>=20
> > >> Can't the daemon live outside the container and shuffle stuff in?
> > >
> > > That's exactly what Michael Warfield is suggesting, fwiw.
> >=20
> > Michael Warfields example of dynamically assigning serial ports to
> > containers is a pretty good test case.  Serial ports are extremely well
> > known kernel objects who evolution effectively stopped long ago.  When
> > we need it we have ptys to virtual serial ports when we need it, but in
> > general unprivileged users are safe to directly use a serial port
> > device.
> >=20
> > Glossing over the details.  The general problem is some policy exists
> > outside of the container that deciedes if an when a container gets a
> > serial port and stuffs it in.
> >=20
> > The expectation is that system containers will then run the udev
> > rules and send the libuevent event.=20=20

> I thought the suggestion was that udev on the host would be given
> container-specific rules, saying "plop this device into /dev/container1/"
> (with /dev/container1 being bind-mounted to $container1_rootfs/dev).

I think that the "given container-specific rules, saying..." thing was
on my chart of options as the one with the big cloudy shaped object in
the lower right corner labeled "and then a miracle occurs".

The basic part is the mapping from /dev into /dev/lxc/container.  That
should be doable based on the rules in the host and a basic udev trigger
along with a simple mapping configuration.  The "given
container-specific" part becomes a morass if it gets complicated enough.

What I was envisioning was a very simple system of container specific
{match} and {map} objects.  If a name or symlink passed to the daemon
from a udev trigger matched a match, then the name and symlinks and
additional maps would be mapped into the appropriate container
subdirectory.  That works real well if the container and host udev rules
are congruent.

The tough part is the "container-specific" rules which was the part I
specifically mentioned that I had no clue how to make happen.  That's a
non-trivial task if the container is allowed to make arbitrary udev rule
changes based on what they are allowed to receive from the host (and how
do we trigger the changes in the host when a change is made in the
container).

It's easily doable where the container rules are congruent with the host
rules.  Where they are orthogonal gets much more complicated.  But...
All that being said, I will take the congruent solution as a starting
point (and that will not be an 80% solution - it will be more like a 95%
solution) and we can argue about the corner cases and deltas after that.
Doable, yes, for some value of doable.

I like what Greg was saying about using libudev but I'm totally in the
dark as to how to effectively hook that or if it would even work in the
container.  That one is not in my realm.

> -serge

Regards,
Mike
--=20
Michael H. Warfield (AI4NB)  | Desk: (404) 236-2807
Senior Researcher - X-Force  | Cell: (678) 463-0932
IBM Security Services        | mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org mhw-UGBql2FAF+1Wk0Htik3J/w@public.gmane.org
6303 Barfield Road           | http://www.iss.net/
Atlanta, Georgia 30328       | http://www.wittsend.com/mhw/
                             | PGP Key: 0x674627FF

--=-wr5rNnSX4ykv3ToY4jYH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEVAwUAUktT5MDrlnVnRif/AQjVdQf/dWL1TkBGhvdKBrxdEDypLGiVv+ajRcQY
+aN8tLDQp6+Lzo9Lwra434d77sdfX6i2Kg7mMgvStnmH4/tIWJPY5Ge4cneXWsp8
YTbHkWE+3TpZjDroI30n7p8+CSUdcSx/VvIs7K4uGh6f5Z5ien3sFQ/A+OGNrpU+
02ZUkQVqSlaAi0KldK/OGKMPy9d6qmehckdPy86XH2SXq0087uZ/dGlhY6SvEfca
A3k3wrMG677rL6BBcm7M1aeV9OeC/Re7nEiUgydmMVL9zfOZX11SGTzbMDFJeW+l
QdxDupApeuPHIw3+x+kVOrsV5cRvgrQhmAFROaiDTXkEoNUrMZezxQ==
=oF7u
-----END PGP SIGNATURE-----

--=-wr5rNnSX4ykv3ToY4jYH--

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.

--===============5793246283562211700==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============5793246283562211700==--

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.
