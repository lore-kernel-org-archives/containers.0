From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 7 Aug 2008 11:25:28 +0200
Message-ID: <20080807092528.GN22403@hawkmoon.kerlabs.com>
References: <20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
	<1FA56146-7C30-4C36-982D-A50AA8BC8392@evergrid.com>
	<20080805091955.GA5027@localdomain>
	<48987DE7.3060408@cs.columbia.edu>
	<3A99F254-E9B3-484B-85B0-29023ADA04C4@evergrid.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3592671256453936770=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3A99F254-E9B3-484B-85B0-29023ADA04C4-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
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
To: Joseph Ruscio <jruscio-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============3592671256453936770==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-4244-1218101006-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-4244-1218101006-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 06, 2008 at 08:41:10AM -0700, Joseph Ruscio wrote:
>
> On Aug 5, 2008, at 9:20 AM, Oren Laadan wrote:
>> Eh... and, yes, live migration :)
>
>  User-space live migration of a "batch" process e.g. one taking place in=
=20
> an MPI job is quite trivial. User-space live migration of something like=
=20
> a database is not that hard assuming you have a cooperative load =20
> balancer or proxy on the front end.

Hm, this means modifying the MPI run-time, right? Especially the ones relyi=
ng on
daemons on each node (like LAM implementation, and MPI2 specification IIRC).
Anyway, this is probably not an issue, since most high-end HPC systems come=
 with
their own customized MPI implementation.

>
> I'm not advocating for implementing this in user-space. I am in complete=
=20
> agreement that this effort should result in code that completely=20
> checkpoints a Container in the kernel. My question was whether there are=
=20
> situations where it would be advantageous for user-space to have the=20
> option of instructing/hinting the kernel to ignore certain resources that=
=20
> it would handle itself. Most of the use-cases I'm thinking of come from=
=20
> the different styles of implementations I've seen in the HPC space, where=
=20
> our implementation (and a lot of others) are focused.
>
> MPI codes require coordination between all the different processes =20
> taking part to ensure that the checkpoints are globally consistent. MPI=
=20
> implementations that run on hardware such as Infiniband would most =20
> likely want the container checkpointing to ignore all of the pinned =20
> memory associated with the RDMA operations so that the coordination and=
=20
> recreation of MPI communicator state could be handled in user-space. When=
=20
> working with inflexible process checkpointers, MPI coordination routines=
=20
> often must completely teardown all communicator state prior to invoking=
=20
> the checkpoint, and then recreate all the communicators after the=20
> checkpoint. On very large scale jobs, this is expensive.
>
> As another example HPC applications can create local scratch files of =20
> several GB in /tmp. It may not be necessary to migrate these files, but=
=20
> if user-space has no way to mark a particular file, "local files", or=20
> files in general as being ignored, then we'll have to copy these during a=
=20
> migration or a checkpoint.

Definitely agree with you here. This is the kind of use-case we will study =
in
Kerrighed. (Actually the project is centered on supporting a petaflopic
application, with help from Kerrighed to tolerate failures).

>
> I don't suppose anyone is attending Linuxworld in San Francisco this =20
> week? I'd be more then happy to grab a coffee and talk about some of =20
> this. I stopped by the OpenVZ booth but none of the devs are around.

Not me, sorry :) However, whichever requirement you can describe is interes=
ting
for us. They can surely help designing a most useful checkpoint/restart
mechanism.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-4244-1218101006-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFImr+IVKcRuvQ9Q1QRAjucAJ9V0xCqdIdL2GJ0OHEarI4FBIulpQCcCg4k
B6czx+uHOSvFjYNSwPw1S4c=
=9c31
-----END PGP SIGNATURE-----

--=_bohort-4244-1218101006-0001-2--

--===============3592671256453936770==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3592671256453936770==--
