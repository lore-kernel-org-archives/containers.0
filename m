From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 2.1 has been released
Date: Wed, 6 Sep 2017 01:37:38 -0400
Message-ID: <20170906053738.j3gsfcmlzbipkgbv__16835.112454328$1504676279$gmane$org@castiana>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7986781876306133670=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lxc-users-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
List-Id: containers.vger.kernel.org


--===============7986781876306133670==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="sqbclaag3osbchoi"
Content-Disposition: inline


--sqbclaag3osbchoi
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey there,

After 1.5 years of development, we've finally tagged a new feature
release of LXC.

LXC 2.1 is a normal feature release coming with a year of upstream
support. For production environments, you should stick to LXC 2.0 which
benefits from much longer support.


This new release of LXC introduces a few new security features and
various improvements to the LXC tools and templates.

But more importantly, it's a transitional release ahead of LXC 3.0 to be
released early next year. LXC 3.0 will deprecate a number of tools and
change a large number of the existing configuration keys.

LXC 2.1 will issue warnings whenever the user is using something which
will be removed or renamed in the upcoming LXC 3.0.
An lxc-update-config tool is also provided to automatically convert your
containers' configurations to the new format.


More details about LXC 2.1 can be found in the release announcement:

  https://discuss.linuxcontainers.org/t/lxc-2-1-has-been-released/487

--=20
St=E9phane Graber
Ubuntu developer
http://www.ubuntu.com

--sqbclaag3osbchoi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJZr4mdAAoJEMY4l01keS1nCdEP/jYHOVTiTKwj6J434JymZDOB
NCFG0iTgiJ8OEFleEs7Qr2fF/B6fOL0KZA3L6dqWnBxtsjEj4BWjVp1x8vJF2OnB
Yo04aNcWAAkFu6MXBjPK3PreWjlMpyq0adGHGzdR5qDceVaGcAhBC86FqPYyfEzo
Zt9IkvE7F1ubjoH9L8NnSbeCv05oGc44USUYhPAhShpTmfoJN+zyvsLOMZnQFXZn
ptHtOGctOW/Zvq0/7e9LSqAGQJGIiwy8VB/JBVnt3bOg8yR18TBJ1ZUs6ORMuIq5
nVPwDF19Z3tRF/e9fxpKlorjE1z08tcUrD2JAy4bZcUaFdzYkABe0IBqwgw2f9tu
uTRmk35XrZHfy0ckN+6ofndF9wiV+gC1RZ6iaHyvQuLoW6XnURjYY8y9xjGjgsEl
zlHegZIJo90ew1w462BxYgS1jrrgiGxrky0fykFjshmA/YjBfZMKDNO+pRqyDxcK
Y4a36qyrY6+PxiWf6sct7MUaHQuz1zN9fRB14U5J+0hHekVSPYGfODDzyQANnlFA
roMiUm+qma7F7FwTYcEZlQdoLq7wiN9Rp5qIoEVBN8p9rOrNWCSDFJQDH4ArKLeL
lMScyjKemaBhr257Ab3ujoaqNC9+h/KqiXLkvvT8BFnYPFbJ/c2RHye1EQSv4OuN
T4vvIMiEjJflSdMk29F2
=Ukdf
-----END PGP SIGNATURE-----

--sqbclaag3osbchoi--

--===============7986781876306133670==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7986781876306133670==--
