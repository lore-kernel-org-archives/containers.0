From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Wed, 9 Feb 2011 13:01:00 +0100
Message-ID: <20110209120100.GD13323@hawkmoon.kerlabs.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3560963925425391846=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110209020942.GA5339-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

--===============3560963925425391846==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-9386-1297252799-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-9386-1297252799-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 08/02/11 18:09 -0800, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> |=20
> |=20
> | On 02/05/2011 04:40 PM, Sukadev Bhattiprolu wrote:
> | > Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | > | Suka,
> | > |=20
> | > | This patch - and the corresponding kernel patch - are wrong
> | >=20
> | > Ah, I see that now.
> | >=20
> | > But am not sure about the kernel part though. We were getting a crash
> | > reliably (with older kernels) because of the ->exit_signal =3D -1 in
> | > do_ghost_task().
> |=20
> | Are we still getting it with 2.6.37 ?
>=20
> I am not currently getting the crash on 2.6.37 - I thought it was due to
> the following commit which removed the check for task_detached() in
> do_wait_thread().
>=20
> 	commit 9cd80bbb07fcd6d4d037fad4297496d3b132ac6b
> 	Author: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 	Date:   Thu Dec 17 15:27:15 2009 -0800

I don't think that this introduced the bug. The bug triggers with EXIT_DEAD
tasks, for which wait() must ignore (see below). So, the bug looks still th=
ere
in 2.6.37.

>=20
> But if that is true, I need to investigate why Louis Rilling was getting
> the crash in Jun 2010 - which he tried to fix here:
>=20
> 	http://lkml.org/lkml/2010/6/16/295

I was getting the crash on Kerrighed, which heavily patches the 2.6.30 kern=
el.
I could reproduce it on vanilla Linux of the moment (2.6.35-rc3), but
only after introducing artificial delays in release_task().

IIRC, what triggers the crash is some exiting detached task in the
pid_namespace, which goes EXIT_DEAD, and as such cannot be reaped by
zap_pid_ns_processes()->sys_wait4(). So with some odd timing, the detached
task can call proc_flush_task() after container init does, which triggers t=
he
proc_mnt crash.

Container init                           Some detached task in the ctnr
                                         exit_notify()
						->exit_state =3D EXIT_DEAD
exit_notify()
 forget_original_parent()
  find_new_reaper()
   zap_pid_ns_processes()
    sys_wait4()
     /* cannot reap EXIT_DEAD tasks */
 /* reparents EXIT_DEAD tasks to global init */

Container reaper
release_task()
 proc_flush_task()
  pid_ns_release_proc()
                                         release_task()
                                          proc_flush_task()
                                           proc_flush_task_mnt()
                                            KABOOM

Thanks,

Louis

>=20
> Even if we are not currently not getting the crash, I think user-space
> actions can result in the container-init being unable to forcibly kill
> all its children and exit.
>=20
> Eg: if ghost tasks are pushed into a child pid namespace (by intentionally
> setting ->piddepth in usercr/restart.c), we can have a situation where the
> ghost task exits silently, the parent (i.e container-init can be left han=
ging).
>=20
> It can be argued that the incorrect changes in usercr code result in the
> application hang.
>=20
> But pid namespace is supposed to guarantee that if a container-init is
> terminated, it will take the pid namespace down. But some userspace=20
> actions can result in kill -9 of container-init leaving the container-init
> hung forever.
>=20
> | >=20
> | > One fix I was watching for was Eric Biederman's=20
> | >=20
> | > 	http://lkml.org/lkml/2010/7/12/213
> | >=20
> | > which AFAICT has not been merged yet.
> |=20
> | If we need it and it isn't in mainline (any reason why ?) then
> | we can just add it to our linux-cr tree, as a preparatory patch.
> |=20
> | >=20
> | > Was there another change to 2.6.37 that would prevent the crash ?
> |=20
> | I don't know whether *that* crash still happens in 2.6.37 -=20
> | because I still didn't test it with that kernel line back.
> | (Actually, I never experienced that crash here even with
> | earlier kernels).
>=20
> Yes, it needed some "accidental" usercr change to expose the crash :-)
>=20
> (I will try to send a patch to existing usercr and a test case to repro
> this problem)
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-9386-1297252799-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1SgfwACgkQVKcRuvQ9Q1ScJwCeMvs7VQe4yu+qNtuD0HGWmSal
dM0AoLX73YRP19ejDAnoiBcfnXYqbO/9
=XOoD
-----END PGP SIGNATURE-----

--=_bohort-9386-1297252799-0001-2--

--===============3560963925425391846==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3560963925425391846==--
