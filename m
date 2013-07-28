From: Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Sun, 28 Jul 2013 19:14:51 +0200
Message-ID: <20130728171451.GX5670@mykerinos.kheops.frmug.org>
References: <87d2wxshu0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6324447510264489263=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2wxshu0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?B?RnJhbsOnb2lz?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============6324447510264489263==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="zuE2pCA56U4I9Fhk"
Content-Disposition: inline


--zuE2pCA56U4I9Fhk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>=20
> The kernel support for user namespaces allows ordinary users to use
> multiple uids and gids if they can get a trusted program to tell the
> kernel the set of subordinate uids and gids they are allowed to use.
>=20
> This is my work to make that trusted program.
> Two new files are added /etc/subuid /etc/subgid that specify
> ranges of uids and gids that users may uses.
>=20
> useradd, and newusers are modifed to add users to those files.
>=20
> userdel is modeifed to remove users from those files.
>=20
> usermod is modified to give manual control of what goes in those files.
>=20
> newuidmap and newgidmap read the new files and update
> /proc/[pid]/uid_map and /proc/[pid]/gid_map respectively
> as requested by their command line parameters and as allowed
> by the /etc/subuid and /etc/subgid.
>=20
> The following patches are against the current developent trunk
> of pkg-shadow svn rev 3745.  With minor tweaking of man/Makefile.am
> these patches also apply to shadow 4.1.5.
>=20
> Eric W. Biederman (11):
>       Documentation for /etc/subuid and /etc/subgid
>       login.defs.5: Document the new variables in login.defs
>       Implement commonio_append.
>       Add backend support for suboridnate uids and gids
>       Implement find_new_sub_uids find_new_sub_gids
>       userdel: Add support for removing subordinate user and group ids.
>       useradd: Add support for subordinate user identifiers
>       Add support for detecting busy subordinate user ids
>       usermod: Add support for subordinate uids and gids.
>       newusers: Add support for assiging subordinate uids and gids.
>       newuidmap,newgidmap: New suid helpers for using subordinate uids an=
d gids
> ---

OK, now we're ready for this.

Eric, I have no skills to decide whether your patches can be included
or not. My proposal is to go ahead and include them in the upcomign
4.2 release, that will be compiled and uploaded in Debian as soon as
released, so that it gets extensive testing.

We now have an "upstream" git repository at


http://github.com/shadow-maint/shadow.git

Would you mind pushing your set of patches there?

That requires an account on github and include you in the project
members (Serge Hallyn can do that).

I would prefer this over committing/pushing myself.

I really apologize for the too long delay working on this. We now need
to revive shadow's development.




--zuE2pCA56U4I9Fhk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBCAAGBQJR9VGLAAoJEIcvcCxNbiWoPdkQAMAGPF7Jt8I884YPJA8b4zDx
ZtVoR7pOf9xIDsIMVu9aIDDu4/JeMfF4pvpECdgOIKsog93HzslhrcoX9LqvIVwO
pAQQO59RsKR5qcdb25BCIRhx+4WG8u37bwjcAnUq6iqlNujquZLvFn3ayj8kMxcX
n5OAjgI8IDbFDcXdnlygDhI8mYyFfaNg7ocd0YNNmom+HnDrnHSGoWqWbUOOwnuv
RnPN1cIUTNyOsxywSigVrM9t6Bil5zpvC/IvhSDA0kYHyPL3ZFoDj6yxLPYe6PxS
apBGYpLYpV2qfclUT4uwbKJncBDej7F3rPYqbwCTAaqbdquAVnqEiSh+ptYda/Y1
Fv9FHic1xypkZgn4PVTtRd8N5GRyyShgbVw1fx3ojI9AbxYPh1e30xy8GSfNLhTA
aR79yY/y7HhzK3zM60kt42zB5nwY3mfthdRbfzE29aKyIVl08odgjv+/MnrDD5+x
Ie0UKaaxSh6Q7Ka920Czzfle6ktJA4mwupJQtXr3AkX/30z3wdYinDST0v23kw1f
XPRsH9OCQPBOKm5iKIsux6bSY14dxIgXIWs92oPA5Z2LIP7flDu1SRPynJKUNsOn
846KX+fD7LnnVaNTMuUpY+gCrA5h8ouRCmHR4DvbImcH7sxLrqnhW9S1NnQBejuI
DGxRRtXgilU1+IJYHFJv
=Yp+c
-----END PGP SIGNATURE-----

--zuE2pCA56U4I9Fhk--

--===============6324447510264489263==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6324447510264489263==--
