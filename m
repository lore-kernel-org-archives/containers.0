From: "Michael H. Warfield" <mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org>
Subject: Mount remount operations propagating from container to host and
	other containers.
Date: Thu, 01 Apr 2010 09:40:48 -0400
Message-ID: <1270129248.7564.43.camel@localhost>
Reply-To: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7069565533024407831=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: containers-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


--===============7069565533024407831==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-n8G6hgQxLouuPZfvT8Nv"


--=-n8G6hgQxLouuPZfvT8Nv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hey all,

Been running into an ugly situation with LXC-Tools that seems to be
pointing up a real serious leakage from containers.  If you have a mount
inside a container (presumably a bind mount in this case), if the
container does a mount -o remount (say rw->ro or ro->rw) this propagates
to the host mount points (all the way to the primary mount point for
that partition in some cases) and is reflected in other containers.

This first show up with containers running full VM's running on a
mounted fs (aot the host / fs) were causing the real mounted fs to
become ro when they were shut down (the VM was remounting its rootfs as
ro and it was leaking out of the container).

I've since confirmed that and encountered it trying to have a shared ro
mounted fs in a container using bind mounts (bind mounts since 2.6.26
have allowed setting the ro flag on individual mount points) and
discovering that one container could make it rw and then all the other
containers would see it as rw as well!  If a container made a mount
point ro, all the other containers would see it as ro and the mount
point for the entire real fs in the host would become ro!  This is very
not good.  That's a pretty serious leakage from the containers out to
the host.

Is this a problem with the container isolation or some problem in
creating the container?

I'm running and testing on a Fedora 12 system with a 2.6.32 kernel.  Not
related (I don't think) but I have also noted that linux-utils-ng on F16
seems to also have a bug irt something similar here.  If I mount a
directory from a mounted partition onto another location and then make
that other location ro, the entire partition becomes ro.  BUT!  If I
then make the partition rw, that does not propagate back up and the bind
mount remains ro.

What should work is this:

Partition /export
Directory /export/readonly

mount --bind /export/readonly /srv/readonly

At this point, /export and /srv/readonly are both rw

mount -o remount,ro /srv/readonly

Now. both /export and /srv/readonly are ro!  This is wrong.
Only /srv/readonly is suppose to be ro!

Now, running...

mount -o remount,rw /export

now, /export is rw and /srv/readonly is readonly.

Back to containers...

If I have /srv/readonly mounted in several containers (same mount point)
it's ro in the host and in the containers...

Running this in one container:

mount -o remount,rw /srv/readonly

(I seriously wish this would NOT WORK AT ALL, but it does.  I don't want
the container to be able to write to that partition at all, like the
media was RO.  Anybody have any ideas on that one?)

Now /srv/readonly is rw in the host and all the containers!

(EVEN WORSE!)

Running this in one container:

mount -o remount,ro /srv/readonly

NOW /srv/readonly is ro in all the containers and /export is ro in the
host.  NOT GOOD.

Thoughts?

Regards,
Mike
--=20
Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
   /\/\|=3Dmhw=3D|\/\/          | (678) 463-0932 |  http://www.wittsend.com=
/mhw/
   NIC whois: MHW9          | An optimist believes we live in the best of a=
ll
 PGP Key: 0x674627FF        | possible worlds.  A pessimist is sure of it!

--=-n8G6hgQxLouuPZfvT8Nv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEVAwUAS7SiYMDrlnVnRif/AQLY9wf/acPF6h1MDxDpy0w7llpAqO/wVSmFObI7
CIEAeheoSLcGjUW2b9YnjX4eUGy1Ujb2ALwqI2iwivxcYA/wsf9SjQZxRxvGeYL7
JArSHtmcgm+05f8dmaC8XNfYVwENJPutOY8kwDf+GyAkriNlD5nBvM3Ja46SMQXL
yVurkun4o7yzhYkBb6pz+iCY5hPgG+E5k2Du/ebJHnrGVFLN6IA8OdxR+hwvwR+B
WjoXPFZh3PWkAPugMvxHOJS/4rUaX+EcCdwNN9D3QXNQ8KOkZivPbJ1KIwyyAqW6
qpWN0s7A+q8EpxpiW0p7h2iI/QYYUyQ3o9aGKW1y3DcLjR7E7y4gOA==
=dEDu
-----END PGP SIGNATURE-----

--=-n8G6hgQxLouuPZfvT8Nv--


--===============7069565533024407831==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7069565533024407831==--
