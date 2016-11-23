From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 1.0.9, LXC 2.0.6, LXCFS 2.0.5 and LXD 2.0.6 have been released!
Date: Wed, 23 Nov 2016 17:08:23 -0500
Message-ID: <20161123220823.GG3374@dakara>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7820722998961814464=="
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


--===============7820722998961814464==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="0qt3EE9wi45a2ZFX"
Content-Disposition: inline


--0qt3EE9wi45a2ZFX
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

Today the LXC project is pleased to announce the release of:
 - LXC 1.0.9 (includes fix for CVE-2016-8649)
 - LXC 2.0.6 (includes fix for CVE-2016-8649)
 - LXD 2.0.6
 - LXCFS 2.0.5

They each contain the accumulated bugfixes since the previous round of
bugfix releases. LXC 1.0.9 and LXC 2.0.6 also fix CVE-2016-8649.


CVE-2016-8649 was reported by Roman Fiedler from AIT and is a way to
access the host filesystem and therefore escaping the container through
an inherited dirfd to the host's /proc.

This issue is possible because the Linux kernel doesn't prevent root in
the container from attaching (with ptrace) to the lxc-attach process
then running as real root.

Eric Biederman submitted a set of ptrace fixes to the Linux kernel which
will prevent this kind of attack from being possible in the future.

The fix we're releasing today, simply stops passing a full dirfd to
/proc and instead only passes the one file we actually care about,
reducing the impact from an attacker attaching to the process.


The detailed changelogs can be found at:
 - https://linuxcontainers.org/lxc/news/
 - https://linuxcontainers.org/lxcfs/news/
 - https://linuxcontainers.org/lxd/news/

As a reminder, the 2.0 series of all of those is supported for bugfix
and security updates up until June 2021.

The LXC 1.0.x branch is supported until June 2019 with critical bugfixes
and security updates only from this point on.

Thanks to everyone who contributed to those projects and helped make
this possible!


St=E9phane Graber
On behalf of the LXC, LXCFS and LXD development teams

--0qt3EE9wi45a2ZFX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJYNhNXAAoJEMY4l01keS1nzyAP/3A+seeXdyHmz9qArsZbL4Sq
7h27/ONnpkKqML9ovxUw5IYOeOkmcHi1v5/E9Nx9Be7ZapzVF2Ti+WO+0QIzSsDs
Y6ObykmbYBblRt3LJurSfK30ekAhhDD8Ct2gUdQATkDaoLtQb4WuatPkPI+0nfLW
wZ9BO6ev0H9S0hY3Cb4XyIrVNICWtyGijF2X/4FOo2d+sxyK+FeSo7pt3SLWI5WO
Hof39eaMz/iKA8kcSDf9fxXd0dtSi1bvwZtl2DtCabcbNyK5sDaSAsCm9GO7Pylx
qCWzAB/3YMwnRTFBZyc3kCZYuqOHaKTOy8/zlYI6pubEazV2I3zW/CuvXSY9ihU6
hS9B55tlkMR2vRYR7ikht0DWukg/qvU23ajW0vPAXLKaqLNNNCQ9WtepT257jcRB
B4cJgwxiV00s8XTuftJIe4nth8mjyKnjbndJlrk3P9HDlGQ1WaZ9FlzaZmN/tru+
4d3gkLeiZpwe6aqZmYIivx2ipRDo1VzOiN3T70tcG5UaJNg1nv/UrGQFTB1lcvy7
Cr5fEkWbErBVlfxzqXEzY8EZSN1/VN41qVTbUlxEh8CIR2b1HZyny25UffpwPuPo
v8zEpWreZJrUodCqYNEGeSAInzvxXf0lXK/9Y8aCBjGzvK2W6Dkb+9D9+/A5MckG
RdK0ZgUva6WBUIgfyuam
=jy+R
-----END PGP SIGNATURE-----

--0qt3EE9wi45a2ZFX--

--===============7820722998961814464==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7820722998961814464==--
