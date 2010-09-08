From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: C/R and stdio redirection
Date: Wed, 8 Sep 2010 10:41:52 +0200
Message-ID: <20100908084152.GC4812@hawkmoon.kerlabs.com>
References: <20100907200326.GA22256@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8056803412480862162=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100907200326.GA22256-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============8056803412480862162==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-25034-1283935287-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-25034-1283935287-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 07/09/10 13:03 -0700, Sukadev Bhattiprolu wrote:
>=20
> Suppose we create a container and redirect its stdout/stderr as follows:
>=20
> 	lxc-execute -name foo -- /path/to/app > /tmp/xyz.out 2>&1
>=20
> If we attempt to checkpoint the container 'foo', we fail bc one of the
> fds in the application refers to /tmp/xyz.out, which is also in use
> outside the container (specifically sys_checkpoint() fails due to the
> "alien mount ns" check in ckpt_fill_fname()).
>=20
> It can be argued, 'foo' is not a strict container (since it shares the
> fd with another container).  For this reason, we currently need the
> CHECKPOINT_SUBTREE flag in lxc-checkpoint.
>=20
> We initially thought that solving mount-namespaces will solve this, but
> realized that they are both separate problems. Mount-namespace C/R addres=
ses
> preserving the mounts within the container and /tmp/xyz.out is outside
> the container.
>=20
> So if an application container needs to redirect stdio as above, we should
> either=20
> 	a) disable/ignore the alien-mount-ns check or=20
>=20
> 	b) try and start the application something like:
>=20
> 		$ cat /tmp/wrapper
> 		/path/to/app > /tmp/xyz.out 2>&1
>=20
> 		$ lxc-execute --name foo --  /tmp/wrapper
>=20
> with the difference being /tmp/xyz.out is now inside the container's /tmp
> filesystem rather than in the parent container.
>=20
> Maybe we can go with approach 'a' above only if CHECKPOINT_SUBTREE is also
> set - we had discussed this before and considered it hacky.
>=20
> Or are there other solutions to this stdio redirection issue ?

I think that this should be solved by a file substitution facility combined=
 with
an ability to ignore "unsupported files" at checkpoint.
File substitution is the ability to tell sys_restart() to substitute some of
caller's file descriptors to checkpointed file descriptors.
Ignoring "unsupported files" means that the checkpoint could record that a =
given
file descriptor was shared by some files_struct, but the file descriptor it=
self
is not checkpointed because of various reasons, like file descriptor outside
the container, unsupported file systems, etc.

Both of those mechanisms have been developed in Kerrighed, and Matthieu (in=
 Cc)
should start a discussion about this in the next weeks.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-25034-1283935287-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkyHTFAACgkQVKcRuvQ9Q1TIMgCg1aDUDm3+Z8vILdhkD8MksmVI
mKsAn3qUilXzhvQhasxR2nIeCddlv//j
=7U9J
-----END PGP SIGNATURE-----

--=_bohort-25034-1283935287-0001-2--

--===============8056803412480862162==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8056803412480862162==--
