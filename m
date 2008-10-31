From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Fri, 31 Oct 2008 11:37:22 +0100
Message-ID: <20081031103722.GQ15171__31223.0080635802$1225449581$gmane$org@hawkmoon.kerlabs.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
	<20081030114747.GL15171@hawkmoon.kerlabs.com>
	<4909F2B5.7040907@cs.columbia.edu>
	<20081030181418.GO15171@hawkmoon.kerlabs.com>
	<4909FDD3.5090806@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5944483822844268174=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4909FDD3.5090806-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============5944483822844268174==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-31372-1225449296-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-31372-1225449296-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 30, 2008 at 02:32:51PM -0400, Oren Laadan wrote:
>=20
>=20
> Louis Rilling wrote:
> > On Thu, Oct 30, 2008 at 01:45:25PM -0400, Oren Laadan wrote:
> >>
> >> Louis Rilling wrote:
> >>> In Kerrighed this is kernel-based, and will remain kernel-based becau=
se we
> >>> checkpoint a distributed task tree, and want to restart it as mush as=
 possible
> >>> with the same distribution. The distributed protocol used for restart=
 is
> >>> currently too fragile and complex to rely on customized user-space
> >>> implementations. That said, if someone brings very good arguments in =
favor of
> >>> userspace implementations, we might consider changing this.
> >> Zap also has distributed checkpoint which does not require strict
> >> kernel-side ordering. Do you need that because you do SSI ?
> >=20
> > Yes. Tasks from different nodes have parent-children, session leader, e=
tc.
> > relationships, and the distributed management of struct pid lifecycle i=
s a bit
> > touchy too. By the way, splitting the checkpoint image in one file for =
each task
> > helps us a lot to make restart parallel, because it is more efficient f=
or the file
> > system to handle parallel reads of different files from different nodes=
 than
> > parallel reads on a single file descriptor from different nodes.
>=20
> You can also make parallel restart work with the single stream, without
> much effort. Particularly if you store everything on the file system.

Sure we can use a single stream, since we already share file descriptors ac=
cross
nodes. But the distributed synchronization of the file pointer is costly
compared to having each node access different files. This way we push the
parallelization bottelneck down to the file system rather than in the
distributed VFS layer.

>=20
> In both cases, the limiting factor is shared resources - where one task
> cannot proceed with checkpoint because it waits for another task to first
> (re)create that resource.

We just try to avoid other bottlenecks :) And besides file descriptors, sha=
red
resources are as common as multi-threaded programs, which are not the major=
ity
of the workloads we can address.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-31372-1225449296-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJCt/iVKcRuvQ9Q1QRAmtnAKCoX1qY3l700QYYbVW4wus2bO+fpwCglCgA
3EXqpUk1uLYYsKN/HnqWfJg=
=noPP
-----END PGP SIGNATURE-----

--=_bohort-31372-1225449296-0001-2--

--===============5944483822844268174==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5944483822844268174==--
