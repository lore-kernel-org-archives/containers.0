From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 21:24:10 +1100
Message-ID: <20180214102410.dxgbayb4i76h5exo__22444.5548643873$1518603771$gmane$org@gordon>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<5633d335-3926-d98f-d6d7-948b1e2a0b2c@metux.net>
	<20180213222751.p3fyg7whg6jqlzz5@gordon>
	<39b08c53-3449-3164-c1b1-44ac587dd4ea@metux.net>
	<20180214045442.jyv6zpbwz5glzi4z@gordon>
	<9c097fd9-3035-d5be-a829-fc18e7734f18@metux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6824444835445770742=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9c097fd9-3035-d5be-a829-fc18e7734f18-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============6824444835445770742==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="i6vlwh3q4g7b5nmn"
Content-Disposition: inline


--i6vlwh3q4g7b5nmn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2018-02-14, Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org> wrote:
> On 14.02.2018 04:54, Aleksa Sarai wrote:
>=20
> > It depends how old your kernel is and what distro you use. Arch Linux >
> > disables user namespaces entirely, Debian requires that you set a
> sysctl> to enable unprivileged user namespaces, and RHEL requires you to
> set> both a sysctl and a kernel boot-flag. Also check how old your kernel
> is> (unprivileged user namespace support was added in 3.8).
> Just tried on a mainline kernel (4.15). Same problem:
>=20
> root@alphabox:~ unshare -U -r
> unshare: unshare(0x14000000): Invalid argument
> root@alphabox:/proc/sys/user cat max_user_namespaces
> 5922

What distribution are you using and which release? Also, are you trying
to do this inside a Docker container or something similar (Docker has
seccomp filters that block CLONE_NEWUSER by default, for instance).

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--i6vlwh3q4g7b5nmn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAlqEDkcACgkQnhiqJn3b
jbR/lRAAhtJwY1LdR9n3xTMOgI6w518forGtJw6stoKAUvTvSv0ZbTqR6da1J2YA
fwPosBpttzWbygbhi/7GjzCYkNUDYu9OJMf/toXHqniuvnj7KlDODCsAUlIe3CEx
8aaPSHDuSxrmi/Mu66f89DT58flU5zc/jrVr8CH5Rk8yY8fVW5zI7RtV7o9xCz6/
CW8Dhu0fIBPxzK3lGK5bfmsiWXL/zsDe5e2cHBczX4fUORfIYepQ8luAbckOsxYE
lGqlPM0/NwdgSrSpL2g+a+6WhN+ZI2FsQak75d0XtJ28l/pwAizcAYKquPUEd9dp
wkFS6g3TSZ7pEK8NdCKT1D6y00ZtzEhX2eUZq3VDSnVcf8y67e3u/JtSIBayIo4L
gwKsvZOWu9yjPOQiPgSl3Znlas0uIbR5EOcxQ4q4Fu1jnX7IRdz/kjDDfW+sYHgi
EL6+6LxV+fr6hKaisKq5QprefpU9bk4n0prPv6aw8nCw9dwPD8FDvLi2cy/Io1fz
slE2XTFNFDP1T91iRsWrlXl1OmwT9wJvHTl5MaY774L1cMluqbXkDgEXZVniE5Rq
ze7+BJluc4KLb5VpnT5qUAqWOc+VdoVKPxewunXn9+qxSfSEUmw144vumVivuvAp
LOQ2Tr+1mWSen+odSI8+atCmygixQNxhvTGHOUeNfdfeQx7+vyo=
=HU2g
-----END PGP SIGNATURE-----

--i6vlwh3q4g7b5nmn--

--===============6824444835445770742==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6824444835445770742==--
