From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Tue, 5 May 2009 10:20:57 +0200
Message-ID: <20090505082057.GA11377@hawkmoon.kerlabs.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
	<49F8D8FC.8010400@cs.columbia.edu> <49FEB01B.208@cs.columbia.edu>
	<20090504130108.GA21521@us.ibm.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3042721983614682693=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090504130108.GA21521-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matthieu =?iso-8859-1?Q?Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============3042721983614682693==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-4482-1241511646-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-4482-1241511646-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/05/09  8:01 -0500, Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > > I see one drawback with this approach if you allow checkpoint of
> > > application that is not isolated in a container. In that case, you may
> > > want to select which IPC objects to dump to not dump all the IPC obje=
cts
> > > living in the system. Indeed, this is why we have chosen in Kerrighed=
 to
> > > checkpoint IPC objects independently of tasks, since we have no
> > > container/namespaces support currently.
> >=20
> > I assume that in this case it will be the application itself that
> > will somehow tell the system which specific sysvipc objects (ids) it
> > cares about.
> >=20
> > (I'm not sure how would the system otherwise know what to dump and
> > what to leave out).
> >=20
> > I originally proposed the construct of cradvise() syscall to handle
> > exactly those cases where the application would like to advise the
> > kernel about certain resources. So, extending the previous example,
> > a task may call something like:
> >=20
> >    cradvise(CHECKPOINT_SYSVIPC_SHM, false);  /* generally skip shm */
> >    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, true);  /* but include this */
> >=20
> > or:
> >    cradvise(CHECKPOINT_SYSVIPC_SHM, true);  /* generally include shm */
> >    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, false);  /* but skip this */
> >=20
> > Anyway, these are just examples of the concept and what sort of generic
> > interface can be used to implement it; don't pick on the details...
> >=20
> > Oren.
>=20
> Oren, I have to be honest:  I could of course be wrong, but imo there
> is 0 chance of such a bigger-and-uglier-than-ioctl syscall as cradvise
> being accepted upstream.  There may be good uses for it, but I think
> it's worthwhile thinking of ways around it whenever possible.
>=20
> In this particular case, wouldn't it be better to do something like:
>=20
> 	1. freeze + checkpoint full application + container (=3D=3D C1)
> 	2. continue application, which does a clone(CLONE_COPYIPC) (*1)
> 	3. application removes all shms except the one to be
> 	checkpointed
> 	4. freeze + checkpoint application again ( =3D=3D C2)
> 	5. restart applicaiton from C1
>=20

Besides COW issues mentioned by Oren in his reply, this approach does not
seem to provide the required flexibility. The point is to avoid checkpointi=
ng
some IPC objects together with the application, but we still need those IPC
objects, and the application still uses them. Moreover, on restart the
administrator should be able to first install the required IPC objects, e.g.
re-create them from scratch, or restore them from another checkpoint, and s=
econd
restart the application, linking it to the previously
re-created/restored/whatever SHMs.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-4482-1241511646-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJ//bpVKcRuvQ9Q1QRAvPNAKCUYd9hNkXI65e+9/T6i9UOwEHOjwCguRUO
yZSMErdGLydUfvYvtrpGpYQ=
=87ow
-----END PGP SIGNATURE-----

--=_bohort-4482-1241511646-0001-2--

--===============3042721983614682693==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3042721983614682693==--
