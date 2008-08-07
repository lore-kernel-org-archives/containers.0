From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 7 Aug 2008 11:29:43 +0200
Message-ID: <20080807092942.GO22403@hawkmoon.kerlabs.com>
References: <48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
	<1FA56146-7C30-4C36-982D-A50AA8BC8392@evergrid.com>
	<1217953429.10907.27.camel@nimitz>
	<FE4D936E-06F1-45D2-8E7C-85D87149BDC0@evergrid.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6509464505149857752=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <FE4D936E-06F1-45D2-8E7C-85D87149BDC0-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============6509464505149857752==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-4290-1218101261-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-4290-1218101261-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 06, 2008 at 09:15:46AM -0700, Joseph Ruscio wrote:
>
> On Aug 5, 2008, at 9:23 AM, Dave Hansen wrote:
>
>> On Mon, 2008-08-04 at 20:51 -0700, Joseph Ruscio wrote:
>>> It might be desirable for the checkpointing implementation to be
>>> modular enough that a userspace application or library could select =20
>>> to
>>> handle certain resources on their own. Memory is the primary one that
>>> comes to mind.
>>
>> How would you propose making it modular?
>>
>> -- Dave
>>
>
>
> Well it seems to me that the initial focus here is in live migration of=
=20
> traditional enterprise applications, e.g. databases, app-servers, etc. I=
=20
> think this is the right focus given how much utility the general=20
> enterprise is finding in capabilities like VMotion. Providing this=20
> mobility to applications without the overhead of traditional VM's would=
=20
> be very valuable.
>
> On the other hand I've been primarily focused in checkpointing large-=20
> scale MPI jobs to provide fault tolerance, and that use-case is somewhat=
=20
> different then the live-migration one. These checkpoints have huge RAM=20
> footprints (in-core checkpointing is not an option), require =20
> coordination across large numbers of servers, some number of open files =
=20
> on an enormous parallel filesystem, and some scratch files open on the=20
> local disk/ramdisk. They generally have very simple process trees with=20
> one process per core, or one process with a thread for each core.
>
> To support these kinds of jobs, one would ideally instruct the Container=
=20
> checkpointer to ignore network resources, dynamically allocated private=
=20
> memory, and the contents of open files. You'd be relying on the Container=
=20
> checkpointer to recreate processes, open file descriptors, threads,=20
> thread synchronization primitives, IPC mechanisms (including shm).
>
> As far as the mechanism is concerned, I'd defer to the more experienced=
=20
> kernel developers here. I assume that passing a bitmask of flags as an=20
> argument into the checkpoint syscall would be frowned upon, and anyways=
=20
> redundant, as its unlikely that the mask would change within a container=
=20
> from checkpoint to checkpoint. If each container is going to have a=20
> CGroup filesystem directory, then we could have a file(s) along the lines=
=20
> of /proc/sys/kernel/randomize_va_space that turn features off for that=20
> Container. The default settings after Container creation would be a=20
> complete in-kernel checkpoint/migration.

Did you think about mechanisms/interfaces making the kernel's checkpointing
sub-system and the application/run-time interact to efficiently build the
checkpoint image and restart from it?

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-4290-1218101261-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFImsCGVKcRuvQ9Q1QRAnGRAJ9vYSg4cNzPcgqb8IlLzulOkW3xNQCbBevZ
8x2RQdCQmMf/JDFLvlKf/NQ=
=IzxX
-----END PGP SIGNATURE-----

--=_bohort-4290-1218101261-0001-2--

--===============6509464505149857752==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6509464505149857752==--
