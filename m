From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Thu, 6 Aug 2009 16:54:43 +0200
Message-ID: <20090806145443.GH26446__34062.1988209479$1249570591$gmane$org@hawkmoon.kerlabs.com>
References: <2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
	<6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
	<2f86c2480908051701s57120404q475edbedb58cdca1@mail.gmail.com>
	<20090806095854.GD26446@hawkmoon.kerlabs.com>
	<6599ad830908060328y21a008c1pc5ed5c27e0ec905d@mail.gmail.com>
	<20090806112450.GF26446@hawkmoon.kerlabs.com>
	<6599ad830908060440g2f6cbed6xdc54c7096cd3745e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7977205344428546636=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908060440g2f6cbed6xdc54c7096cd3745e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============7977205344428546636==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-669-1249570450-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-669-1249570450-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 06/08/09  4:40 -0700, Paul Menage wrote:
> On Thu, Aug 6, 2009 at 4:24 AM, Louis Rilling<Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org> =
wrote:
> >
> > You meant signal_struct, right? sighand_struct can be shared by several
> > thread groups, while signal_struct can't.
> >
>=20
> No, I meant sighand_struct. I realise that it *can* be shared between
> processes, but I didn't think that NPTL actually did so. (Are there
> common cases of this happening?)

Not that I'm aware of, besides old LinuxThreads of course.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-669-1249570450-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkp67rMACgkQVKcRuvQ9Q1RH2gCfc4hlhWMj+LfNYTkBoRg8pB2C
YnYAoKd9N32zijGT+2Tu7nDLemZPhmZZ
=ODvo
-----END PGP SIGNATURE-----

--=_bohort-669-1249570450-0001-2--

--===============7977205344428546636==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7977205344428546636==--
