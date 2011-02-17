From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Thu, 17 Feb 2011 16:21:16 +0100
Message-ID: <20110217152116.GM518@hawkmoon.kerlabs.com>
References: <4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
	<20110210024430.GA23167@us.ibm.com>
	<4D536154.8000900@cs.columbia.edu>
	<20110210061730.GA25432@us.ibm.com>
	<4D53FC9C.1050405@cs.columbia.edu>
	<20110216201019.GA27698@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2481064873704118538=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110216201019.GA27698-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

--===============2481064873704118538==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-20377-1297956013-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-20377-1297956013-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16/02/11 12:10 -0800, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | So instead, we can call __wake_up_parent() from exit_checkpoint()
> | if indeed we are already reaped there:
> |=20
> | exit_checkpoint()
> | {
> | 	...
> | 	if (current->flags & PF_RESTARTING) {
> | 		...
> | 		/* either zombie or reaped ghost/dead */
> | 		if (current->exit_state =3D EXIT_DEAD)
> | 			__wake_up_parent(...);	  /* probably need lock */
> | 		...
> | 	}
> | 	...
> | }
> |=20
> | and to avoid userspace misuse, disallow non-thread-group-leader ghosts.
> |=20
> | ?
>=20
> Well, I don't see a problem as such, but notice one inconsistency.
>=20
> By the time the ghost task calls exit_checkpoint() it would have
> gone through release_task()/__exit_signal()/__unhash_process() so
> it is no longer on the parent's ->children list. We will be accessing
> the task's ->parent pointer after this.
>=20
> I am looking to see if anything prevents the parent from itself going
> through release_task(), after the child does the release_task() but before
> the child does the exit_checkpoint().
>=20
> In 2.6.38, I don't see specifically where a task's ->parent pointer is
> invalidated.  The task->parent and task->parent->signal are freed in the
> final __put_task_struct(). So its probably safe to access them, even if t=
he
> parent itself is exiting and has gone through release_task().
>=20
> But in 2.6.32 i.e RHEL5, tsk->signal is set to NULL in __exit_signal().
> So, I am trying to rule out the following scenario:
>=20
> 	Child (may not be a ghost)			Parent
> 	-------------------------                       ------
> - exit_notify(): is EXIT_DEAD=20
> - release_task():
> 	 - drops task_list_lock
> 	 					- itself proceeds to exit.
> 						- enters release_task()
> 						- sets own->signal =3D NULL
> 						  (in 2.6.32, __exit_signal())
>=20
> - enters exit_checkpoint()
> - __wake_up_parent()
> 	access parents->signal NULL ptr
>=20
> Not sure if holding task_list_lock here is needed or will help.

Giving my 2 cents since I've been Cc'ed.

AFAICS, holding tasklist_lock prevents __exit_signal() from setting
parent->signal to NULL in your back. So something like this should be safe:

	read_lock(&tasklist_lock);
	if (current->parent->signal)
		__wake_up_parent(...);
	read_unlock(&tasklist_lock);

I haven't looked at the context, but of course this also requires that some
get_task_struct() on current->parent has been done somewhere else before cu=
rrent
has passed __exit_signal().

By the way, instead of checking current->parent->signal,
current->parent->exit_state would look cleaner to me. current->parent is not
supposed to wait on ->wait_chldexit after calling do_exit(), right?

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-20377-1297956013-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1dPOwACgkQVKcRuvQ9Q1QkggCgl8j5pUA/d5ZWbQYCMsSwLz1R
dY4An2WS3OwjJgt1PDhpZXaWyOIEIEjd
=Grf1
-----END PGP SIGNATURE-----

--=_bohort-20377-1297956013-0001-2--

--===============2481064873704118538==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2481064873704118538==--
