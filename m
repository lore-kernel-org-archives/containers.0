From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/6] c/r: [pty 2/2] support for pseudo terminals
Date: Tue, 8 Sep 2009 10:50:13 +0200
Message-ID: <20090908085013.GQ12824@hawkmoon.kerlabs.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-4-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7723876298366021151=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252074054-22241-4-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============7723876298366021151==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-22300-1252399773-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-22300-1252399773-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/09/09 10:20 -0400, Oren Laadan wrote:
> This patch adds support for checkpoint and restart of pseudo terminals
> (PTYs). Since PTYs are shared (pointed to by file, and signal), they
> are managed via objhash.
>=20
> PTYs are master/slave pairs; The code arranges for the master to
> always be checkpointed first, followed by the slave. This is important
> since during restart both ends are created when restoring the master.
>=20
> In this patch only UNIX98 style PTYs are supported.
>=20
> Currently only PTYs that are referenced by open files are handled.
> Thus PTYs checkpoint starts with a file in tty_file_checkpoint(). It
> will first checkpoint the master and slave PTYs via tty_checkpoint(),
> and then complete the saving of the file descriptor. This means that
> in the image file, the order of objects is: master-tty, slave-tty,
> file-desc.
>=20
> During restart, to restore the master side, we open the /dev/ptmx
> device and get a file handle. But at this point we don't know the
> designated objref for this file, because the file is due later on in
> the image stream. On the other hand, we can't just fput() the file
> because it will close the PTY too.
>=20
> Instead, when we checkpoint the master PTY, we _reserve_ an objref
> for the file (which won't be further used in checkpoint). Then at
> restart, use it to insert the file to objhash.
>=20
> TODO:
>=20
> * Better sanitize input from checkpoint image on restore
> * Check the locking when saving/restoring tty_struct state
> * Echo position/buffer isn't saved (is it needed ?)
> * Handle multiple devpts mounts (namespaces)
> * Paths of ptmx and slaves are hard coded (/dev/ptmx, /dev/pts/...)
>=20
> Changelog[v1]:
>   - Adjust include/asm/checkpoint_hdr.h for s390 architecture
>   - Add NCC to kernel constants header (ckpt_hdr_const)
>   - [Serge Hallyn] fix calculation of canon_datalen
>=20
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

[...]

> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index a3afa0c..b8f8d79 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -570,7 +582,9 @@ static void do_tty_hangup(struct work_struct *work)
>  	set_bit(TTY_HUPPED, &tty->flags);
>  	spin_unlock_irqrestore(&tty->ctrl_lock, flags);
> =20
> -	/* Account for the p->signal references we killed */
> +	/* Account
> +
> +	   for the p->signal references we killed */
>  	while (refs--)
>  		tty_kref_put(tty);
> =20

Nit: this hunk is certainly not needed ;)

[...]

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-22300-1252399773-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqmGsUACgkQVKcRuvQ9Q1SBKQCdFdwxtLb65ge81vURaz+6NAys
NVQAoIyRvS6D7oRaVjsxzD0qPrrwDMut
=SJFM
-----END PGP SIGNATURE-----

--=_bohort-22300-1252399773-0001-2--

--===============7723876298366021151==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7723876298366021151==--
