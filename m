From: Scott James Remnant <scott-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] proc connector: add event for process becoming session
	leader
Date: Fri, 26 Jun 2009 13:38:51 +0100
Message-ID: <1246019931.10001.7.camel__12491.448064293$1246019990$gmane$org@quest>
References: <E1MGUmL-00036A-EE@zelda.netsplit.com>
	<20090622161909.e5706885.akpm@linux-foundation.org>
	<20090623210110.GB7931@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4951200972922323645=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090623210110.GB7931-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============4951200972922323645==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-CTfRoWWA/NCjTplhDOgz"


--=-CTfRoWWA/NCjTplhDOgz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-23 at 14:01 -0700, Matt Helsley wrote:

> On Mon, Jun 22, 2009 at 04:19:09PM -0700, Andrew Morton wrote:
> > > +	get_seq(&msg->seq, &ev->cpu);
> > > +	ktime_get_ts(&ts); /* get high res monotonic timestamp */
> > > +	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
> > > +	ev->what =3D PROC_EVENT_SID;
> > > +	ev->event_data.sid.process_pid =3D task->pid;
> >=20
> > This is a bit of a worry.  In a containerised environment, pids are not
> > unique.  Now what do we do?
>=20
> An excellent point. It's broadcast via a netlink multicast address. That
> means we'd have pids and listeners from arbitrary combinations of pid
> namespaces.
>=20
Yeah, right now that's a general problem with the netlink approach
compared to the signal approach I was using before.  Of course, it's
also non-obvious how init in the initial pid namespace should deal with
processes dying in a different pid namespace.

> One obvious but poor solution is to only send the pid of the initial
> pid namespace. Then it's not ambiguous what an event refers to. However
> it also means that the events would only be useful to tasks running
> in the initial pid namespace -- not a good solution given Scott's example
> and our desire to run things like sshd in separate pid namespaces.
>=20
> Alternatively, we may be able to split up the connector such that the
> listeners only see events from their own pid namespace. I'm not
> sure that netlink and connectors can enable this change though.
>=20
Or the netlink socket could include both the pid, and a descriptor of
the pid namespace that it is in (isn't it just a pid itself?)  That way
listeners could check the namespace is the same before carrying on.

Though that obviously leaks information you may not actually want
leaked?

Scott
--=20
Scott James Remnant
scott-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org

--=-CTfRoWWA/NCjTplhDOgz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpEwVsACgkQSnQiFMl4yK57OACfVQ8ViJZ7b+jZbZX9uGrUDbm7
j5IAn25/66V08JFiIVSD4sS+GT8iViQz
=d+9F
-----END PGP SIGNATURE-----

--=-CTfRoWWA/NCjTplhDOgz--


--===============4951200972922323645==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4951200972922323645==--
