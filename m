From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXD 2.0 has been released!
Date: Mon, 11 Apr 2016 15:34:32 -0400
Message-ID: <20160411193432.GA2850@dakara>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9014770541376535072=="
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
To: lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, lxc-users-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============9014770541376535072==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Content-Disposition: inline


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

After releasing LXC 2.0 last week, we are very happy to announce that we
have now released version 2.0 of LXD!

LXD is a new project, started a year and a half ago to provide a new,
cleaner, more user friendly, system containers experience.

It is based on LXC 2.0 through the use of the liblxc library and is
essentially a system wide daemon offering a REST API to interact with
containers.

It is entirely image based, supports a variety of storage backends and
advanced features such as live migration through the use of CRIU.


This is the first production-ready release of LXD and just like LXC 2.0
and LXCFS 2.0 will benefit from a 5 years commitment from upstream to
support this release through frequent backports of all bugfixes.

LXD 2.0 will be supported until the 1st of June 2021.


A walkthrough the LXD 2.0 features can be found here:
https://www.stgraber.org/2016/03/11/lxd-2-0-blog-post-series-012/

You can also try LXD online using our demo server here:
https://linuxcontainers.org/lxd/try-it


A detailed release announcement may be found here:
https://linuxcontainers.org/lxd/news

The release tarballs may be found at https://linuxcontainers.org/lxd/downlo=
ads
or you may get a packaged version of it from Ubuntu or Gentoo.

Our git repository and bug tracker are on Github: https://github.com/lxc/lxd

Additional information on LXD itself may be found on our website:
https://linuxcontainers.org/lxd

And we have mailing-lists for user questions and for development (patches):
https://lists.linuxcontainers.org

We hope you'll enjoy this new release as much as we do!

St=E9phane Graber
On behalf of the LXD development team

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJXC/xIAAoJEMY4l01keS1nnVcP/A6dJKbB0/kpp6aypg1YoXOE
vcnU2g5sTpWrAdMlq7C/62hB3LeQT6SK2ThjMIXyVml9yHV8TXMPZLqd81RBJojg
wv4QJCAdHcAPq0c6OqyovOjNQbH+EdudQkSsZIvl3lgMa4AR6PLLTBsigssSqs55
8utGm3PRxqw0TfD6fZZgqpvHs3+j6e9biGI2TFgwvM/ps8C2B06oWldrphS48Hpi
4P/s3wyANk5jxIT7Przxu/O2B6mhqD+m6o1OoQH/F7v4XIZa6RQltyFdz6F/W4HR
p+fFqZ+prIHFw5hGuIK5z5maYbIgQaID3pl0vStCpmU1loE4F9OUI8+0yhZKOHFX
D1e4P6l3Ec15XSadJ1yxmdQMyRkzJc9JM2SQlBBnjKqPBH//rdBLdgWKDNiIKuct
h10pmbr8RQ1tNvIvTj31keQVYBN3GZ2kAlMMp8FTi65jy5/qrzLCrXk9IXuYMka2
euDdnaYrnJe4OJ/HkyWp9h2dKs2uKeh5DuTR3PQLHkJZCyaogTWuMR7Jux7H0xgV
z/pJH7OOkScXfHLWJW4y4uMV1B8umO6i5b7Xrml8cQ+NMy75EiTJfNwL0G9wj5iH
+stWuZRofh1j0H8lrHEfOaE3weMi61Kh+MbXtWcA2Cb11WlOyqBS4Wk7E2RaLhXV
5D+jwR0095bZaVnKFHOi
=GNOn
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--

--===============9014770541376535072==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============9014770541376535072==--
