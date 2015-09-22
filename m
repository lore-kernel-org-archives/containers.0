From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: handling of supplemental groups with userns
Date: Tue, 22 Sep 2015 12:21:57 -0400
Message-ID: <20150922162157.GB27286__39034.9995148883$1442938938$gmane$org@vapier.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2496019664533644406=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============2496019664533644406==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="eHhjakXzOLJAF9wJ"
Content-Disposition: inline


--eHhjakXzOLJAF9wJ
Content-Type: multipart/mixed; boundary="mojUlQ0s9EVzWg2t"
Content-Disposition: inline


--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

is it possible to map in supplemental groups in a userns when the user
lacks setgid/etc... capabilities in the parent ns ?  it doesn't seem
like it's currently possible, but is there a reason to not enable it ?

basically i have a build tool that i want to isolate a bit, but it
requires access to some of my supplemental groups.  if i map just
my effective uid/gid, the build will fail when it tries to use the
chown/chgrp commands (gets back EINVAL).

my scenario boils down to:
 - normal unprivileged user (uid=8282)
 - member of multiple groups (gid=100, getgroups={100,16,250,...})
 - create a new userns (to get access to other ns like mount/pid)
   but still have access to existing groups where i'm root
 - use various features that require caps (new pidns/mntns/etc...)
 - create another userns and map back non-root users/groups
i.e. i switch from 8282 to 0, do what i need, then switch back to 8282.

i've attached a simple test program to show the issue.  it can map the
current uid/gid fine, but fails to do so with a supplemental group.

my reading of kernel/user_namespace.c shows that it's not possible:
(1) if gid_map has any entries, map_write bails early with EPERM
(2) if gid_map is empty, then writing a single entry (e.g. "0 100 1")
    works, but then a 2nd write runs into (1)
(3) if gid_map is empty, then writing multiple entries (e.g.
    "0 100 1\n250 250 1\n") fails in new_idmap_permitted -- the first
    check is skipped (since new_map->nr_extents is 2), and the user
    does not have caps in the parent ns

i'm aware UID_GID_MAP_MAX_EXTENTS is low, so it's not even possible if i
had the caps to map all the existing supplemental groups, which is why i
only want to map the few critical groups.  but assuming this use case is
one we want to support, maybe it makes sense to add a knob to map all of
the user's supplemental groups ?

in the mean time, a "quick" fix might be to change new_idmap_permitted
to walk all the extents, and if all the ranges are set to 1, check the
supplemental groups in addition to the current egid ?
-mike

--mojUlQ0s9EVzWg2t
Content-Type: text/x-c; charset=utf-8
Content-Disposition: attachment; filename="test.c"

/* To compile:
 *  gcc test.c
 * To run:
 *  ./a.out [1|2|3|4|5]
 *  ./a.out -1 "string to write to gid_map"
 */

#define _GNU_SOURCE
#include <assert.h>
#include <err.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

int main(int argc, char *argv[])
{
	int ret;

	FILE *fp;

	int uid = getuid();
	int gid = getgid();
	int nuid = 0;
	int ngid = 0;
	int suppgid;

	gid_t *groups;
	size_t i, gsize;

	int group_mode;
	switch (argc) {
	case 0:
	case 1:
		group_mode = 1;
	case 2:
		group_mode = atoi(argv[1]);
	case 3:
		group_mode = -1;
	}

	/* Find one supplemental group */
	gsize = getgroups(0, NULL);
	assert(gsize != 0);
	groups = malloc(sizeof(*groups) * gsize);
	ret = getgroups(gsize, groups);
	assert(ret == gsize);
	for (i = 0; i < gsize; ++i)
		if (groups[i] != gid) {
			suppgid = groups[i];
			break;
		}
	if (i == gsize)
		errx(1, "could not find a supplemental group to test");
	free(groups);

	/* Create new userns */
	assert(unshare(CLONE_NEWUSER) == 0);

	/* Map the current uid */
	fp = fopen("/proc/self/uid_map", "we");
	assert(fp);
	setbuf(fp, NULL);
	fprintf(fp, "%i %i 1", nuid, uid);
	fclose(fp);

	/* Disable setgroups() */
	fp = fopen("/proc/self/setgroups", "we");
	assert(fp);
	setbuf(fp, NULL);
	fputs("deny", fp);
	fclose(fp);

	/* Map the various gids */
	fp = fopen("/proc/self/gid_map", "we");
	assert(fp);
	setbuf(fp, NULL);
	switch (group_mode) {
	case 1:	/* This works */
		fprintf(fp, "%i %i 1\n", ngid, gid);
		break;
	case 2:	/* This fails */
		fprintf(fp, "%i %i 1\n", ngid, gid);
		fprintf(fp, "%i %i 1\n", suppgid, suppgid);
		break;
	case 3:	/* This fails */
		fprintf(fp, "%i %i 1\n%i %i 1\n", ngid, gid, suppgid, suppgid);
		break;
	case 4:	/* This fails */
		fprintf(fp, "%i %i 1\n", suppgid, suppgid);
		break;
	case 5:	/* This fails */
		fprintf(fp, "0 0 10000\n");
		break;
	case -1:
		fprintf(fp, argv[2]);
		break;
	}
	fclose(fp);

	/* Validate */
	printf("uid:%i gid:%i\n", getuid(), getgid());
	gsize = getgroups(0, NULL);
	assert(gsize != 0);
	groups = malloc(sizeof(*groups) * gsize);
	ret = getgroups(gsize, groups);
	assert(ret == gsize);
	printf("groups: ");
	for (i = 0; i < gsize; ++i)
		printf("%i ", groups[i]);
	printf("\n");
	free(groups);
}

--mojUlQ0s9EVzWg2t--

--eHhjakXzOLJAF9wJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWAYAlAAoJEEFjO5/oN/WB098P/2zsXLbHhh17a1gTcXIy6IZJ
HZOTUnnFtc0BHd8BuJ8X0ohUFUXtxAFD7T8kbb6iWvUumEJLy7oiWFA0pUkhMyOj
YZ+18UmDWUSIpvQklXIX+rTthPf1YFVPOWuPEBZY+8Ty9Ud4/5mdz17nXG2Z6Twk
d0X8+3BtfdXX/5mB1seXxwJklQJIErIZ2/hHbXrNIqNcR9PCUmT718/kvmsPQm5T
kcqqvNh91bW+znmXg70UIG9voinGODb7TiN9DiduWOPOvg60JK9LQHdMFaAJoa8n
eJDTbh/YeFOoHQEO+IIQOfFbwx25x9s+ffLZu4IP6DyxeJiArIoW6OIJT4xBUB6b
9ul3oJ2NLg/FPC8WpeJzZPgwvrDNJemxbiZoOaPu/RYq0P21Et7Oa5G6kAadtDAP
/YHjKhO9/dTzRQ2P2242ooylOahTl1cGFfHr1/wPjd012VEfBW3Vceqy3CDFvCoZ
gOd0fc5jsZli0D10n5ZrG008rfbRiEzpccNtfKrUI2ceYE+BB2Qc8BMbPrhjltFz
lL+uOklmdb0SeQpURQAo39bsP2e5HMSO97RrS3ko9HBe4xpRNJe1j0tweI7cpRQM
7DqwXsDoJiU7xsjEvBsDe8xweygIqb4benuGqdBmH7KCJVjLn9VRCUkJNrMud5gB
njVwL4FekRgZaHSFqMQJ
=0AuI
-----END PGP SIGNATURE-----

--eHhjakXzOLJAF9wJ--

--===============2496019664533644406==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2496019664533644406==--
