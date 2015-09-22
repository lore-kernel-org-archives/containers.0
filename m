From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: handling of supplemental groups with userns
Date: Tue, 22 Sep 2015 17:52:15 -0400
Message-ID: <20150922215215.GE27286@vapier.lan>
References: <20150922162157.GB27286@vapier.lan>
	<87d1xafdk8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8755221698703250500=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d1xafdk8.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============8755221698703250500==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="wtjvnLv0o8UUzur2"
Content-Disposition: inline


--wtjvnLv0o8UUzur2
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 22 Sep 2015 14:40, Eric W. Biederman wrote:
> Mike Frysinger writes:
> > is it possible to map in supplemental groups in a userns when the user
> > lacks setgid/etc... capabilities in the parent ns ?  it doesn't seem
> > like it's currently possible, but is there a reason to not enable it ?
>=20
> In your unprivileged use scenario, you won't be able to drop
> your supplementary groups so why do you need them mapped?
>=20
> > basically i have a build tool that i want to isolate a bit, but it
> > requires access to some of my supplemental groups.  if i map just
> > my effective uid/gid, the build will fail when it tries to use the
> > chown/chgrp commands (gets back EINVAL).
>=20
> Yes.  That really isn't valid as you are dropping groups.  Peculiarly
> enough dropping groups can be a security issue as in some permission
> checks not being a member of a group can give you enhanced access to
> files and directories.

i don't want to drop groups ... i want the exact opposite actually :).
ideally, `id` would have the same output before/after.  instead, i get
65534 for all the supplemental groups.  these commands work before i
create a new userns and i want them to keep working afterwards:
	chgrp 100 foo
	chgrp 250 foo
instead, only the first works (since that's my effective gid) and the
second fails (since i'm in that via a supplemental group).

> So to do something like what you want, you need a setuid helper (something
> like newuidmap or newgidmap) to verify that what you are doing is ok
> by local policy.

i know i can get it ahead of time if i have the caps apriori, but that's
not what i want to require.  if i had those, then i would generally be
able to simply create the namespaces directly and not bother with userns
in the first place :).

> > my scenario boils down to:
> >  - normal unprivileged user (uid=3D8282)
> >  - member of multiple groups (gid=3D100, getgroups=3D{100,16,250,...})
> >  - create a new userns (to get access to other ns like mount/pid)
> >    but still have access to existing groups where i'm root
> >  - use various features that require caps (new pidns/mntns/etc...)
> >  - create another userns and map back non-root users/groups
> > i.e. i switch from 8282 to 0, do what i need, then switch back to 8282.
>=20
> [snip]
>=20
> > in the mean time, a "quick" fix might be to change new_idmap_permitted
> > to walk all the extents, and if all the ranges are set to 1, check the
> > supplemental groups in addition to the current egid ?
>=20
> That allows dropping groups that you could not drop normally and so we
> can't allow it, by default.

if setgroups is set to deny, then it's not possible for me to drop any
groups, and therefore allowing me to map supplemental groups wouldn't be
a problem right ?
-mike

--wtjvnLv0o8UUzur2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWAc2PAAoJEEFjO5/oN/WBFlIQAKXKIvCSgIHkKyQ3nnNZRG8Z
8qtEmmaJVhUJjC9N638MRBAPnscCb7EV11vyW15NSPjGLQPW3a2evwHtO/3w+hZt
/nDQWgEPQIBhfpHNJLaPLPowUUG23Wyzzbpa2LSmSELWLWbfzUqenKvx4wlmm+XS
e1KDhRPwRcO5zvEWwHRi+fiSQQ7zo2Sven0+xuTzm9Zp132RonB3PI97KiWgr/Sx
WIQvTpCjttjye6dlyyK9ag+Kb5Pzwv3JMlCgaFubcalkOsMv/Ynzumii6VRQOBeH
8HZr839AmMjm35GuW7lb3RpEK+p66afPHyXwohS4/ZwzRlEIaoGt+Vg7QN40AX0u
Vi0SxgAbGiJ/aSxf6V2Ujl0TW3Ct4XdTFiyAA1C+HtCBFQDIrjxLJT4oPAD6a/fz
o5NaYMEsTf6OPhUiLZR1GI2Kl16CPVkPX/uGw6YkI1CpRWp8VuSFK1Xvox7beNvh
Tjhed2tYJ1WKi4eQmdG/kiGtmcyi9Hxb8U3oUJ5Pzn8QyxyVmgvNKfWdRPNel3Lu
JoFbuc9MtiBFt4SMa8ZJaW6mdk0qstG8y9WHSTcwPV+G54tX3HPchh8SYqLWrco7
RV/b5s2SmYjW/ivt53jbAJwAzgFgw6wxFAMxEwjCpKlluL3iBJntn1HRgY+ZoKBO
h2yxgI5MBrwnt/zXMA7L
=41wf
-----END PGP SIGNATURE-----

--wtjvnLv0o8UUzur2--

--===============8755221698703250500==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8755221698703250500==--
