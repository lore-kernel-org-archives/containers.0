From: Thadeu Lima de Souza Cascardo <cascardo-/wxwWNsM9nk+uJoB2kUjGw@public.gmane.org>
Subject: Re: cgroup mount point
Date: Mon, 2 Feb 2009 21:43:28 -0200
Message-ID: <20090202234327.GW3643__10953.256142284$1233618389$gmane$org@vespa.holoscopio.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
	<498779C2.2060908@nortel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6193781090909127230=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <498779C2.2060908-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
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
To: Chris Friesen <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============6193781090909127230==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nhYGnrYv1PEJ5gA2"
Content-Disposition: inline


--nhYGnrYv1PEJ5gA2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 02, 2009 at 04:54:58PM -0600, Chris Friesen wrote:
> Thadeu Lima de Souza Cascardo wrote:
>
>> Linux Documentation is not consistent and have some funny options. In
>> Documentation/cgroups/*, we have:
>
>> So, we have some more options now: /cgroups, /containers, /dev/cpuset,
>> /dev/cpuctl, /opt/cgroup, /opt/cpuset.
>>
>> I am copying the container and the kernel guys. Perhaps, we can find an
>> agreement (if we want to find one at all) and change all that
>> Documentation to get consistent.
>
> I'd vote for "cgroups" or "containers", mounted at / or /sys/.
>
> /opt feels more like where software should live, and /dev should be for =
=20
> devices rather than capabilities/management.  "cpuctl" and "cpuset" are =
=20
> subsets of the full capabilities of cgroups, so they're suboptimal as =20
> far as naming.
>
> Chris

Since the original post didn't go to lkml or lxc, here it is. Sorry d-d,
but I want to keep it in the loop.

And I agree with Chris in regards that cpuctl and cpuset are not only
what is provided under a cgroup mountpoint, so they are not very good
options. I prefer cgroup over container, and I prefer the singular.

However, I'd rather not see this in /sys/ for the reason stated below.
But since we may end up agreeing on this with the kernel people, we
would be safe not to clash with a /sys/cgroup. But I see no problems
with /dev/cgroup/ but would also be glad to see /cgroup/ as the choice.


--
Hello,

Some software I intend to package work with the new cgroup feature in
Linux. I would like to open a discussion about what would be the better
place to mount it and how/when to mount it.

Some of the options are:


/sys/cgroup
/proc/cgroup

These two would not be very wise, since some kernel change may create
those two, and, then, we would hide them, at least. /proc/cgroups, for
example, is already there.


/cgroup

The FHS says why we should not create a new subdirectory in the root
filesystem:

1) "It demands space on a root partition which the system administrator
may want kept small and simple for either performance or security
reasons."

This does not apply here, since we do not require any storage for
/cgroup, but for the directory entry itself.

2) "It evades whatever discipline the system administrator may have set
up for distributing standard file hierarchies across mountable volumes."

Since /cgroup is totally local, I can't see why this will evade
anything.

procfs and sysfs are in the root filesystem too. So why not put /cgroup
there?


/dev/cgroup

Many people have been using this. FHS says this "is the location for
special and device files." What is not special about cgroup anyway?



After deciding where to mount it, we may write some code for some of the
init scripts to mount it. I think mountkernfs.sh may be a good place,
since it also mounts /proc and /sys.

Any opinions and comments appreciated.

Regards,
Cascardo.
--

--nhYGnrYv1PEJ5gA2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkmHhR8ACgkQyTpryRcqtS1e9gCcDLYewviBz8+EPykCXoD+OIik
DwcAnj3zSmGW02NAEFMd8VI8DNHJA4wq
=T+ng
-----END PGP SIGNATURE-----

--nhYGnrYv1PEJ5gA2--

--===============6193781090909127230==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6193781090909127230==--
