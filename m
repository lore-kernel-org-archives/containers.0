From: Seth Arnold <seth.arnold-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 05/11] Implement find_new_sub_uids find_new_sub_gids
Date: Fri, 14 Jun 2013 17:15:31 -0700
Message-ID: <20130615001531.GB32705@hunt>
References: <87ehhdpoag.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6630544801723560726=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ehhdpoag.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
 <87fw1tr33a.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============6630544801723560726==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yEPQxsgoJgBvi8ip"
Content-Disposition: inline


--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

My apologies for the lateness of my reply; I have a few small thoughts
about these patches.

On Tue, Jan 22, 2013 at 01:15:05AM -0800, Eric W. Biederman wrote:
> Functions for finding new subordinate uid and gids ranges for use
> with useradd.
>=20
> [...]
>
> +int find_new_sub_gids (const char *owner,
> +		       gid_t *range_start, unsigned long *range_count)
> +{
> +	unsigned long min, max;
> +	unsigned long count;
> +	gid_t start;
> +
> +	assert (range_start !=3D NULL);
> +	assert (range_count !=3D NULL);
> +
> +	min =3D getdef_ulong ("SUB_GID_MIN", 100000UL);
> +	max =3D getdef_ulong ("SUB_GID_MAX", 600100000UL);
> +	count =3D getdef_ulong ("SUB_GID_COUNT", 10000);


I'd like to see a quick


	if (min >=3D max || count >=3D max || (min + count) >=3D max) {
		/* fail loudly */
	}

right here. The sanity of the rest of the function depends upon these
invariants.

> +
> +	/* Is there a preferred range that works? */
> +	if ((*range_count !=3D 0) &&
> +	    (*range_start >=3D min) &&
> +	    (((*range_start) + (*range_count) - 1) <=3D max) &&
> +	    is_sub_gid_range_free(*range_start, *range_count)) {
> +		return 0;
> +	}
> +
> +	if (max < (min + count)) {
> +		(void) fprintf (stderr,
> +				_("%s: Invalid configuration: SUB_GID_MIN (%lu), SUB_GID_MAX (%lu)\n=
"),
> +			Prog, min, max);
> +		return -1;
> +	}
> +	start =3D sub_gid_find_free_range(min, max, count);
> +	if (start =3D=3D (gid_t)-1) {
> +		fprintf (stderr,
> +		         _("%s: Can't get unique secondary GID range\n"),
> +		         Prog);
> +		SYSLOG ((LOG_WARN, "no more available secondary GIDs on the system"));
> +		return -1;
> +	}
> +	*range_start =3D start;
> +	*range_count =3D count;
> +	return 0;
> +}
> +
> diff --git a/libmisc/find_new_sub_uids.c b/libmisc/find_new_sub_uids.c
> new file mode 100644
> index 0000000..f1720f9
> --- /dev/null
> +++ b/libmisc/find_new_sub_uids.c
>=20
> [...]
>=20
> +/*
> + * find_new_sub_uids - Find a new unused range of UIDs.
> + *
> + * If successful, find_new_sub_uids provides a range of unused
> + * user IDs in the [SUB_UID_MIN:SUB_UID_MAX] range.
> + *=20
> + * Return 0 on success, -1 if no unused UIDs are available.
> + */
> +int find_new_sub_uids (const char *owner,
> +		       uid_t *range_start, unsigned long *range_count)
> +{
> +	unsigned long min, max;
> +	unsigned long count;
> +	uid_t start;
> +
> +	assert (range_start !=3D NULL);
> +	assert (range_count !=3D NULL);
> +
> +	min =3D getdef_ulong ("SUB_UID_MIN", 100000UL);
> +	max =3D getdef_ulong ("SUB_UID_MAX", 600100000UL);
> +	count =3D getdef_ulong ("SUB_UID_COUNT", 10000);

Same here, of course.

> +	/* Is there a preferred range that works? */
> +	if ((*range_count !=3D 0) &&
> +	    (*range_start >=3D min) &&
> +	    (((*range_start) + (*range_count) - 1) <=3D max) &&
> +	    is_sub_uid_range_free(*range_start, *range_count)) {
> +		return 0;
> +	}
> +
> +	if (max < (min + count)) {
> +		(void) fprintf (stderr,
> +				_("%s: Invalid configuration: SUB_UID_MIN (%lu), SUB_UID_MAX (%lu)\n=
"),
> +			Prog, min, max);
> +		return -1;
> +	}
> +	start =3D sub_uid_find_free_range(min, max, count);
> +	if (start =3D=3D (uid_t)-1) {
> +		fprintf (stderr,
> +		         _("%s: Can't get unique secondary UID range\n"),
> +		         Prog);
> +		SYSLOG ((LOG_WARN, "no more available secondary UIDs on the system"));
> +		return -1;
> +	}
> +	*range_start =3D start;
> +	*range_count =3D count;
> +	return 0;
> +}

On Tue, Jan 22, 2013 at 01:20:07AM -0800, Eric W. Biederman wrote:
> +struct map_range *get_map_ranges(int ranges, int argc, char **argv)
> +{
> +	struct map_range *mappings, *mapping;
> +	int idx, argidx;
> +
> +	if ((ranges * 3) > argc) {
> +		fprintf(stderr, "ranges: %u argc: %d\n",
> +			ranges, argc);
> +		fprintf(stderr,
> +			_( "%s: Not enough arguments to form %u mappings\n"),
> +			Prog, ranges);
> +		return NULL;
> +	}

If 'ranges' is large enough, 3*ranges can wrap around to be less than
'argc', pass this test, and continue to the for loop below, which could
scribble all over memory until running into an unmapped page.

The current use appears safe, and I don't see how this could be exploited
even if it weren't currently safe, but I'd really like to see this test
re-written in a way that does not allow wraparound.

> +	mappings =3D calloc(ranges, sizeof(*mappings));
> +	if (!mappings) {
> +		fprintf(stderr, _( "%s: Memory allocation failure\n"),
> +			Prog);
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	/* Gather up the ranges from the command line */
> +	mapping =3D mappings;
> +	for (idx =3D 0; idx < ranges; idx++, argidx +=3D 3, mapping++) {
> +		if (!getulong(argv[argidx + 0], &mapping->upper))
> +			return NULL;
> +		if (!getulong(argv[argidx + 1], &mapping->lower))
> +			return NULL;
> +		if (!getulong(argv[argidx + 2], &mapping->count))
> +			return NULL;
> +	}
> +	return mappings;
> +}

Thanks,

Seth

--yEPQxsgoJgBvi8ip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAEBAgAGBQJRu7IjAAoJEPMhclmdjS6XFDYIAL1jHwSDmWnjTKP30Wjn1pCy
Xv35Td9rn8SiDx2DN4R68jJsxTKi4NKBn2gnczErb2HskqWwGOIPHUSEq/kA6GRp
WRZOWvpLg+BDcHmAjBpkLmU0tOxsopcL2fMceGsR1jMXUZ6h0oqm0lozm0q774Hs
8xf9jKk/Vy7OYloYanwSzioJQUMK/9XS138yBJBoiJbusb92SS8w8OCYw9u7yi1w
BJOCpkTOQyagkszBkCT+EX26eAPW6VNjAc5l4XTKB/dgmNs0O4S71KHFtplYYAwo
aO7EJ9fZPwTzDUAkBD4c1bIi590h/cXcQszdLiUoiwujL8vB+p5KWe9IR4lOBGo=
=Xyhu
-----END PGP SIGNATURE-----

--yEPQxsgoJgBvi8ip--

--===============6630544801723560726==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6630544801723560726==--
