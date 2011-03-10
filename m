From: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH] Documentation: cgroups: Add notes on removing PIDs
	from tasks and cgroups requiring setup
Date: Thu, 10 Mar 2011 11:59:12 -0500
Message-ID: <20110310165911.GA4911__25926.1673935272$1299776397$gmane$org@mgebm.net>
References: <1299704969-4485-1-git-send-email-emunson@mgebm.net>
	<AANLkTinW99M1FBp5gRA=+SsjUWSJBwByurqrsjXKgQ4=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2373501513376125102=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinW99M1FBp5gRA=+SsjUWSJBwByurqrsjXKgQ4=@mail.gmail.com>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============2373501513376125102==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="45Z9DzgjV8m4Oswq"
Content-Disposition: inline


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 09 Mar 2011, Paul Menage wrote:

> On Wed, Mar 9, 2011 at 1:09 PM, Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org> wrote:
> >
> > +Note: To remove a task from a cgroup you must write its PID to the root
> > +tasks file.
> > +
>=20
> This isn't really accurate - the root cgroup is a cgroup like all the
> others. More accurate would be something like:
>=20
> Since every task is always a member of exactly one cgroup in each
> mounted hierarchy, to remove a task from its current cgroup you must
> move it into a new cgroup (possibly the root cgroup) by writing to the
> new cgroup's tasks file.
>=20
> Paul
>=20

I am going to lift that for V2.

--45Z9DzgjV8m4Oswq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNeQNfAAoJEH65iIruGRnNuxsIAIXMHywzVAuCywb3SOLhXTXJ
r/0Z+t6Tlmy1mSh701GU+t2TPl/Cr4UwN0xHmBVtBGBUFKXzXibmatsVLavD/r5K
Zjosn5nhKpwiXH0RmWSiGlCLgr6qkhUpRuujOnf993+81omUjCfLfLUzbaS9p5FD
4taE8seaUUUoZromdh1mtEwIR9gdYtKG1obuCCuhaI4R+esHMVS/kMQYHt0zxEhW
8o1lvQV5xvGDpYrluj+hAquU+7l0fhmHsHMQhv96fq/X24puEB7K1yxgBMg+vwr2
i7KNBDPdXwsZdFXJRC/C2LCN0iK1pkA7EfMPi0Cg/tjv1hr9fyZgtYZp6Lw3Nqk=
=dAUN
-----END PGP SIGNATURE-----

--45Z9DzgjV8m4Oswq--

--===============2373501513376125102==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2373501513376125102==--
