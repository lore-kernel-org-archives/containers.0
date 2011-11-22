From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: linux-next: inclusion request for cgroup/for-next
Date: Wed, 23 Nov 2011 09:43:33 +1100
Message-ID: <20111123094333.550d9a0f918b8a74012ed6e8@canb.auug.org.au>
References: <20111122161746.GB3250@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7228452705945371279=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111122161746.GB3250-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============7228452705945371279==
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__23_Nov_2011_09_43_33_+1100_b3sThrsEGNJRL358"

--Signature=_Wed__23_Nov_2011_09_43_33_+1100_b3sThrsEGNJRL358
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Tejun,

On Tue, 22 Nov 2011 08:17:46 -0800 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> Can you please include the following branch into linux-next?
>=20
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-next
>=20
> This is the new cgroup devel branch and will follow the usual
> for-next/fixes branch convention.

OK, I have added that tree with just you as the contact.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Wed__23_Nov_2011_09_43_33_+1100_b3sThrsEGNJRL358
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOzCWVAAoJEECxmPOUX5FEseoP/3+Q45MNxfLk7TiV8dS2ip7f
5zRzNnheGslK/PveCigAIyNnZmx9B0BkJoOJsY09+pdc26PSRY29QvCaqF76iVTh
bYOrwgny4s3M1JuEzxeH+1N4utlESPKUOnSF/ekKHz5nfleHLnDVN0e0wkWoiHg0
iY4IBT+TDNeoJxLsI5pcKQObF9LpOudrb5r587yA9ZWbj+qqbUiMZ9tD2dwJJQmH
S82oPOACdC0Jrbeyy3OVkX5+xTsdP3Q91AS+yyc0r7Rqbq+fvmfirTodg8W0WtsK
GSFxDsBEh+temEnOTLFGgBw/f9rNWrIqmc0hwYyjovBLWYxrrX8jTE0yI80+ZnPW
RWhWDi2td2C5ilX6Aew2dIudeMYj6V5ZG9FiJJl8l6RwVW61mkpsHOFoI9QwCp0I
7KhELaXNsQHm4MgFdc91qfXokr3fECls8axiGQquOQDRFNkSvdiusPlOfmfmPgTo
EvaY+NchZaWOf2TbJNn9Iw/Q/vgtAWoMkk5leGlKdY8IQb0tUYyfk5jfXy8Kwfd4
l1QFqgYw/9Z/uvS3SLfujjOpe+TZW2qBne4z/JlKOMbl+PBKpEvddAPoqZXGXWkI
uZ/pLgC1Ut4aqclX1xtBqGpcZkvCv+UAZX0+aOkNouiY5mQ6FIFLBu2hfHDjj2S7
K87npSodBBpL/hLNoG0d
=BdHQ
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Nov_2011_09_43_33_+1100_b3sThrsEGNJRL358--

--===============7228452705945371279==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7228452705945371279==--
