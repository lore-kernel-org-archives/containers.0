From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Fri, 29 Apr 2016 15:18:30 -0700
Message-ID: <1461968310.16292.20.camel__40174.6710217141$1461968331$gmane$org@HansenPartnership.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1909370894180485784=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1461944328.2311.10.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============1909370894180485784==
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-4CgZvvoFzrZpkPn1CPuX"


--=-4CgZvvoFzrZpkPn1CPuX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-04-29 at 08:38 -0700, James Bottomley wrote:
> On Thu, 2016-04-28 at 16:00 -0700, W. Trevor King wrote:
> > On Thu, Apr 28, 2016 at 03:02:08PM -0700, James Bottomley wrote:
> > > /etc/usernamespaces
> > >=20
> > > and the format be :::
> > >=20
> > > =E2=80=A6
> > >=20
> > > If this sounds OK to people, I can code up a utility that does
> > > this,
> > > which should probably belong in util-linux.
> >=20
> > This sounds a lot like shadow's newuidmap and newgidmap [1,2,3].
> >=20
> > Cheers,
> > Trevor
> >=20
> > [1]: https://github.com/shadow-maint/shadow/commit/673c2a6f9aa6c695
> > 88f4c1be08589b8d3475a520
> > [2]: http://man7.org/linux/man-pages/man1/newuidmap.1.html
> > [3]: http://man7.org/linux/man-pages/man5/subuid.5.html
>=20
> I think that mostly works.  No-one's packaging it yet, which is why I
> didn't notice.  It also looks like the build dependencies have vastly
> expanded, so I can't get it to build in the build service yet.
>=20
> It looks like the only addition it needs is the setgroups flag for
> newgidmap, which the security people will need, so I can patch that.=20

How does this look for a patch?

James

---

diff --git a/lib/subordinateio.c b/lib/subordinateio.c
index 0d64a91..aa3c968 100644
--- a/lib/subordinateio.c
+++ b/lib/subordinateio.c
@@ -18,9 +18,10 @@ struct subordinate_range {
 	const char *owner;
 	unsigned long start;
 	unsigned long count;
+	const char *flags;
 };
=20
-#define NFIELDS 3
+#define NFIELDS 4
=20
 /*
  * subordinate_dup: create a duplicate range
@@ -44,6 +45,16 @@ static /*@null@*/ /*@only@*/void *subordinate_dup (const=
 void *ent)
 		free(range);
 		return NULL;
 	}
+	if (rangeent->flags) {
+		range->flags =3D strdup (rangeent->flags);
+		if (NULL =3D=3D range->flags) {
+			free((void *)range->owner);
+			free(range);
+			return NULL;
+		}
+	} else {
+		range->flags =3D NULL;
+	}
 	range->start =3D rangeent->start;
 	range->count =3D rangeent->count;
=20
@@ -111,13 +122,17 @@ static void *subordinate_parse (const char *line)
 	 * There must be exactly NFIELDS colon separated fields or
 	 * the entry is invalid.  Also, fields must be non-blank.
 	 */
-	if (i !=3D NFIELDS || *fields[0] =3D=3D '\0' || *fields[1] =3D=3D '\0' ||=
 *fields[2] =3D=3D '\0')
+	if ((i !=3D NFIELDS && i !=3D NFIELDS -1) || *fields[0] =3D=3D '\0' || *f=
ields[1] =3D=3D '\0' || *fields[2] =3D=3D '\0')
 		return NULL;
 	range.owner =3D fields[0];
 	if (getulong (fields[1], &range.start) =3D=3D 0)
 		return NULL;
 	if (getulong (fields[2], &range.count) =3D=3D 0)
 		return NULL;
+	if (i =3D=3D NFIELDS)
+		range.flags =3D fields[3];
+	else
+		range.flags =3D NULL;
=20
 	return &range;
 }
@@ -134,10 +149,11 @@ static int subordinate_put (const void *ent, FILE * f=
ile)
 {
 	const struct subordinate_range *range =3D ent;
=20
-	return fprintf(file, "%s:%lu:%lu\n",
+	return fprintf(file, "%s:%lu:%lu:%s\n",
 			       range->owner,
 			       range->start,
-			       range->count) < 0 ? -1  : 0;
+			       range->count,
+			       range->flags ? range->flags : "") < 0 ? -1  : 0;
 }
=20
 static struct commonio_ops subordinate_ops =3D {
@@ -295,7 +311,8 @@ static const struct subordinate_range *find_range(struc=
t commonio_db *db,
  * Returns true if @owner is authorized to use the range, false otherwise.
  */
 static bool have_range(struct commonio_db *db,
-		       const char *owner, unsigned long start, unsigned long count)
+		       const char *owner, unsigned long start, unsigned long count,
+		       const char **flags)
 {
 	const struct subordinate_range *range;
 	unsigned long end;
@@ -309,8 +326,11 @@ static bool have_range(struct commonio_db *db,
 		unsigned long last;=20
=20
 		last =3D range->start + range->count - 1;
-		if (last >=3D (start + count - 1))
+		if (last >=3D (start + count - 1)) {
+			if (flags)
+				*flags =3D range->flags;
 			return true;
+		}
=20
 		count =3D end - last;
 		start =3D last + 1;
@@ -430,7 +450,7 @@ static int add_range(struct commonio_db *db,
 	range.count =3D count;
=20
 	/* See if the range is already present */
-	if (have_range(db, owner, start, count))
+	if (have_range(db, owner, start, count, NULL))
 		return 1;
=20
 	/* Otherwise append the range */
@@ -585,7 +605,7 @@ bool sub_uid_assigned(const char *owner)
=20
 bool have_sub_uids(const char *owner, uid_t start, unsigned long count)
 {
-	return have_range (&subordinate_uid_db, owner, start, count);
+	return have_range (&subordinate_uid_db, owner, start, count, NULL);
 }
=20
 int sub_uid_add (const char *owner, uid_t start, unsigned long count)
@@ -659,9 +679,9 @@ int sub_gid_open (int mode)
 	return commonio_open (&subordinate_gid_db, mode);
 }
=20
-bool have_sub_gids(const char *owner, gid_t start, unsigned long count)
+bool have_sub_gids(const char *owner, gid_t start, unsigned long count, co=
nst char **flags)
 {
-	return have_range(&subordinate_gid_db, owner, start, count);
+	return have_range(&subordinate_gid_db, owner, start, count, flags);
 }
=20
 bool sub_gid_assigned(const char *owner)
diff --git a/lib/subordinateio.h b/lib/subordinateio.h
index a21d72b..7e47659 100644
--- a/lib/subordinateio.h
+++ b/lib/subordinateio.h
@@ -25,7 +25,7 @@ extern int sub_uid_remove (const char *owner, uid_t start=
, unsigned long count);
 extern uid_t sub_uid_find_free_range(uid_t min, uid_t max, unsigned long c=
ount);
=20
 extern int sub_gid_close(void);
-extern bool have_sub_gids(const char *owner, gid_t start, unsigned long co=
unt);
+extern bool have_sub_gids(const char *owner, gid_t start, unsigned long co=
unt, const char **flags);
 extern bool sub_gid_file_present (void);
 extern bool sub_gid_assigned(const char *owner);
 extern int sub_gid_lock (void);
diff --git a/libmisc/idmapping.c b/libmisc/idmapping.c
index 0dce634..7f7de88 100644
--- a/libmisc/idmapping.c
+++ b/libmisc/idmapping.c
@@ -106,7 +106,6 @@ void write_mapping(int proc_dir_fd, int ranges, struct =
map_range *mappings,
 	struct map_range *mapping;
 	size_t bufsize;
 	char *buf, *pos;
-	int fd;
=20
 	bufsize =3D ranges * ((ULONG_DIGITS  + 1) * 3);
 	pos =3D buf =3D xmalloc(bufsize);
@@ -128,13 +127,20 @@ void write_mapping(int proc_dir_fd, int ranges, struc=
t map_range *mappings,
 	}
=20
 	/* Write the mapping to the maping file */
+	write_proc(proc_dir_fd, map_file, buf, pos - buf);
+}
+
+void write_proc(int proc_dir_fd, const char *map_file, void *buf, int len)
+{
+	int fd;
+
 	fd =3D openat(proc_dir_fd, map_file, O_WRONLY);
 	if (fd < 0) {
 		fprintf(stderr, _("%s: open of %s failed: %s\n"),
 			Prog, map_file, strerror(errno));
 		exit(EXIT_FAILURE);
 	}
-	if (write(fd, buf, pos - buf) !=3D (pos - buf)) {
+	if (write(fd, buf, len) !=3D len) {
 		fprintf(stderr, _("%s: write to %s failed: %s\n"),
 			Prog, map_file, strerror(errno));
 		exit(EXIT_FAILURE);
diff --git a/libmisc/idmapping.h b/libmisc/idmapping.h
index 58d000f..c2cec38 100644
--- a/libmisc/idmapping.h
+++ b/libmisc/idmapping.h
@@ -39,6 +39,7 @@ struct map_range {
 extern struct map_range *get_map_ranges(int ranges, int argc, char **argv)=
;
 extern void write_mapping(int proc_dir_fd, int ranges,
 	struct map_range *mappings, const char *map_file);
+extern void write_proc(int proc_dir_fd, const char *map_file, void *buf, i=
nt len);
=20
 #endif /* _ID_MAPPING_H_ */
=20
diff --git a/src/newgidmap.c b/src/newgidmap.c
index 451c6a6..8d64e3b 100644
--- a/src/newgidmap.c
+++ b/src/newgidmap.c
@@ -46,14 +46,14 @@
  */
 const char *Prog;
=20
-static bool verify_range(struct passwd *pw, struct map_range *range)
+static bool verify_range(struct passwd *pw, struct map_range *range, const=
 char **flags)
 {
 	/* An empty range is invalid */
 	if (range->count =3D=3D 0)
 		return false;
=20
 	/* Test /etc/subgid */
-	if (have_sub_gids(pw->pw_name, range->lower, range->count))
+	if (have_sub_gids(pw->pw_name, range->lower, range->count, flags))
 		return true;
=20
 	/* Allow a process to map it's own gid */
@@ -64,14 +64,14 @@ static bool verify_range(struct passwd *pw, struct map_=
range *range)
 }
=20
 static void verify_ranges(struct passwd *pw, int ranges,
-	struct map_range *mappings)
+			  struct map_range *mappings, const char **flags)
 {
 	struct map_range *mapping;
 	int idx;
=20
 	mapping =3D mappings;
 	for (idx =3D 0; idx < ranges; idx++, mapping++) {
-		if (!verify_range(pw, mapping)) {
+		if (!verify_range(pw, mapping, flags)) {
 			fprintf(stderr, _( "%s: gid range [%lu-%lu) -> [%lu-%lu) not allowed\n"=
),
 				Prog,
 				mapping->upper,
@@ -103,6 +103,7 @@ int main(int argc, char **argv)
 	struct stat st;
 	struct passwd *pw;
 	int written;
+	const char *flags;
=20
 	Prog =3D Basename (argv[0]);
=20
@@ -177,7 +178,18 @@ int main(int argc, char **argv)
 	if (!mappings)
 		usage();
=20
-	verify_ranges(pw, ranges, mappings);
+	verify_ranges(pw, ranges, mappings, &flags);
+
+	if (flags && strlen(flags) !=3D 0) {
+		/* only allowed flag is currently deny */
+		if (strcmp(flags, "deny") =3D=3D 0) {
+			write_proc(proc_dir_fd, "setgroups", "deny", strlen("deny"));
+		} else {
+			fprintf(stderr, _("%s: illegal flag in map file: %s\n"),
+				Prog, flags);
+			exit(EXIT_FAILURE);
+		}
+	}=09
=20
 	write_mapping(proc_dir_fd, ranges, mappings, "gid_map");
 	sub_gid_close();

--=-4CgZvvoFzrZpkPn1CPuX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXI922AAoJEDeqqVYsXL0MK0EIAIuAkOYHuS72kHYueIxG8LvX
Ri9jU5LBu9HxBBYu/HMEnKlnbsRRGvtcEb/P2S8V00sk9+GigZUm0cQ9MRMuZ4aE
vEX83miE3xeqpCc0b+WZrVLJrNAofVGQkVK8piGlUMBelvvMqpH7PRiXQLniQXET
3n559fhoKsVQ/d/6TXaLHb+3EME96cs/tPPB81UGO/uBCPRwrfH5SnILHvthLpmd
Rt7SvzJtuFiaQERrr2zOGH/S+j4450bFhi3I0cPEC1BCsiydk06FxTDbQFPdHpu7
2nWkjbqi9+JTYAop3UukHy8NqvRx/XTWpr3w99ic49H7gc84jXD6PRM0PiCzyRQ=
=T77u
-----END PGP SIGNATURE-----

--=-4CgZvvoFzrZpkPn1CPuX--


--===============1909370894180485784==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============1909370894180485784==--
