From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Thu, 15 Feb 2018 07:39:33 +1100
Message-ID: <20180214203933.55yraxue7hpup65x@gordon>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<2050418.Dl5pXkWGsk@blindfold>
	<4f620eb7-c00c-487b-2e06-8cc4c97af38c@metux.net>
	<60748622.exvCVAzLTp@blindfold>
	<e924b563-44c6-d678-a6cc-1181f4b820d5@metux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4908068134935903588=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e924b563-44c6-d678-a6cc-1181f4b820d5-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Richard Weinberger <richard-S6VGOU4v5edDinCvNWH78Q@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============4908068134935903588==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="45q67fkve2bvqniy"
Content-Disposition: inline


--45q67fkve2bvqniy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2018-02-14, Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org> wrote:
> But still I wonder whether user_ns really solves my problem, as I don't
> want to create sandboxed users, but only private namespaces just like
> on Plan9.

On Linux you need to have CAP_SYS_ADMIN (in the user_ns that owns your
current mnt_ns) in order to mount anything, and to create any namespaces
(in your current user_ns). So, in order to use the functionality of
mnt_ns (the ability to create mounts only a subset of processes can
see) as an unprivileged user, you need to use user_ns.

(Note there is an additional restriction, namely that a mnt_ns that was
set up in the non-root user_ns cannot mount any filesystems that do not
have the FS_USERNS_MOUNT option set. This is also for security, as
exposing the kernel filesystem parser to arbitrary data by unprivileged
users wasn't deemed to be a safe thing to do. The unprivileged FUSE work
that Richard linked to will likely be useful for pushing FS_USERNS_MOUNT
into more filesystems -- like 9p.)

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--45q67fkve2bvqniy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAlqEnoIACgkQnhiqJn3b
jbRwxQ/7BE3wVUP9GsXPbxtByKmh4mlHGR1IkTlzxGs09+IVxiOF8mmfaGviElD5
i6vWhYhv9JFzTvONadYoGFy/BhYiDW5QxYN9HUduHOA4aMpW7nrnq3HVbZQSumU1
7tt1ULEXzm+LSJdFFk5o3VaK+twkmFYaa9F8C/pH1Ywy6k4Cq16eP9aj08Qt1ADW
1ORXyVKPrr5j9o39EAZNu/qu6Xzv5WVa8LvAxshAUQDrhIxmQqqyYZ9nSAc9ecQt
0MouBo8I3HzK3YQDTeQwKGTWIPFtLsnoL+p69CtiKuhSVTTjcN20xGDgohpCYQud
7mMZt4GrHgSE0JV8gwgLhMKeHPmD7I0QTIoODJbXh5xL/Q1gt5cjZ4fOMk20DsO1
mBSNlrYyH8WlLITwNpxi6XecNDb6CBwh3rOnMoC5ELl2v9zsSsPll//ENTJIqz5P
U1dvn9hahHvSnDsz8A6cjtvPBYHB8gofaHKUxhFMrqn1vakP8uQEkvCLx/knnR4K
JlmTlUxgx+JDm1lmx9ai+JHXjzjyI6f6LtKlvWOqPeIvCD5rWRbTZvkOOn7s8mLV
sEdeOFkLrKNIGfvOaipY2SEMgsfzbc3yGXBrWbaydjDAMeFwiqWycdQlQ7NyRhX5
TxU7WphcjR+4QBAhFL6xuAkjsXe1dkBHTeNAkUSQ7Vli+iuMo+Y=
=j1bi
-----END PGP SIGNATURE-----

--45q67fkve2bvqniy--

--===============4908068134935903588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============4908068134935903588==--
