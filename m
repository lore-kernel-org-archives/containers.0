From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Wed, 5 Aug 2009 12:20:57 +0200
Message-ID: <20090805102057.GT29252__6238.17596720091$1249467744$gmane$org@hawkmoon.kerlabs.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com>
	<20090803194555.GA10158@us.ibm.com>
	<6599ad830908041148h6d3f3e9bxfef9f3eedec0ab6d@mail.gmail.com>
	<2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
	<6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4374069383552712668=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908041228w67bc6f7fh57e28f244e1923b3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============4374069383552712668==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-24649-1249467624-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-24649-1249467624-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/08/09 12:28 -0700, Paul Menage wrote:
> On Tue, Aug 4, 2009 at 12:14 PM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > Hmm, the tasklist_lock section in fork() is entirely inside the
> > read-lock. Presumably then iterating the threadgroup list to take all
> > rwsems is safe from a race in which one thread escapes?
> >
>=20
> I think so - the write-side locking would be something like:
>=20
> again:
>   read_lock(&tasklist_lock);
>   find first not-yet-locked task t
>   while (t !=3D group_leader) {
>     if (!down_write_trylock(&t->threadgroup_stability_mutex)) {
>       get_task_struct(t);
>       read_unlock(&tasklist_lock);
>       down_write(&t->threadgroup_stability_mutex);
>       put_task_struct(t);
>       goto again;
>     }
>     t =3D t->next_thread;
>   }
>   read_unlock(&tasklist_lock);

The downside of this is teaching lockdep about this recursive locking. Not =
that
simple actually... so that such cases are currently handled using a higher-=
level
lock that prevents races in locking the whole chain (there was one such exa=
mple
for locking all vmas with KVM). IIUC, the intent here is to avoid such
higher-level lock.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-24649-1249467624-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkp5XQkACgkQVKcRuvQ9Q1Sm0wCfXbE4OFiSty/OI+C5K8txTat5
9EgAoNCJZbOv9eCNIXXibuSO+YY64Y3P
=Q8i+
-----END PGP SIGNATURE-----

--=_bohort-24649-1249467624-0001-2--

--===============4374069383552712668==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4374069383552712668==--
