From: Thadeu Lima de Souza Cascardo <cascardo-/wxwWNsM9nk+uJoB2kUjGw@public.gmane.org>
Subject: Re: cgroup mount point
Date: Mon, 2 Feb 2009 19:41:53 -0200
Message-ID: <20090202214153.GV3643__15921.0668680773$1233611160$gmane$org@vespa.holoscopio.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0135396006964608280=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090202205246.GA28593-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>
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
To: debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============0135396006964608280==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nYySOmuH/HDX6pKp"
Content-Disposition: inline


--nYySOmuH/HDX6pKp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 02, 2009 at 09:52:46PM +0100, Mike Hommey wrote:
> On Mon, Feb 02, 2009 at 09:26:11PM +0100, Julien Cristau wrote:
> > On Mon, 2009-02-02 at 18:00 -0200, Thadeu Lima de Souza Cascardo wrote:
> > > Hello,
> > >=20
> > > Some software I intend to package work with the new cgroup feature in
> > > Linux. I would like to open a discussion about what would be the bett=
er
> > > place to mount it and how/when to mount it.
> >=20
> > What do other distros use?
>=20
> Even better: what do the kernel folks want to do?
>=20
> Mike

=46rom what I've seen, most of them are in the same phases as Debian, or,
perhaps, behind. Fedora seems to plan that for Fedora 11, and they have
some support in libvirt.

Linux Documentation is not consistent and have some funny options. In
Documentation/cgroups/*, we have:

cgroups.txt:
/dev/cgroup

cpuacct.txt:
/cgroups

devices.txt:
/cgroups

memcg_test.txt:
/opt/cgroup
/opt/cpuset
/cgroup

memory.txt:
/cgroups

cpusets.txt:
/dev/cpuset

freezer-subsystem.txt:
/containers

There is also:

Documentation/scheduler/sched-design-CFS.txt:
/dev/cpuctl
/cgroup

Documentation/scheduler/sched-rt-group.txt:
/cgroup

Documentation/accounting/cgroupstats.txt:
/cgroup


So, we have some more options now: /cgroups, /containers, /dev/cpuset,
/dev/cpuctl, /opt/cgroup, /opt/cpuset.

I am copying the container and the kernel guys. Perhaps, we can find an
agreement (if we want to find one at all) and change all that
Documentation to get consistent.

Regards,
Cascardo.

--nYySOmuH/HDX6pKp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkmHaKEACgkQyTpryRcqtS0sqwCcDigmXRoVTC5Rwq6+O83uHA3O
uP0An0TonymKQRNhtkBM+GxYaIPkHPR0
=VqDr
-----END PGP SIGNATURE-----

--nYySOmuH/HDX6pKp--

--===============0135396006964608280==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0135396006964608280==--
