From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] [RFC][WIP] namespace.c: Allow some unprivileged proc
	mounts when not fully visible
Date: Thu, 5 Apr 2018 01:34:22 +1000
Message-ID: <20180404153422.mea4nup3ldc2q2qt__21561.5292582244$1522855984$gmane$org@gordon>
References: <20180404115311.725-1-alban@kinvolk.io>
	<87tvsrjai0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6739104547154484090=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tvsrjai0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Crosby <crosbymichael-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Stephen J Day <stephen.day-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jess Frazelle <acidburn-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============6739104547154484090==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xg6ha4rtuhb7wper"
Content-Disposition: inline


--xg6ha4rtuhb7wper
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2018-04-04, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> > The following commands show my problem:
> >
> > $ sudo docker run -ti --rm --cap-add=3DSYS_ADMIN busybox sh -c 'unshare=
 -U -r -p -m -f mount -t proc proc /home && echo ok'
> > mount: permission denied (are you root?)
> >
> > $ sudo docker run -ti --rm --cap-add=3DSYS_ADMIN busybox sh -c 'mkdir -=
p /unmasked-proc && mount -t proc proc /unmasked-proc && unshare -U -r -p -=
m -f mount -t proc proc /home && echo ok'
> > ok
>=20
> Actually this does not show your problem because it does not reveal why
> you need to mount proc.
>=20
> That is a ``Doctor it hurts when I do this'' example where the Doctor
> will reasonably tell you ``Don't do that then''.

The context is that people want to run unprivileged runc inside a Docker
container, and mounting proc is part of setting up a container. But
Docker (and runc) have masks for /proc to stop containers from being
able to touch things like /proc/scsi and so on. The other possibility is
to give people an escape-hatch when setting up a container which
basically says "make this container slightly less secure so that I can
run containers inside it".

However I share your concern about the layer mixing with inheriting the
masks for the new procfs mount (what if you have a mount over a
particular process, now the mask is masking something completely
different, and a bunch of other possible problems).

> > For my use case, I will need to support at least the following entries:
> >
> > $ sudo docker run -ti --rm busybox sh -c 'mount|grep /proc/'
> > proc on /proc/asound type proc (ro,nosuid,nodev,noexec,relatime)
> > proc on /proc/bus type proc (ro,nosuid,nodev,noexec,relatime)
> > proc on /proc/fs type proc (ro,nosuid,nodev,noexec,relatime)
> > proc on /proc/irq type proc (ro,nosuid,nodev,noexec,relatime)
> > proc on /proc/sys type proc (ro,nosuid,nodev,noexec,relatime)
> > proc on /proc/sysrq-trigger type proc (ro,nosuid,nodev,noexec,relatime)
> > tmpfs on /proc/kcore type tmpfs (rw,context=3D"...",nosuid,mode=3D755)
> > tmpfs on /proc/latency_stats type tmpfs (rw,context=3D"...",nosuid,mode=
=3D755)
> > tmpfs on /proc/timer_list type tmpfs (rw,context=3D"...",nosuid,mode=3D=
755)
> > tmpfs on /proc/sched_debug type tmpfs (rw,context=3D"...",nosuid,mode=
=3D755)
> > tmpfs on /proc/scsi type tmpfs (ro,seclabel,relatime)
>=20
> It looks like a cruft free cousin of proc that is just processes would
> be applicable to your usecase.

I think a procfs that only has processes would be a massive improvement
for a bunch of other reasons too. :D

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--xg6ha4rtuhb7wper
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAlrE8HsACgkQnhiqJn3b
jbRnow/+KccyoEV0xLBfJSPqejhSu8o8/aasXyqdJaAIM/GTI0/Xf6aT6pW4JZU/
m8IcgIKBrSDd6GmdkTE5MJ8s/Bqc5+EeDAbwfeJQeDzGFqBOXtmNvhs6YJrLG6pp
nZG7nwIsrxeKuL/yqyHNAZYpC5ii7zEe+GeEaeUf6gaxq6T5qklmDPWDS5kVRyza
4O+NpfSmd8MmOmCBNrwV90LxqdB+kso4MFAFXZzmhs9IzibpPdaBT8RWhJ8z0gCj
hZDtGHnY2gpjppgec+L35h9xHN3A1W93OVZAuzmX/JRWnRdimuv9URJlAH8k+GhW
gNIbXcoPQgDcRaSpGrimIqOiUAbNQXB0HUbsDwnmGlWWTESZ5nIVv3xftmew+QSR
M2AxI/vvii/HkvUMIgwAN8IGTzI+6ozJmT5wweDrRhKkFak88VlL7Kr+2+2yBxti
LCJmGhuqss3VEKYeXd5+43W+TEtCHE3gkAOtkU572XC25BmPxr4k446UxbUkagBk
FXPD5NbzEeASwzcVSJdvUF/hRSGztyRuSbYcBqRsxa+LUwIZSuW295Rh7EC3dpxl
eKtSMiyHnlj9Qg6AABfWo5qDI7OldL7EQmVYtW4NuXzaggh2SMqrdx+uERFcYDGE
mSFLWHc54ZN5gvuRPOtSCb5MGuVUtE3+Dtqe2AAtUk4m83CHOvc=
=0/iw
-----END PGP SIGNATURE-----

--xg6ha4rtuhb7wper--

--===============6739104547154484090==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6739104547154484090==--
