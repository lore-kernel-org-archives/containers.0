From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: [stable] Locked mount and loopback mount fixes
Date: Sun, 10 May 2015 18:59:51 +0100
Message-ID: <1431280791.2233.50.camel__40945.5111403533$1431281808$gmane$org@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9160087483894417642=="
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============9160087483894417642==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZoaFvj7x6M2h9uXUe2Jg"


--=-ZoaFvj7x6M2h9uXUe2Jg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Why were these not cc'd to stable?  Was this an oversight, or are they
simply not needed for fixing any known bugs?

commit cd4a40174b71acd021877341684d8bb1dc8ea4ae
Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date:   Wed Jan 7 14:28:26 2015 -0600

    mnt: Fail collect_mounts when applied to unmounted mounts

commit 820f9f147dcce2602eefd9b575bbbd9ea14f0953
Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date:   Thu Apr 2 16:35:48 2015 -0500

    fs_pin: Allow for the possibility that m_list or s_list go unused.

Ben.

--=20
Ben Hutchings
When in doubt, use brute force. - Ken Thompson

--=-ZoaFvj7x6M2h9uXUe2Jg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVU+cnOe/yOyVhhEJAQpKmw//R3YVl0jCF9CY6PNt3RtgznyBPeMY/dlH
jP8RBvk/qfNHQb1693xZeK4LuD4zNs8rpfclwpIEB2a8PvV9EzljwtDy3sohNRPL
ZfMI6JTQv3iF/OXEekjLhHIuBSVAgrb3+kskoSLbtt8ne/xh6jvAdVodDsGSh237
TgGcpO9lcINSNdbPfhvDNmiannocxZfHhFHR1z7Xbrym4hzdZT/h7+UWCeH37pIf
z1Kk2aDg2ciGh+6VAL46wcdicAkqcAU9q2fCQwzO3HM1XtFhxHH2ynXBiWH96VUa
wGSrJfsOISGbGLRXf6fCGRtSO0zrIv09nkGtWdNf7TZOskeus8O0VMohBmXSqKFO
i2lxqVGoRDnkR9Xmt/4EgXvEmWTNs8Ecggrts9HxZwcWYgtD6hHFFO4mBLfx7pnh
g1QXP6tUgNxiPtbelrV3FjTHF70Fax4g5I+lQekwlO+l/LNggAE0UgLvIQ0SlKde
7v+GmE7jhm8Lyv4PsUDkmcB5+tAKZg71RZsGP4Sk5qN4FVx+3D/dCq728X+FcQ/T
zUlYQfo6Rbl7dvtWZ/nzviatgn1IWZ50NRejc+MdStxJC2tTNcflzQqkF3KJa8RJ
xgog/qTU+lqT4YjKly48IssRtsi5s1bOBFLBkwE2B1hIL5JacR7lNVqBLipgIKxW
mnJvCjrL7MU=
=vJUF
-----END PGP SIGNATURE-----

--=-ZoaFvj7x6M2h9uXUe2Jg--

--===============9160087483894417642==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============9160087483894417642==--
