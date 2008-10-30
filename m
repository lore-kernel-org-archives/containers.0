From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Thu, 30 Oct 2008 12:47:47 +0100
Message-ID: <20081030114747.GL15171__12399.5517300957$1225367390$gmane$org@hawkmoon.kerlabs.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8542240801419900304=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810300902.47067.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============8542240801419900304==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-30093-1225367121-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-30093-1225367121-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 30, 2008 at 10:02:44AM +0400, Andrey Mirkin wrote:
> > > kernel. Also we will need a functionolity to create processes with
> > > predefined PID. I think it is not very good to provide such ability to
> > > user space. That is why we prefer in OpenVZ to do all the job in kern=
el.
> >
> > This is the weak side of creating the processes in user space -
> > that we need such an interface. Note, however, that we can
> > easily "hide" it inside the interface of the sys_restart() call,
> > and restrict how it may be used.
>=20
> Of course we can "hide" it somehow, but anyway we will have a hole and th=
at is=20
> not good.
>=20
> Anyway we should ask everyone what they think about user- and kernel- bas=
ed=20
> process creation.
> Dave, Serge, Cedric, Daniel, Louis what do you think about that?

Frankly, I'm not convinced (yet) that one approach is better than the other=
 one.
I only *tend* to prefer kernel-based, for the reasons explained below. I kn=
ow
that there are arguments in favor of userspace (I've at least seen
security-related ones), but I let their authors detail them (again).

In Kerrighed this is kernel-based, and will remain kernel-based because we
checkpoint a distributed task tree, and want to restart it as mush as possi=
ble
with the same distribution. The distributed protocol used for restart is
currently too fragile and complex to rely on customized user-space
implementations. That said, if someone brings very good arguments in favor =
of
userspace implementations, we might consider changing this.

Without taking distributed restart into account, I also tend to prefer
kernel-based, mainly for two (not so strong) reasons:
1) this prevents userspace from doing weird things, like changing the task =
tree
and let the kernel detect it and deal with the mess this creates (think abo=
ut
two threads being restarted in separate processes that do not even share th=
eir
parents). But one can argue that userspace can change the checkpoint image =
as
well, so that the kernel must check for such weird things anyway.
2) restart will be more efficient with respect to shared objects.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-30093-1225367121-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJCZ7jVKcRuvQ9Q1QRApKeAKCsUFFiC/RJBW7wNKKF7iPjAms5sACdG9cr
b9+Zh+eBenOil48XhDZU3ws=
=a0Rz
-----END PGP SIGNATURE-----

--=_bohort-30093-1225367121-0001-2--

--===============8542240801419900304==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8542240801419900304==--
