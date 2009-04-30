From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Thu, 30 Apr 2009 11:41:06 +0200
Message-ID: <20090430094106.GC13896@hawkmoon.kerlabs.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
	<49F8D8FC.8010400@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1195000496241945978=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49F8D8FC.8010400-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============1195000496241945978==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-2782-1241084454-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-2782-1241084454-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 29/04/09 18:47 -0400, Oren Laadan wrote:
> Hi Louis,
>=20
> Louis Rilling wrote:
> > Hi,
> >=20
> > On 28/04/09 19:23 -0400, Oren Laadan wrote:
> >> Here is the latest and greatest of checkpoint/restart (c/r) patchset.
> >> The logic and image format reworked and simplified, code refactored,
> >> support for PPC, s390, sysvipc, shared memory of all sorts, namespaces
> >> (uts and ipc).
> >=20
> > I should have asked before, but what are the reasons to checkpoint SYSV=
 IPCs
> > in the same file/stream as tasks? Would it be better to checkpoint them
> > independently, like the file system state?
> >=20
> > In Kerrighed we chose to checkpoint SYSV IPCs independently, a bit like=
 the file
> > system state, because SYSV IPCs objects' lifetime do not depend on tasks
> > lifetime, and we can gain more flexibility this way. In particular we e=
nvision
> > cases in which two applications share a state in a SYSV SHM (something =
like a
> > producer-consumer scheme), but do not need to be checkpointed together.=
 In such
> > a case the SYSV SHM itself could even need more high-availability (using
> > active replication) than a checkpoint/restart facility.
> >=20
>=20
> Thanks for the feedback, this is actually an interesting idea.
>=20
> Indeed in the past I also considered SYSV IPC to be a "global" resource
> that was checkpointed before iterating through the tasks.
>=20
> However, in the presence of namespaces, the lifetime of an IPC namespace
> does depend on on tasks lifetime - when the last task referring to a
> given namespace exits - that namespace is destroyed. Of course, the
> root namespace is truly global, because init(1) never exits.
>=20
> What would 'checkpoint them independently' mean in this case ?

I mean that the producer and the consumer could have separate checkpointing
policies (if any), and the IPC SHM as well.

>=20
> In your use-case, can you restart either application without first
> restoring the relevant SYSVIPC ?

Probably not.

>=20
> Can you think of other use-cases for such a division ?  Am I right to
> guess that your use case is specific to the distributed (and SSI-)
> nature of your system ?  (Active-replication of SYSV_SHM sounds
> awfully related to DSM :)

The case of active-replication may be specific to DSM-based systems, but the
case of independent policies is already interesting in standalone boxes.

>=20
>=20
> While not focusing on such use cases, I want to keep the design flexible
> enough to not exclude them a-priori, and be able to address them later
> on. Indeed, the code is split such that the the function to save a given
> IPC namespace does not depend on the task that uses it. Future code
> could easily use the same functionality.
>=20
> One way to be flexible to support your use case, is by having some
> mechanism in place to select whether a resource (virtually any) is
> to be chekcpointed/restored.
>=20
> For example, you could imagine checkpoint(..., CHECKPOINT_SYSVIPC)
> to checkpoint (also) IPC, and not checkpoint IPC in its absence.
>=20
> So normally you'd have checkpoint(..., CHECKPOINT_ALL). When you don't
> want IPC, you'd use CHECKPOINT_ALL & ~CHECKPOINT_SYSVIPC. When you
> want only IPC, you'd use CHECKPOINT_SYSVIPC only.
>=20
> Same thing for restart, only that it will get trickier in the "only IPC"
> case, since you will need to tell which IPC namespace is affected.
>=20
> Also, I envision a task saying cradvise(CHECKPOINT_SYSVIPC, false),
> telling the kernel to not c/r its IPC namespace. (Or any other
> resource). Again there would need to be a way to add a restored
> namespace.
>=20
> Does this address your concerns ?

Yes this sounds flexible enough. Thanks for=A0taking this into account.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-2782-1241084454-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJ+XIyVKcRuvQ9Q1QRAjk0AJ4wdlBNqypc5zd+XKossf7Z3cEGsQCgqHJI
9PDE13csaarGHmoRIHNohEI=
=0N7O
-----END PGP SIGNATURE-----

--=_bohort-2782-1241084454-0001-2--

--===============1195000496241945978==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1195000496241945978==--
