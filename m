From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Thu, 30 Oct 2008 19:14:18 +0100
Message-ID: <20081030181418.GO15171@hawkmoon.kerlabs.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
	<20081030114747.GL15171@hawkmoon.kerlabs.com>
	<4909F2B5.7040907@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8497030011756010126=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4909F2B5.7040907-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

--===============8497030011756010126==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-8888-1225390312-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-8888-1225390312-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 30, 2008 at 01:45:25PM -0400, Oren Laadan wrote:
>=20
>=20
> Louis Rilling wrote:
> > In Kerrighed this is kernel-based, and will remain kernel-based because=
 we
> > checkpoint a distributed task tree, and want to restart it as mush as p=
ossible
> > with the same distribution. The distributed protocol used for restart is
> > currently too fragile and complex to rely on customized user-space
> > implementations. That said, if someone brings very good arguments in fa=
vor of
> > userspace implementations, we might consider changing this.
>=20
> Zap also has distributed checkpoint which does not require strict
> kernel-side ordering. Do you need that because you do SSI ?

Yes. Tasks from different nodes have parent-children, session leader, etc.
relationships, and the distributed management of struct pid lifecycle is a =
bit
touchy too. By the way, splitting the checkpoint image in one file for each=
 task
helps us a lot to make restart parallel, because it is more efficient for t=
he file
system to handle parallel reads of different files from different nodes than
parallel reads on a single file descriptor from different nodes.

>=20
> >=20
> > Without taking distributed restart into account, I also tend to prefer
> > kernel-based, mainly for two (not so strong) reasons:
> > 1) this prevents userspace from doing weird things, like changing the t=
ask tree
> > and let the kernel detect it and deal with the mess this creates (think=
 about
> > two threads being restarted in separate processes that do not even shar=
e their
> > parents). But one can argue that userspace can change the checkpoint im=
age as
> > well, so that the kernel must check for such weird things anyway.
>=20
> I don't really buy this argument. First, as you say, user can change
> the checkpoint image file. Second, you can verify in the kernel that
> the real relationships of the processes match those specified (and
> expected from) the image file. That's pretty straightforward.
>=20
> > 2) restart will be more efficient with respect to shared objects.
>=20
> Can you elaborate on this ?  In what sense "more efficient" ?
>=20
> Note that the topic in question is not whether to do the entire restart
> from user space (and I argue that most work should be done in the kernel),
> but rather whether process creation (and only that) should be done in
> kernel or user space.

See my answer to Dave.

>=20
> Quick thoughts of pros/cons of each approach are:
>=20
> user space:
>=20
> + re-use existing api (fork)
> + easier to debug
> + will allow 'handmade' resources restart: it was mentioned before that
>   one may want to reattach stdout to a different place after restart; a
>   user based restart of processes can make this much easier: e.g. the
>   user process can create the alternative resources, give them to the
>   kernel and only then call sys_restart)
> + arch-independent code
>=20
> - a bit slower than in kernel space
> - requires a clone-with-specific-pid syscall or interface
>=20
> kernel space:
>=20
> + a bit easier to control everything
> + a bit faster than user space
> + no need for user-visible interface for clone-with-...
>=20
> - arch-dependent code
> - needs special code to fight 'fork-bomb'
>=20
> So, I'm not convinced, and I even think there may be room to both, for
> the time being. I volunteer to support the user-space alternative while
> we make up our minds.

Yes, I hope that investigating both approaches will give us stronger argume=
nts.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-8888-1225390312-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJCfl6VKcRuvQ9Q1QRAuh1AJ40VfXrWVLGyDNob1doxP25r1juBwCfeoE/
fvoTg6R2vmuMbvCFkQnMsKQ=
=8jwl
-----END PGP SIGNATURE-----

--=_bohort-8888-1225390312-0001-2--

--===============8497030011756010126==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8497030011756010126==--
