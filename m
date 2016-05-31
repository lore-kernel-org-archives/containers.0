From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXD 2.0.2 has been released (security update)!
Date: Tue, 31 May 2016 14:16:56 -0400
Message-ID: <20160531181656.GD26506__35546.2293061011$1464718642$gmane$org@castiana>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3041017994574663158=="
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


--===============3041017994574663158==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="oj4kGyHlBMXGt3Le"
Content-Disposition: inline


--oj4kGyHlBMXGt3Le
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

Today we're releasing LXD 2.0.2 as a security release for two recent CVEs.

The main announcement can be found at: https://linuxcontainers.org/lxd/news/


=3D=3D CVE-2016-1581 =3D=3D
Robie Basak noticed that after setting up a loop based ZFS pool through
"lxd init" the resulting file (/var/lib/lxd/zfs.img) was world readable.

This would allow any user on the system, and a potential attacker to
copy and then read the data of any LXD container, regardless of file
permissions inside the container.

LXD 2.0.2 fixes the "lxd init" logic to always set the mode of zfs.img to 0=
600.

Additionally a one-time upgrade step will trigger on first run and reset
any existing zfs.img mode to be 0600.

If you manage an affected system and suspect an unauthorized user may
have accessed the zfs.img file, you should consider replacing any secret
that was stored in the affected containers (private keys and similar
credentials).


=3D=3D CVE-2016-1582 =3D=3D
Robie Basak noticed that when switching an unprivileged container
(default, security.privileged=3Dfalse) into privileged mode (by setting
security.privileged to true), the container rootfs is properly remapped
but the container directory itself (/var/lib/lxd/containers/XYZ) remains
at 0755.

This is a problem because it allows an unprivileged user on the host to
access any world readable path under /var/lib/lxd/containers/XYZ which
may include setuid binaries.

Such setuid binaries could then be used on the host to access otherwise
unaccessible data or to escalate one's privileges.

LXD 2.0.2 fixes this behavior by making sure all privileged containers
are always root-owned and have their mode set to 0700 to prevent
traversal by unprivileged users.

Additionally a one-time upgrade step will trigger on first run and reset
any existing privileged containers' ownership and mode to root:root 0700


We recommend everyone update to LXD 2.0.2 as soon as possible.
Especially if you are a user of loop-mounted ZFS or privileged
containers!


Thanks to the Ubuntu Security team for coordinating the disclosure of
those two CVEs with other Linux distributions.


As a reminder, the 2.0 series is supported for bugfix and security
updates up until June 2021.


St=E9phane Graber
On behalf of the LXD development team

--oj4kGyHlBMXGt3Le
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJXTdUYAAoJEMY4l01keS1nx5gQAIAiygxH/Mcl4zWLGRbUN50Q
Qb7aiqpTkSyVmX4Z8hS3aoXWJgCHAw813RC3Jg8bQX0vAXv4NEUtOdAfncCgtcez
VaWoKbFdqMkd5MyDFz9t1huSpLLMPHPtwfo1F79OINZjiDN3cpZZ+mh7sHnboKQn
EJSU9fSHc2ldfOWLaZQMlFca54hVoL2UcR4/p5oqfh7XLQmD9tR80AerB/2TyKiN
Bhms3PltHlv78ogkF1IkaNSVAZaaC/g4UJkZnuUSyDcL0hD4st/YbUX8srxnGBvc
O0p2OyQ884V6KWQ+pLqfEW5Zm+tPB1RjMw5ISOlItLCMUHQeP0R0yPBJ7+dQNYmB
kBZEoXn50pIy7mTzRTHBLrjwBZRTEZ9aIL0DJc0Up8XwGsO4cjcbAbA4iFVhyuHW
Nc/mTAvvq6BMnbnKCpWJPgN5YFayY5HLYTfo1KPkO1lLzLOnKdnQVIDSUStU4621
rHOloDa2VQvGvXj7LlG177JbkCAvfPPy1r7sl2Ms8sBjP7D4lHg1/5fPTFk0ICh7
Hmt2NdcJlJJ7+OoUh5vDugWuKCKGRYoarGUQQ8zEgLrSn+HOJzL0Dhdlv5LdpK3D
Q0vpqcERyC6HBJ/EDh1E9SQv762lhzSvQNpUaDGM4JLdJqr2bmZ/WGuNawmaK7J+
1Rdxta7M0J0tf8eomi6v
=XzHk
-----END PGP SIGNATURE-----

--oj4kGyHlBMXGt3Le--

--===============3041017994574663158==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3041017994574663158==--
