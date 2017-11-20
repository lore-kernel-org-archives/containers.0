From: Christian Brauner <christian.brauner-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] ioctl_tty.2: add TIOCGPTPEER documentation
Date: Mon, 20 Nov 2017 13:15:57 +0100
Message-ID: <20171120121556.ck2jrr5nk6sqqene__24706.5547890545$1511180176$gmane$org@mailbox.org>
References: <20170609170147.32311-1-asarai@suse.de>
	<11706e49-8271-ed8c-3747-19b3e8f2850d@gmail.com>
	<878tijwjic.fsf@xmission.com>
	<a7175aad-645c-8f86-d7cf-51f24f0bc281@suse.de>
	<87ziaztoxu.fsf@xmission.com>
	<c702b5c6-0098-4a61-f51c-c28ed085534f@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2653571805929790512=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c702b5c6-0098-4a61-f51c-c28ed085534f-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============2653571805929790512==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="htugecgnqe2zoyg2"
Content-Disposition: inline


--htugecgnqe2zoyg2
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 20, 2017 at 11:20:13AM +0100, Michael Kerrisk (man-pages) wrote:
> On 08/16/2017 07:14 PM, Eric W. Biederman wrote:
> > Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:
> >=20
> >>> A couple of things to note on the bigger picture.
> >>>
> >>> The glibc library on all distributions has been changed to not have a
> >>> setuid binary pt_chown, that uses ptsname.  This was the primary fix
> >>> for the security issue.
> >>>
> >>> The behavior of opening /dev/ptmx has been changed to perform a path
> >>> lookup relative to the location of /dev/ptmx of  ./pts/ptmx and open
> >>> it it is a devpts filesystem and to fail otherwise.    This further
> >>> makes it hard to confuse userspace this way as /dev/ptmx always
> >>> corresponds to /dev/pts/ptmx.  Even in chroots and in other mount
> >>> namespaces.
> >>
> >> I have a feeling that there might be a way to trick glibc if you use
> >> FUSE, but I haven't actually tried to create a PoC for it. Fair point
> >> though.
> >=20
> > To trick glibc fuse would have to be mounted somewhere on /dev.
> >=20
> >>> That makes TIOCGPTPEER a very nice addition, but not something people
> >>> have to scramble to use to ensure their system is secure.  As a hosti=
le
> >>> environment now has to work very hard to confuse the existing mechani=
sms.
> >>
> >> There are usecases where you simply need TIOCGPTPEER, and no other
> >> userspace alternative will do, but maybe if we modified the paragraph
> >> to read (as suggested):
> >>
> >>   Security-conscious programs interacting with namespaces may
> >>   wish  to  use  this  operation rather than open(2) with the
> >>   pathname returned by ptsname(3).
> >>
> >> This would clarify that there are usecases where you need this
> >> particular feature, without saying causing people to panic over
> >> inaccurate claims of glibc being broken. Does that sound better?
> >=20
> > I think your original words sounded fine.  I would even go for new
> > programs may want to use the new ioctl as it fundamentally less racy
> > and more of what is actually trying to be implemented with the userspace
> > pieces.
> >=20
> > I just wanted to point out that TIOCGPTPEER while being the interface
> > that it would have been nice had we had since the beginning (and would
> > have avoided all of the problems) is actually not something we need to
> > scramble and use it is just a very nice to have.  As the immediate
> > issues have been fixed in other ways.    It was not clear to me from the
> > other discussions if you and Michael Kerrisk were aware of the
> > mitigations that had been made to address the security issue.
>=20
> So, my takeaway is that we leave this text:
>=20
>               Security-conscious programs interacting with namespaces may
>               wish  to  use  this  operation rather than open(2) with the
>               pathname returned by ptsname(3), and similar library  func=
=E2=80=90
>               tions that have insecure APIs.  (For example, confusion can
>               occur in some cases using ptsname(3) with a pathname  where
>               a  devpts  filesystem has been mounted in a different mount
>               namespace.)

This sounds fine to me. I probably should point out that I wrote a patch for
glibc to use TIOCGPTPEER based slave fd allocation when supported and only =
use
the insecure way as a fallback. I've pushed this to glibc master on 8 Octob=
er.
That means it is still in our current glibc development cycle and will thus=
 be
available in glibc 2.27. The relevant commit hash is
645ac9aaf89e3311949828546df6334322f48933 and the link to the diff
https://sourceware.org/git/?p=3Dglibc.git;a=3Dcommitdiff;h=3D645ac9aaf89e33=
11949828546df6334322f48933;hp=3D98e0742024d4c13c08a6076b3d119c250e7d0118

At least for us at glibc this should mean that *most* insecure
path-based-operations have been eliminated since other path-based bits in t=
hese
codepaths are basically no-ops by now. That being said glibc needs to be
backward compatible and so will (see comment above) execute path-based fall=
back
code if the new ioctl() fails. So if you really^2 care about using TIOCGPTP=
EER
you should do the ioctl() dance yourself.

(Fwiw, I'm not directly involved with Musl I've written a patch for them as=
 well
but Rich had some reservations and I haven't been able to pick that patch b=
ack
up yet.)

Christian

>=20
> as is?
>=20
> > The change to the behavior of /dev/ptmx may need to be documented
> > somewhere.   I am not certain if anything has been documented since
> > devpts has started allowing multiple mounts.
>=20
> Eric can you say more about this. When did this change occur?
> What is the model: mount devpts once in each mount namespace?
>=20
> Cheers,
>=20
> Michael
>=20
>=20
> --=20
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

--htugecgnqe2zoyg2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJaEsd5AAoJEHs8OR7+qTYkvFcQAOIhNyEd5/CIiG0xYRk1AUTr
mv18W62NeN6vUeECVs/B7oSB5guBDr4XIbwkPcsOHsPAcaYdLKgj6RpND8kvUrps
MJVYf42rm5ZEzb1XNq6JBNZiet+kpWq0KWC7fkJZVJ7e6XzaIJMEXpB/cwGndntA
U77hGaVyti0DMxmQHg9e3rTwYx9+8w9XRFD6XWNedz71HRIb+gmMcwaynTDxKwPs
ZKWzr9A7PI+g6Byr0S/oNqgHsbLdUqtmTW4X4TmB808bA+ZKJS0f+suQwQM3HIFM
36hGvuUDVnWV6Tovj8uMuOz7Q4WMl0t/CF/3lbnL2ogyMKi/tKI5TCbuljNYDn3y
l6M2OX4CJRkV0bc6c9/G/JBsRAc80HqRCzau1/fYnHCvKSZixt3SoRZseeC4Mb6g
QXO39bS9rNz+m9SVn9OlCh7nFoXXYl1jFayi10Im6aAiGDlq8XzFWfmqHRaXSCyh
RSP3wrKznriAEwyv72OIZXV9dXc6NEDu0v15L06KlQMZk1lIBGiIjID1auGwjIon
I+3+IRLGQHQ8q2B1O2nNK4EFDvmQsAT5+cYLmY8NO1xUvNUcLofgh3dF3M7mPxsK
NU2DCvpsmmMOKEQad1DNqynnBpoyPrJo8yBEH8s9u58rrQwqgc+owmfzElHLH7Sj
ZTkHSFkt9sI0I2s2u/hS
=wMU6
-----END PGP SIGNATURE-----

--htugecgnqe2zoyg2--

--===============2653571805929790512==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2653571805929790512==--
