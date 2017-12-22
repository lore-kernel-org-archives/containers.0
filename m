From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] userns: honour no_new_privs for cap_bset during user ns
	creation/switch
Date: Fri, 22 Dec 2017 13:17:34 +1100
Message-ID: <20171222021733.rerkt6mhpf3cb3oe@gordon>
References: <20171221210605.181720-1-zenczykowski@gmail.com>
	<87wp1foiwa.fsf@xmission.com>
	<CAHo-OoyrOr5jXwU-j4Z4qYdWo40+qAdAk0r+OpfMUZ6LgbS-RA@mail.gmail.com>
	<87fu83lfw5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8983374409890909422=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fu83lfw5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============8983374409890909422==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="kwekmczu27otmcjx"
Content-Disposition: inline


--kwekmczu27otmcjx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2017-12-21, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Good point about CAP_DAC_OVERRIDE on files you own.
>=20
> I think there is an argument that you are playing dangerous games with
> the permission system there, as it isn't effectively a file you own if
> you can't read it, and you can't change it's permissions.

This problem reminds me of the whole "unmapped group" problem. If you
have access to a file through an unmapped group you can still access a
file -- which to me is wrong. I understand the need for checking
unmapped groups in order to fix the "chmod 707" problem, but I think
that unmapped groups should only *block* access and never *grant* it.

I was working on a patch for that issue a while ago but it touched more
VFS than I was comfortable with. Eric, is that a fix you would be
interested in?

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--kwekmczu27otmcjx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAlo8az0ACgkQnhiqJn3b
jbTpKw//RTizKTfmoglKt9khvpo5Jdu97/nH1jHle2INERKwTMHqugDWWvYM9Gis
Plf52oDTUQf0qoIT10Y8n8WfZ8v0Z/zBoayjEB0Mz4JB4OXFJobcF0bn55eOqGwQ
bgOciUBVu2zA7nlWk7ROlnSQaRVmbsxdUhymq12dhS6rwh9fBCExzzLdSWZCbzWk
4SV01CXTTfoIjQN57OYA8UcBJXUJRido4TXchTlqTtK5P6u1C8FLCbn9nOhQbIHA
eduI6gLlNVptp5a4Wod4VFBkmZcOuSPqcZ1BYVXKkMcI/108eQNCSDROWBnL7FWu
UKzjT/tXiXofXKkF1fD1fQeKYCmPiduGrC91sSr0Qj+S470J1xK0RRLm5RbMed5J
NHl765DMS3RCYIgrghduGew7P4Go5u+BBPeM8iMZdI1WTwlwdDzRCBJjHSII+8Sw
k/6Cw0WSdG5XV0k1WPsrKydz3xLK+Z3M1nOFpDe3xgLWAFqpm04+k695Nxk4SuMh
eIozExu9SKdA4L9kCCZr7eIZzzvU0sWHiN9twGRqMneFZ297azcbeqPuQ2cGmjtm
Y6EfaGP0XCEzRwYdFt1yYPXFhIeqWbujctmmQQJuoVlv9PuTbsP1uFT7lzC7eCkn
P7KIc+k1Zd/SYmb5ePQrQIwgJzx1dbxyf3gpO7xHeTdXAt1CCkQ=
=i2Hp
-----END PGP SIGNATURE-----

--kwekmczu27otmcjx--

--===============8983374409890909422==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8983374409890909422==--
