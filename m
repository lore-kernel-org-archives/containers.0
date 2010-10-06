From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: C/R and stdio redirection
Date: Wed, 6 Oct 2010 11:58:35 +0200
Message-ID: <20101006095835.GC30415@hawkmoon.kerlabs.com>
References: <20100907200326.GA22256@us.ibm.com>
	<1283939092.32527.67.camel@bahia>
	<20101006055017.GA22969@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1594106216338261984=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101006055017.GA22969-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============1594106216338261984==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-14675-1286359084-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-14675-1286359084-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 05/10/10 22:50 -0700, Sukadev Bhattiprolu wrote:
> Greg Kurz [gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
> | On Tue, 2010-09-07 at 13:03 -0700, Sukadev Bhattiprolu wrote:
> | > Suppose we create a container and redirect its stdout/stderr as follo=
ws:
> | >=20
> | > 	lxc-execute -name foo -- /path/to/app > /tmp/xyz.out 2>&1
> | >=20
> | > If we attempt to checkpoint the container 'foo', we fail bc one of the
> | > fds in the application refers to /tmp/xyz.out, which is also in use
> | > outside the container (specifically sys_checkpoint() fails due to the
> | > "alien mount ns" check in ckpt_fill_fname()).
> | >=20
> | > It can be argued, 'foo' is not a strict container (since it shares the
> | > fd with another container).  For this reason, we currently need the
> | > CHECKPOINT_SUBTREE flag in lxc-checkpoint.
> | >=20
> | > We initially thought that solving mount-namespaces will solve this, b=
ut
> | > realized that they are both separate problems. Mount-namespace C/R ad=
dresses
> | > preserving the mounts within the container and /tmp/xyz.out is outside
> | > the container.
> | >=20
> | > So if an application container needs to redirect stdio as above, we s=
hould
> | > either=20
> | > 	a) disable/ignore the alien-mount-ns check or=20
> | >=20
> | > 	b) try and start the application something like:
> | >=20
> | > 		$ cat /tmp/wrapper
> | > 		/path/to/app > /tmp/xyz.out 2>&1
> | >=20
> | > 		$ lxc-execute --name foo --  /tmp/wrapper
> | >=20
> | > with the difference being /tmp/xyz.out is now inside the container's =
/tmp
> | > filesystem rather than in the parent container.
> | >=20
> | > Maybe we can go with approach 'a' above only if CHECKPOINT_SUBTREE is=
 also
> | > set - we had discussed this before and considered it hacky.
> | >=20
> | > Or are there other solutions to this stdio redirection issue ?
> | >=20
> |=20
> | To be more accurate, this issue is about fd leaking from a parent
> | container to its descendants. The fd numbers may be anything else than
> | 0,1 or 2 and the underlying files may be regular files, pipes,
> | sockets... For example, in the HPC world, stdio are often sockets
> | inheritated from a rshd like daemon.
>=20
> I agree that fd substitution is the right way to go.
>=20
> However, Matt Helsley and I were discussing this and wondered if we should
> ignore the redirection and expect to user to specify it during restart.
>=20
> i.e if container was created like this:
>=20
> 	lxc-execute -name foo -- /path/to/app > /tmp/xyz.out 2>&1
>=20
> and checkpointed, can we expect the user to restart it like this ?
>=20
> 	lxc-restart --name foo --statefile ckpt.img >> /tmp/xyz.out=20
>=20
> i.e user has to redo the redirection or the output would go to stdout.
>=20
> Doing this would somehow seem to match a (bogus container) like:
>=20
> 	lxc-execute --name foo -- /path/to/app | sort
>=20
> If this container is checkpointed/restarted, we can't really redirect
> the output of the app to 'sort' right ? So expecting the user to
> redo the redirection on restart would treat both redirections ('>'
> and '|') in a consistent way ?

=46rom the fd substitution point of view, this means that lxc-restart would
automatically request the substitution of its stdout to the checkpointed
container init's stdout?

This sounds reasonable to me at least. Especially since the container is us=
ually
not supposed to know where the host is redirecting its stdout.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-14675-1286359084-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkysSEsACgkQVKcRuvQ9Q1SadwCfVsKk7Zxl+DL2R9QC0Q+6EHB7
67AAoLATIMH8dL7dsiuAo88wq2WMvjj3
=eaMI
-----END PGP SIGNATURE-----

--=_bohort-14675-1286359084-0001-2--

--===============1594106216338261984==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1594106216338261984==--
