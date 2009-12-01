From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: how to handle devpts
Date: Tue, 1 Dec 2009 10:37:08 +0100
Message-ID: <20091201093708.GC2430@hawkmoon.kerlabs.com>
References: <20091130202223.GA20224@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1356077486017337647=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091130202223.GA20224-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============1356077486017337647==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-12845-1259660169-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-12845-1259660169-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Serge,

On 30/11/09 14:22 -0600, Serge E. Hallyn wrote:
> We currently checkpoint and restart unix98 ptys in the kernel.
> So what do we want to do about the userspace part?  In particular,
> if I run the following test program and checkpoint it, it
> has `tty` open.  What do we want to do about that?
>=20
> Just having user-cr/restart.c take an option to mount a new
> instance of devpts isn't enough - we don't get hooked up to
> restart.c's stdin/out obviously, and restart succeeds but the
> restarted program exists with -EIO.  At the same time, just
> doing a cradvise type of thing to plug fds 0,1,2 suffice for
> this testcase, but not for something more complicated which
> also has other unix98 ptys open.

In Kerrighed we are implementing something =E0-la-cradvise: we allow the
caller of sys_restart() to give replacement fds for arbitrary files. To ach=
ieve
this, each checkpointed file descriptor (struct file) has a unique key, and
sys_restart() takes a substitution table in parameter, where an entry is a
pair (key, fd).

In Kerrighed sys_checkpoint() exports a human-readable table of checkpointed
file descriptors, with types, fd in each checkpointed task, etc.
With Oren's patchset, I presume that some userspace tool could extract such=
 a
table from the checkpoint.

Hope this makes the discussion progress...

Louis

>=20
> Do we require that it be run in screen?  Then what about the
> screen session's terminals themselves?
>=20
> Anyway, I have this feeling that other have already thought
> through this, so here is the simple program for discussion:
>=20
> #include <stdio.h>
> #include <curses.h>
> #include <string.h>
>=20
> int main(int argc, char *argv[])
> {
> #define MAXLEN 20
> 	char input[MAXLEN+1];
> 	int i =3D 0;
>=20
> 	initscr();
> 	cbreak();
> 	//noecho();
> 	nonl();
> 	intrflush(stdscr, FALSE);
> 	keypad(stdscr, TRUE);
>=20
> 	addstr("Enter some text: ");
> 	memset(input, 0, MAXLEN+1);
> 	while (1) {
> 		input[i] =3D getch();
> 		if (input[i] =3D=3D KEY_ENTER || input[i]=3D=3D'\r')
> 			break;
> 		i++;
> 		if (i =3D=3D MAXLEN)
> 			break;
> 	}
> 	endwin();
> 	printf("I read the text: %s\n", input);
> 	return 0;
> }
>=20
> -serge
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-12845-1259660169-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksU48QACgkQVKcRuvQ9Q1Tj3wCgzEAAFNH4zzH6yEoiSxICUjSw
368An3UA1hHj+mYKirKzFIFkvXyEpjY4
=Z+0M
-----END PGP SIGNATURE-----

--=_bohort-12845-1259660169-0001-2--

--===============1356077486017337647==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1356077486017337647==--
