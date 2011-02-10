From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Thu, 10 Feb 2011 19:04:33 +0100
Message-ID: <20110210180433.GI6360@hawkmoon.kerlabs.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<20110209120100.GD13323@hawkmoon.kerlabs.com>
	<20110209190216.GA17051@us.ibm.com>
	<20110210102312.GC6360@hawkmoon.kerlabs.com>
	<20110210175409.GB1025@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0945278415625472791=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110210175409.GB1025-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

--===============0945278415625472791==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-27222-1297361011-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-27222-1297361011-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 10/02/11  9:54 -0800, Sukadev Bhattiprolu wrote:
> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> | > I can reproduce a crash with 2.6.32 - where if container-init termina=
tes
> | > before a detached child, we get a crash when the detached child calls
> | > proc_flush_mnt(). I suspected it was because do_wait_thread() skipped
> | > over detached tasks (in 2.6.32).
> | >=20
> | > The same test case does not crash on 2.6.37 - which includes the abov=
e commit.
> | > The removes the check for detached tasks, my initial guess is that th=
e above
> | > commit, may have contributed to _fixing_ the crash in 2.6.37.
> |=20
> | Hm, I don't see how this commit changed things for detached tasks, unle=
ss ptrace
> | is involved. Detached tasks go atomically
> | from ->exit_state =3D=3D 0 to ->exit_state =3D=3D EXIT_DEAD in exit_not=
ify(),
> | because tracehook_notify_death() returns DEATH_REAP for all not ptraced=
 detached
> | tasks.
> |=20
> | What do you think has changed precisely?
>=20
> Well, one of the changes in the commit is this:
>=20
> @@ -1551,14 +1554,9 @@ static int do_wait_thread(struct wait_opts *wo, st=
ruct task_struct *tsk)
>         struct task_struct *p;
>=20
>         list_for_each_entry(p, &tsk->children, sibling) {
> -               /*
> -                * Do not consider detached threads.
> -                */
> -               if (!task_detached(p)) {
> -                       int ret =3D wait_consider_task(wo, 0, p);
> -                       if (ret)
> -                               return ret;
> -               }
> +               int ret =3D wait_consider_task(wo, 0, p);
> +               if (ret)
> +                       return ret;
>         }
>=20
>         return 0;
>=20
> ---
> If it was a detached task, do_wait_thread() skipped over it. In the C/R
> kernel we were setting the ->exit_signal to -1 for a "ghost" process.=20
> I assumed that the container-init exited without waiting for the "ghost"
> and we were getting the crash in proc_flush_mnt() when the ghost exited.

The point is that wait_consider_task() skips detached tasks as soon as they=
 are
not ptraced. So removing the check in do_wait_thread() should not have chan=
ged
the behavior. Am I missing something?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-27222-1297361011-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1UKLEACgkQVKcRuvQ9Q1SNkwCgiTjgG/Og6/HQocy1cjR77HOJ
qXgAoLMd5imLF4rM9Z5Le2kewWEVB5uQ
=ukng
-----END PGP SIGNATURE-----

--=_bohort-27222-1297361011-0001-2--

--===============0945278415625472791==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0945278415625472791==--
