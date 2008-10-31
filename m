From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Fri, 31 Oct 2008 11:22:51 +0100
Message-ID: <20081031102251.GP15171@hawkmoon.kerlabs.com>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org>
	<1225411757.12673.383.camel@nimitz>
	<m1k5bpwj8j.fsf@frodo.ebiederm.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6587592376787198778=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1k5bpwj8j.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============6587592376787198778==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-31020-1225448425-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-31020-1225448425-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 30, 2008 at 08:12:28PM -0700, Eric W. Biederman wrote:
> Checkpoints as backup of where you are in case the machine crashes
> I'm not certain I believe in.=20

This is actually the main reason why checkpoint has been used in HPC for ye=
ars,
way before container-based implementations appeared.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-31020-1225448425-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJCtx7VKcRuvQ9Q1QRAv7uAKCwg2+dKm5orf9/3RJi2601tHI1PgCfRUD8
47Dpy4sMy10njBtCIr9M9ck=
=2SuM
-----END PGP SIGNATURE-----

--=_bohort-31020-1225448425-0001-2--

--===============6587592376787198778==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6587592376787198778==--
