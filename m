From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Wed, 9 Feb 2011 13:35:50 +0100
Message-ID: <20110209123550.GG13323@hawkmoon.kerlabs.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<20110209120100.GD13323@hawkmoon.kerlabs.com>
	<4D528629.7030905@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4653298784748565558=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D528629.7030905-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: biederman Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============4653298784748565558==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-9730-1297254888-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-9730-1297254888-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/02/11  7:18 -0500, Oren Laadan wrote:
>=20
>=20
> On 02/09/2011 07:01 AM, Louis Rilling wrote:
> > On 08/02/11 18:09 -0800, Sukadev Bhattiprolu wrote:
> >> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> >> |=20
> >> |=20
> >> | On 02/05/2011 04:40 PM, Sukadev Bhattiprolu wrote:
> >> | > Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> >> | > | Suka,
> >> | > |=20
> >> | > | This patch - and the corresponding kernel patch - are wrong
> >> | >=20
> >> | > Ah, I see that now.
> >> | >=20
> >> | > But am not sure about the kernel part though. We were getting a cr=
ash
> >> | > reliably (with older kernels) because of the ->exit_signal =3D -1 =
in
> >> | > do_ghost_task().
> >> |=20
> >> | Are we still getting it with 2.6.37 ?
> >>
> >> I am not currently getting the crash on 2.6.37 - I thought it was due =
to
> >> the following commit which removed the check for task_detached() in
> >> do_wait_thread().
> >>
> >> 	commit 9cd80bbb07fcd6d4d037fad4297496d3b132ac6b
> >> 	Author: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> 	Date:   Thu Dec 17 15:27:15 2009 -0800
> >=20
> > I don't think that this introduced the bug. The bug triggers with EXIT_=
DEAD
> > tasks, for which wait() must ignore (see below). So, the bug looks stil=
l there
> > in 2.6.37.
> >=20
> >>
> >> But if that is true, I need to investigate why Louis Rilling was getti=
ng
> >> the crash in Jun 2010 - which he tried to fix here:
> >>
> >> 	http://lkml.org/lkml/2010/6/16/295
> >=20
> > I was getting the crash on Kerrighed, which heavily patches the 2.6.30 =
kernel.
> > I could reproduce it on vanilla Linux of the moment (2.6.35-rc3), but
> > only after introducing artificial delays in release_task().
> >=20
> > IIRC, what triggers the crash is some exiting detached task in the
> > pid_namespace, which goes EXIT_DEAD, and as such cannot be reaped by
> > zap_pid_ns_processes()->sys_wait4(). So with some odd timing, the detac=
hed
> > task can call proc_flush_task() after container init does, which trigge=
rs the
> > proc_mnt crash.
> >=20
> > Container init                           Some detached task in the ctnr
> >                                          exit_notify()
> > 						->exit_state =3D EXIT_DEAD
> > exit_notify()
> >  forget_original_parent()
> >   find_new_reaper()
> >    zap_pid_ns_processes()
> >     sys_wait4()
> >      /* cannot reap EXIT_DEAD tasks */
> >  /* reparents EXIT_DEAD tasks to global init */
> >=20
> > Container reaper
> > release_task()
> >  proc_flush_task()
> >   pid_ns_release_proc()
> >                                          release_task()
> >                                           proc_flush_task()
> >                                            proc_flush_task_mnt()
> >                                             KABOOM
>=20
> Louis, thanks for the explanation, and two follow-up questions:
>=20
> 1) Is there a patch circulating for this ?  or even better, on the
> way to mainline ?

We finally agreed on a patch from Eric, but for some unknown reason, it has=
 not
been finalized(?) and routed to mainline yet.

https://lkml.org/lkml/2010/7/12/213

>=20
> 2) Would it suffice if the c/r code ensures that the init never
> exits before any EXIT_DEAD tasks ?

That's what Eric's patch does: make zap_pid_ns_processes() wait until all o=
ther
tasks (EXIT_DEAD or whatever) have passed
release_task()->__exit_signal()->__unhash_process().

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-9730-1297254888-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1SiiYACgkQVKcRuvQ9Q1SXqQCfc0t0DQCqAyg4mi2PufW7FyDn
WPcAnRLe6Z4eWLVusgPl2UVmNGt0HCw/
=Tlhi
-----END PGP SIGNATURE-----

--=_bohort-9730-1297254888-0001-2--

--===============4653298784748565558==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4653298784748565558==--
