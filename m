From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 09:27:51 +1100
Message-ID: <20180213222751.p3fyg7whg6jqlzz5@gordon>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<5633d335-3926-d98f-d6d7-948b1e2a0b2c@metux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7694765457081725633=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5633d335-3926-d98f-d6d7-948b1e2a0b2c-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============7694765457081725633==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="a6hqz3juwskhopve"
Content-Disposition: inline


--a6hqz3juwskhopve
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2018-02-13, Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org> wrote:
> On 13.02.2018 22:12, Enrico Weigelt wrote:
> > I'm currently trying to implement plan9 semantics on Linux and
> > yet sorting out how to do the mount namespace handling.
> >=20
> > On plan9, any unprivileged process can create its own namespace
> > and mount/bind at will, while on Linux this requires CAP_SYS_ADMIN.
> >=20
> > What is the reason for not allowing arbitrary users to create their
> > own private mount namespace ? What could go wrong here ?

You can do this by creating a new user namespace (CLONE_NEWUSER), which
then gives you the required permissions to create other namespaces
(CLONE_NEWNS). This is how "rootless containers" or unprivileged
containers operate.

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--a6hqz3juwskhopve
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAlqDZmcACgkQnhiqJn3b
jbQBiQ/+PPO9TOTnb9rSgeR/g5QRZEI4/mUBjlwDl/F6bBXb/23FMBBX2DnaZ5uk
XgeRYDQcw5kh62Zq6QSXNMOmodfoI3WhEMUh/p3xVHCOTwfs8UR7kaE1YjXg0sld
wtTFePg75WF+A9ct1SWCm0vMKn2u2+iLcb0l3XqIl/xGplSbfRXWMIBAMxLgwOG/
/FNR4vTuxuDcsRXOo7TdfvY+vMf1yQJrb0DamZx+hshzh+a4l4Q5MjOb2pffhNrj
eBymq06aFn69KETJFnujIPXOm87zPieH/bF98xMdn64xuX8Z1JZ0+Ei9ISnxK2Uf
Be8FQlrkuJ7t3LU8YUX0Sg9tgxVO8jHeTlWduo02NCUEntBxc5nZAe1IwbQmieoC
604OKkAA6Qv5xi2/cKKUgXpcyZAvvn7oKPJlmyYkwUXmL1TafB1MISXIVhx1MQWa
fPsKtSOYvHzOCmFmS/LBuQEBJOQvk4x3qt4YT59pcnuR00Tn6Hv2cIl7q7zFTr5C
Twz3zDlcR5iV5mS+PUhKvwiS5trMB3+SJzz9fUP/AhSe39ojfnWDVRoNo5WjZkeO
dwuFm6PEN3cqN4ljj2NAoT3VbiMomcpjl4W1HJuoeDR8q6yCfYe4xNmfpLQnP6jP
sV/mUbvdCs7eiRUoPYwticI6NYYFzMuhHEIZ2kJ1EpYQzbYMkG8=
=EiJn
-----END PGP SIGNATURE-----

--a6hqz3juwskhopve--

--===============7694765457081725633==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7694765457081725633==--
