From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 2.0.2 & 2.0.3, LXCFS 2.0.2 and LXD 2.0.3 have been released!
Date: Tue, 28 Jun 2016 19:27:12 -0400
Message-ID: <20160628232650.GA11902@castiana>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5967508022616098634=="
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


--===============5967508022616098634==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ZoaI/ZTpAVc4A5k6"
Content-Disposition: inline


--ZoaI/ZTpAVc4A5k6
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

Today the LXC project is pleased to announce the release of:
 - LXC 2.0.2 & 2.0.3
 - LXD 2.0.3
 - LXCFS 2.0.2

We had to release two LXC bugfix releases due to a problem in the
apparmor profile which was included in 2.0.2. Fixing the apparmor
profile is the only change in 2.0.3.


They each contain the accumulated bugfixes since the previous round of
bugfix releases a bit over a month ago.

The detailed changelogs can be found at:
 - https://linuxcontainers.org/lxc/news/
 - https://linuxcontainers.org/lxcfs/news/
 - https://linuxcontainers.org/lxd/news/

As a reminder, the 2.0 series of all of those is supported for bugfix
and security updates up until June 2021.

Thanks to everyone who contributed to those projects and helped make
this possible!


St=E9phane Graber
On behalf of the LXC, LXCFS and LXD development teams

--ZoaI/ZTpAVc4A5k6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJXcwfQAAoJEMY4l01keS1n0T0P/3k9X/2K2cw3YtdBd35/aWsN
PSsJ64rCT/xJ6LmnyIViIB6Und0/Q7/q1MW0Mv6z1ntsUEueCFAEdHnXLbEW2mk+
mcT3j650rComRdLnene250y7c7BtaTq03d73DpWD/jEK9BHGqPNZtgWAEwoG+RFV
jHNGT/7JixFAUSPs49hs9sQcc4FdS8tN7/wbGnqTvnT64ztPJYyNqhhahOep8cVI
epTXUsDXIpAoaPHYPT5n7HdZ1fJ2oMS4d32MFMdxrwyLnqg0uNr9Wk5AbIAnhq+6
4vZ6Bey/3+LHS+PF0i++w0FimqWa+37sdaDQNzlxvWWfHeaUciR8Cm8fKekCEAJs
el6VcOXWcgRIKSAEuVii6Ah7MBUQ7b2VKB1MdhpeqNT/z2EGb6/4bUQYaFYEoA00
Zj/lddSe6KO3pBaDhTJhHk63T+NAnBW9mfyVbtpPSDZg+fKFtn5of3JIdYkc/ZcM
AwcqHxT8BJ1Eqwk60ti9KnSgNbdW7GNgURPuyCevTUpKQvVg1Vhm4mIoaULvnA19
vA9kW9Uww7aqr37njw3KDbenA/mYMCySiJQgNnwJeKhMt1fzl8/5+2FoA4Jb4rZW
DQbJb5O+t55pbfGRSMzGdqWPtoA1rBEVf94kUVVUeKqO1S30ySacwe3YzVLnfvJO
mF5R50lfHy/wvbKT9xVu
=jKb+
-----END PGP SIGNATURE-----

--ZoaI/ZTpAVc4A5k6--

--===============5967508022616098634==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============5967508022616098634==--
