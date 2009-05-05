From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Tue, 5 May 2009 16:26:33 +0200
Message-ID: <20090505142633.GB25550@hawkmoon.kerlabs.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
	<49F8D8FC.8010400@cs.columbia.edu> <49FEB01B.208@cs.columbia.edu>
	<20090504130108.GA21521@us.ibm.com>
	<20090505082057.GA11377@hawkmoon.kerlabs.com>
	<20090505134920.GB10136@us.ibm.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6284037409764672015=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090505134920.GB10136-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

--===============6284037409764672015==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-16845-1241533579-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-16845-1241533579-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 05/05/09  8:49 -0500, Serge E. Hallyn wrote:
> Quoting Louis Rilling (Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> > On 04/05/09  8:01 -0500, Serge E. Hallyn wrote:
> > > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > > > > I see one drawback with this approach if you allow checkpoint of
> > > > > application that is not isolated in a container. In that case, yo=
u may
> > > > > want to select which IPC objects to dump to not dump all the IPC =
objects
> > > > > living in the system. Indeed, this is why we have chosen in Kerri=
ghed to
> > > > > checkpoint IPC objects independently of tasks, since we have no
> > > > > container/namespaces support currently.
> > > >=20
> > > > I assume that in this case it will be the application itself that
> > > > will somehow tell the system which specific sysvipc objects (ids) it
> > > > cares about.
> > > >=20
> > > > (I'm not sure how would the system otherwise know what to dump and
> > > > what to leave out).
> > > >=20
> > > > I originally proposed the construct of cradvise() syscall to handle
> > > > exactly those cases where the application would like to advise the
> > > > kernel about certain resources. So, extending the previous example,
> > > > a task may call something like:
> > > >=20
> > > >    cradvise(CHECKPOINT_SYSVIPC_SHM, false);  /* generally skip shm =
*/
> > > >    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, true);  /* but include th=
is */
> > > >=20
> > > > or:
> > > >    cradvise(CHECKPOINT_SYSVIPC_SHM, true);  /* generally include sh=
m */
> > > >    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, false);  /* but skip this=
 */
> > > >=20
> > > > Anyway, these are just examples of the concept and what sort of gen=
eric
> > > > interface can be used to implement it; don't pick on the details...
> > > >=20
> > > > Oren.
> > >=20
> > > Oren, I have to be honest:  I could of course be wrong, but imo there
> > > is 0 chance of such a bigger-and-uglier-than-ioctl syscall as cradvise
> > > being accepted upstream.  There may be good uses for it, but I think
> > > it's worthwhile thinking of ways around it whenever possible.
> > >=20
> > > In this particular case, wouldn't it be better to do something like:
> > >=20
> > > 	1. freeze + checkpoint full application + container (=3D=3D C1)
> > > 	2. continue application, which does a clone(CLONE_COPYIPC) (*1)
> > > 	3. application removes all shms except the one to be
> > > 	checkpointed
> > > 	4. freeze + checkpoint application again ( =3D=3D C2)
> > > 	5. restart applicaiton from C1
> > >=20
> >=20
> > Besides COW issues mentioned by Oren in his reply, this approach does n=
ot
> > seem to provide the required flexibility. The point is to avoid checkpo=
inting
> > some IPC objects together with the application,
>=20
> ... avoided at step 3 ...
>=20
> > but we still need those IPC
> > objects, and the application still uses them.
>=20
> ... step 5 ...

But this involves changing the application. What I describe requires that t=
he
application is not changed (that is checkpoint/restart is transparent). The
actual policy is handled by some helper configured by sysadmin for instance.

>=20
> > Moreover, on restart the
> > administrator should be able to first install the required IPC objects,=
 e.g.
> > re-create them from scratch, or restore them from another checkpoint, a=
nd second
> > restart the application, linking it to the previously
> > re-created/restored/whatever SHMs.
>=20
> Of course he can do that.
>=20
> Anyway I'm not setting off to implement the clone(COPY_IPC)
> functionality, and Oren might be right that cradvise would
> be deemed different from ioctl.  I just thought I'd give a
> warning, and (being a productive type :) give an alternative...

Sure, I never doubted of the positiveness of your reply :) I just pointed
out that this alternative may not be acceptable.

>=20
> By the way, another alternative to all of the cr_advise()
> stuff is to have userspace programs carve up your checkpoint
> images.  It's been talked about before, but I believe Nathan
> in particular is worried about what this says about kernel-user
> API.

With large IPC SHMs, as a user I wouldn't like paying the price of
checkpointing them if I do not need it.

If an approach =E0 la cr_advise() still looks too close to ioctl(), I would=
 argue
in favor of implementing as many syscalls as needed to "cleanly" obtain the=
 same
flexibility.

To me cr_advise() looks closer to fcntl() or prctl() than to ioctl(). There=
 are
not so many types of objects for which optional checkpoint should be consid=
ered
(at least not as many as device types that could be invented), and the set =
of
advices for a given object will probably be limited to {CHECKPOINT,
DO_NOT_CHECKPOINT} for checkpoint, and {RESTART, REPLACE_WITH} for restart.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-16845-1241533579-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFKAEyZVKcRuvQ9Q1QRAlYqAKCn97a+OxFZdUABOlH3gP6tiUjwkQCePBJm
ZjgYt4VATz9slE0Hkx8qPng=
=/nnY
-----END PGP SIGNATURE-----

--=_bohort-16845-1241533579-0001-2--

--===============6284037409764672015==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6284037409764672015==--
