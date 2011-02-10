From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Thu, 10 Feb 2011 11:23:12 +0100
Message-ID: <20110210102312.GC6360@hawkmoon.kerlabs.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<20110209120100.GD13323@hawkmoon.kerlabs.com>
	<20110209190216.GA17051@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7989368327772939654=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110209190216.GA17051-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============7989368327772939654==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-21952-1297333330-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-21952-1297333330-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/02/11 11:02 -0800, Sukadev Bhattiprolu wrote:
> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> | > | Are we still getting it with 2.6.37 ?
> | >=20
> | > I am not currently getting the crash on 2.6.37 - I thought it was due=
 to
> | > the following commit which removed the check for task_detached() in
> | > do_wait_thread().
> | >=20
> | > 	commit 9cd80bbb07fcd6d4d037fad4297496d3b132ac6b
> | > 	Author: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> | > 	Date:   Thu Dec 17 15:27:15 2009 -0800
> |=20
> | I don't think that this introduced the bug. The bug triggers with EXIT_=
DEAD
> | tasks, for which wait() must ignore (see below). So, the bug looks stil=
l there
> | in 2.6.37.
>=20
> Sorry, I did not mean to imply that the above commit caused the crash
> you saw in Jun 2010.
>=20
> I can reproduce a crash with 2.6.32 - where if container-init terminates
> before a detached child, we get a crash when the detached child calls
> proc_flush_mnt(). I suspected it was because do_wait_thread() skipped
> over detached tasks (in 2.6.32).
>=20
> The same test case does not crash on 2.6.37 - which includes the above co=
mmit.
> The removes the check for detached tasks, my initial guess is that the ab=
ove
> commit, may have contributed to _fixing_ the crash in 2.6.37.

Hm, I don't see how this commit changed things for detached tasks, unless p=
trace
is involved. Detached tasks go atomically
=66rom ->exit_state =3D=3D 0 to ->exit_state =3D=3D EXIT_DEAD in exit_notif=
y(),
because tracehook_notify_death() returns DEATH_REAP for all not ptraced det=
ached
tasks.

What do you think has changed precisely?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-21952-1297333330-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1TvJAACgkQVKcRuvQ9Q1TF/gCeJoRe58ws1GthObqFGyJ8OdWi
A3gAnj1KyBk79p6Kyrs0U4wJNLHGqiwg
=zgPS
-----END PGP SIGNATURE-----

--=_bohort-21952-1297333330-0001-2--

--===============7989368327772939654==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7989368327772939654==--
