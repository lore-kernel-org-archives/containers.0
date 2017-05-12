From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 1.0.10, LXC 2.0.8, LXCFS 2.0.7 and LXD 2.0.10 have been released!
Date: Fri, 12 May 2017 00:39:06 -0400
Message-ID: <20170512043906.ent4zilmmrildzoh__21198.3307767243$1494564460$gmane$org@castiana>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6070971999758655849=="
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


--===============6070971999758655849==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="2eqekquf3xx5ajdf"
Content-Disposition: inline


--2eqekquf3xx5ajdf
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

Today the LXC project is pleased to announce the release of:
 - LXC 1.0.10
 - LXC 2.0.8
 - LXD 2.0.10
 - LXCFS 2.0.7

They each contain the accumulated bugfixes since the previous round of
bugfix releases about four months ago.


This includes the following security fixes for which individual patches
were made available earlier this year:

 - CVE-2016-10124 (backport of pts/pty isolation to LXC 1.0.x from 2.0.x)
 - CVE-2017-5985 (lxc-usernic issue for LXC 1.0.x and 2.0.x)

It's also worth noting that LXC templates in 2.0.10 have been modified
such that no default (insecure) user credentials are set.


The detailed changelogs for each project can be found at:
 - https://linuxcontainers.org/lxc/news/
 - https://linuxcontainers.org/lxcfs/news/
 - https://linuxcontainers.org/lxd/news/

As a reminder, the 2.0 series of all of those is supported for bugfix
and security updates up until June 2021.

The LXC 1.0.x branch is supported until June 2019 with critical bugfixes
and security updates only, users are recommended to upgrade to 2.0.x.

Thanks to everyone who contributed to those projects and helped make
this possible!


St=E9phane Graber
On behalf of the LXC, LXCFS and LXD development teams

--2eqekquf3xx5ajdf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJZFTxnAAoJEMY4l01keS1nEtoQAKa2PWr/3ojYYpVgmnbxl+Vb
wXDRgqauczFRes3SoSpuNqOTytL2LYSgd0CY8EXzcpvxPCH1POsW65Qud35sEBx4
VUYF+/TfSi9xBAZHXK2FNUYLqJUDgVvn5FT+cQSruWoclI+BAuJj9RkcMDtZqDb5
55SKxyi0l16pp8Q76FRLO7xk/pDQtX9LvVOnQmtbhrNLaHsKDpzIBEL5MMaloR57
VdhQBgRoQ/IcdIN91Kgek7r4mf8mn3swS3EXeFl//PIZUkB8M0mUXUCkvjJvSQn5
qhEPH9RfIfhZ3wYm+9UmUoevMtPtIVqbvAavdHMsUyc7DvE42CjyiW0IPQ2a01Kz
axADtG91aa/xHqXsMzuCcuHjrMzY6LjcluVWt2ts9O7yIA9uR+lPigjxx959CQw1
H2tuZ0rzAC4vVMjZgwi2Rf6RZt0EnqVqg1bv2yHGxZ06Cx0o0RUrLVLOq05cr2KO
bAwXZpYRUEW5P4F0LauIV1VUCJbS8kBRUsxNorxWLUjrPgohpwEql2B2a5VJieOK
E4LpU/8N13vYfU75paqQfIbxqGpiX/PHDgTYJpfNX/b5LhEN6KYxwxyODwHqVneu
r+cDZdw9B4g+UgzC8DU6/TXgY26Z8Urvg5DCpyw32PfNqZ+YYx+Lql1ubJ0C09y3
tMGnmY56nlwLslqNKBgb
=6hck
-----END PGP SIGNATURE-----

--2eqekquf3xx5ajdf--

--===============6070971999758655849==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6070971999758655849==--
