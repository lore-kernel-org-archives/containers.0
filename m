From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Wed, 6 Aug 2014 14:46:43 +1000
Message-ID: <20140806144643.45e5dab8@canb.auug.org.au>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3761373110875513739=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fvhav3ic.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

--===============3761373110875513739==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ldyByQSDKEd2wn32YQ=Q0EM"; protocol="application/pgp-signature"

--Sig_/ldyByQSDKEd2wn32YQ=Q0EM
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Tue, 05 Aug 2014 17:57:31 -0700 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman=
) wrote:
>
> Please pull the for-linus branch from the git tree:
>=20
>    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.=
git for-linus
>=20
>    HEAD: 344470cac42e887e68cfb5bdfa6171baf27f1eb5 proc: Point /proc/mount=
s at /proc/thread-self/mounts instead of /proc/self/mounts

This has had 4 commits added since the merge window opened that have no
Reviewed-by, Acked-by or Tested-by tags and only one Signed-off-by tag.

> The last change is a small semantic cleanup introducing
> /proc/thread-self and pointing /proc/mounts and /proc/net at it.  This
> prevents several kinds of problemantic corner cases.  It is a
> user-visible change so it has a minute chance of causing regressions so
> the change to /proc/mounts and /proc/net are individual one line commits
> that can be trivially reverted.  Unfortunately I lost and could not find
> the email of the original reporter so he is not credited.  From at least
> one perspective this change to /proc/net is a refgression fix to allow
> pthread /proc/net uses that were broken by the introduction of the network
> namespace.

They appear to include this last change.

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

--Sig_/ldyByQSDKEd2wn32YQ=Q0EM
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT4bM4AAoJEMDTa8Ir7ZwViE8P/2Ok1V6Oi5EZ4tUBzBDVDB9q
cz1LRHeoMqTDjfQrFTPJ8bXcDt1rW9aYCci+0uFgeP13XkHqMBHMktReBYfr3W3H
dZOoYwisaI/fDy7STICurMGGmS9LEYQ7YCntrMq679FPAfHK2nTTbE/JpTChhlVr
6TiGIitU0wQTeSxFSQwXbr2AsQ8SzlDviuhmmBRjUBCP/NA4/I9W0uEVfZliO5Sa
0L312fmjFIStrSR0auUdvhE2dplkTZXXKrJBQGhGTnJ+UqXtam+2fjTvChYlt4bx
JlsqIG58J5u+2YOi8EeS6OxCQyoP+j/qFCcHe1j2G7cXRcF1svYlI0MjzB139gVQ
6HGeOXj/rW5w2hZxOVDeWN3QQRSZrwv0QRQ0VC5he9skiIhDt+9cB/qehX98ttQG
CQtZQJemFP9yutB7YxJL+d3WusSjGQnQ30y3W5Sy6+2DiQaK77adP+3ppBD9zjRW
/6fLYs2fvFyXEO4n/cfifzBv47eOfNr7x+kQRCKEIsvi//5vV017nF2XfsaXrLb/
qtu7RlM4Q80Ty3ab6JEhZ80DfoBX6fUoocR8A7XeA5CyjpGvYmUoWf9WBQuHW3r2
b1+No4/d30JoWhM9JuUKe+i0O4NVo2UPh9KUfhywrWFMF1tCoQrUnqk6akFdHups
zifFHi4S+VfJRvjECbdJ
=Hqul
-----END PGP SIGNATURE-----

--Sig_/ldyByQSDKEd2wn32YQ=Q0EM--

--===============3761373110875513739==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3761373110875513739==--
