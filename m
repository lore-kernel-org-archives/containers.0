From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: Please include user-namespace.git in linux-next
Date: Mon, 14 May 2012 09:35:16 +1000
Message-ID: <20120514093516.2d567677f1ab1d02c3a9cc69@canb.auug.org.au>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<m1likyz4mh.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6392352840564311583=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1likyz4mh.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============6392352840564311583==
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__14_May_2012_09_35_16_+1000_pI/tG/LMiPoB66fO"

--Signature=_Mon__14_May_2012_09_35_16_+1000_pI/tG/LMiPoB66fO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

HI Eric,

On Fri, 11 May 2012 16:20:54 -0700 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman=
) wrote:
>
> In linux-next please include git://pub/scm/linux/kernel/git/ebiederm/user=
-namespace.git for-next

I assume you left out "git.kernel.org/"  :-)

Included from today.

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

--Signature=_Mon__14_May_2012_09_35_16_+1000_pI/tG/LMiPoB66fO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPsEU0AAoJEECxmPOUX5FELhwQAIXFMZAJcYwjEbc7C6MmP3PN
DDw090H9SdsSscDnFUSBfLP4vwIm+Cvt1uqP2TgBhRvoMUhfMvGWlZW6okfkjg4D
b6A9RI7Uldd8RxYTuTyEI7QkN37/QaC1scoJ0qhlO5vmVi4EhTp1Mpt1O2/pGeIV
EIEBqKDlfkydLI+9rxVrvWnR/D3N0u0m2NQifqshl0KQOW4GG0OssXTbLsvcS0th
rhxnhtjq3a6kxQLeqoeqWDTu7VWcQmkVEfsdyLYguSPYlN6Ga17pcRN7mECYLHgv
nuyfp0MI0cX3GQTccuq3A7MdNixnuagUOtv/KByGRtNsLVoKaJKH/CU3U6sruODV
IH5SkJnGhjA7z2C76y6zTsqZXlt4WBFNOjG8HcvEryHfF+EbiLvEfsPpazCddA0g
DAA1W8S8hY/9qbR6bL4X9tKHW2y+bT/326b2yfdIj/x7n6MlnsnAzQm0bvmTOZKf
6au7+bNSxjPHoCk5TVsVf9IWKc0pgcxjkJrF0yIh2G7eS1ripX7UMfNatTXQuz4d
qXTVQejMf1O3Dt+Iu6BnAwzX9YUEEpJRw2zv5UlDk9V7Rez9oFnWq+Oypt291TjM
6m+ieY21oT7fN547jYGUJcUvangKrQBUCo7HX1xgxan8lka8c0rc3ss5cASYtcts
Fpr1hvjuteS2DTH9dB9Z
=0vcQ
-----END PGP SIGNATURE-----

--Signature=_Mon__14_May_2012_09_35_16_+1000_pI/tG/LMiPoB66fO--

--===============6392352840564311583==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6392352840564311583==--
