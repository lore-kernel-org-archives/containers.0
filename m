From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Tue, 22 Feb 2011 11:28:41 +0100
Message-ID: <20110222102841.GQ518@hawkmoon.kerlabs.com>
References: <4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
	<20110210024430.GA23167@us.ibm.com>
	<4D536154.8000900@cs.columbia.edu>
	<20110210061730.GA25432@us.ibm.com>
	<4D53FC9C.1050405@cs.columbia.edu>
	<20110216201019.GA27698@us.ibm.com>
	<20110217152116.GM518@hawkmoon.kerlabs.com>
	<20110221204058.GC14377@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0808038323349966153=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110221204058.GC14377-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

--===============0808038323349966153==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-12275-1298370457-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-12275-1298370457-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 21/02/11 12:40 -0800, Sukadev Bhattiprolu wrote:
> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> | > But in 2.6.32 i.e RHEL5, tsk->signal is set to NULL in __exit_signal(=
).
> | > So, I am trying to rule out the following scenario:
> | >=20
> | > 	Child (may not be a ghost)			Parent
> | > 	-------------------------                       ------
> | > - exit_notify(): is EXIT_DEAD=20
> | > - release_task():
> | > 	 - drops task_list_lock
> | > 	 					- itself proceeds to exit.
> | > 						- enters release_task()
> | > 						- sets own->signal =3D NULL
> | > 						  (in 2.6.32, __exit_signal())
> | >=20
> | > - enters exit_checkpoint()
> | > - __wake_up_parent()
> | > 	access parents->signal NULL ptr
> | >=20
> | > Not sure if holding task_list_lock here is needed or will help.
> |=20
> | Giving my 2 cents since I've been Cc'ed.
>=20
> Thanks, appreciate the input :-)
>=20
> |=20
> | AFAICS, holding tasklist_lock prevents __exit_signal() from setting
> | parent->signal to NULL in your back. So something like this should be s=
afe:
> |=20
> | 	read_lock(&tasklist_lock);
> | 	if (current->parent->signal)
> | 		__wake_up_parent(...);
> | 	read_unlock(&tasklist_lock);
>=20
> Yes, checking the parent->signal with task_list_lock would work.
>=20
> |=20
> | I haven't looked at the context, but of course this also requires that =
some
> | get_task_struct() on current->parent has been done somewhere else befor=
e current
> | has passed __exit_signal().
> |=20
> | By the way, instead of checking current->parent->signal,
> | current->parent->exit_state would look cleaner to me. current->parent i=
s not
> | supposed to wait on ->wait_chldexit after calling do_exit(), right?
>                                                     ^^^^^^^
>=20
> Hmm, do you mean exit_notify() here ?

Right, I had forgotten zap_pid_ns_processes() ;) My point was just that once
->exit_state is set (for all threads), ->signal->wait_chldexit is not used
anymore. But I'm sure that you got it right :)

Thanks,

Louis

>=20
> If so, yes checking the exit_state is cleaner.
>=20
> If the parent's exit_state is set, then it can't be waiting for the ghost,
> so no need to wake_up_parent(). If exit state is not set, then it is safe
> to wake_up_parent() (parent->signal would not yet have been cleared for
> instance).
>=20
> The one case where a parent in do_exit() could still wait for the child i=
s=20
> the container-init which waits on wait_chldexit in do_exit() ->
> zap_pid_ns_processes() - but even in that case the __wake_up_parent()
> call would be safe.
>=20
> Sukadev
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-12275-1298370457-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1jj9kACgkQVKcRuvQ9Q1QOfQCfTntjP2U3O8l/hg8XKyfdpOLj
paYAn1DI9PavW3DL1B9D8qASrfvAkwwR
=Ue9W
-----END PGP SIGNATURE-----

--=_bohort-12275-1298370457-0001-2--

--===============0808038323349966153==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0808038323349966153==--
