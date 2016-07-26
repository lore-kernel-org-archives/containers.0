From: =?UTF-8?Q?Micha=c5=82_Zegan?= <webczat_200-wo4oW1Pw1HF3vZ0LZ0W7Rg@public.gmane.org>
Subject: Re: [GIT PULL] userns related vfs enhancements for v4.8
Date: Wed, 27 Jul 2016 01:18:01 +0200
Message-ID: <6ec55309-209d-7b90-9289-19e6fd180af9__43160.9934698374$1469575471$gmane$org@poczta.onet.pl>
References: <87bn1kwjad.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1677382520496190230=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bn1kwjad.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============1677382520496190230==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Pm6Vgs1t6BhiqHI5Jw292av2aURFqLpgN"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Pm6Vgs1t6BhiqHI5Jw292av2aURFqLpgN
Content-Type: multipart/mixed; boundary="qVxNNBI4KVAijMUBi47nru9peUE4iEIfg"
From: =?UTF-8?Q?Micha=c5=82_Zegan?= <webczat_200-wo4oW1Pw1HF3vZ0LZ0W7Rg@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
 Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
 linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <6ec55309-209d-7b90-9289-19e6fd180af9-wo4oW1Pw1HF3vZ0LZ0W7Rg@public.gmane.org>
Subject: Re: [GIT PULL] userns related vfs enhancements for v4.8
References: <87bn1kwjad.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
In-Reply-To: <87bn1kwjad.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>

--qVxNNBI4KVAijMUBi47nru9peUE4iEIfg
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable

I have one question: what uids are written in the filesystem inodes?
those that the kernel sees, or those mapped by user namespaces? and so,
is it true that the filesystem will still require shifting uids,
directly or indirectly, to be usable from inside user namespace? can't
uids be mapped dynamically from what is in the inode to kernel uids
based on the user namespace they are used from? Maybe because the fs can
be mounted from outside before starting the container?

W dniu 26.07.2016 o 16:44, Eric W. Biederman pisze:
>=20
> Linus,
>=20
> Please pull the for-linus branch from the git tree:
>=20
>    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespac=
e.git for-linus
>=20
>    HEAD: aeaa4a79ff6a5ed912b7362f206cf8576fca538b fs: Call d_automount =
with the filesystems creds
>=20
> [ Merging note.  There are some minor merge conflicts between this tree=

>   and your own.  My sample merge resolution against v4.7 is at the end =
]
>=20
> This tree contains some very long awaited work on generalizing the user=

> namespace support for mounting filesystems to include filesystems with =
a
> backing store.  The real world target is fuse but the goal is to update=

> the vfs to allow any filesystem to be supported.  This patchset is
> based on a lot of code review and testing to approach that goal.
>=20
> While looking at what is needed to support the fuse filesystem it becam=
e
> clear that there were things like xattrs for security modules that
> needed special treatment.  That the resolution of those concerns would
> not be fuse specific.  That sorting out these general issues made most
> sense at the generic level, where the right people could be drawn into
> the conversation, and the issues could be solved for everyone.
>=20
> At a high level what this patchset does a couple of simple things.
> - Add a user namespace owner (s_user_ns) to struct super_block.
> - Teach the vfs to handle filesystem uids and gids not mapping
>   into to kuids and kgids and being reported as INVALID_UID
>   and INVALID_GID in vfs data structures.
>=20
> By assigning a user namespace owner filesystems that are mounted with
> only user namespace privilege can be detected.  This allows security
> modules and the like to know which mounts may not be trusted.  This als=
o
> allows the set of uids and gids that are communicated to the filesystem=

> to be capped at the set of kuids and kgids that are in the owning user
> namespace of the filesystem.
>=20
> One of the crazier corner casees this handles is the case of inodes
> whose i_uid or i_gid are not mapped into the vfs.  Most of the code
> simply doesn't care but it is easy to confuse the inode writeback
> path so no operation that could cause an inode write-back is
> permitted for such inodes (aka only reads are allowed).
>=20
> This set of changes starts out by cleaning up the code paths involved
> in user namespace permirted mounts.  Then when things are clean enough
> adds code that cleanly sets s_user_ns.  Then additional restrictions
> are added that are possible now that the filesystem superblock contains=

> owner information.
>=20
> These changes should not affect anyone in practice, but there
> are some parts of these restrictions that are changes in behavior.
>=20
> - Andy's restriction on suid executables that does not
>   honor the suid bit when the path is from another mount namespace
>   (think /proc/[pid]/fd/) or when the filesystem was mounted by
>   a less privileged user.
>=20
> - The replacement of the user namespace implicit setting of MNT_NODEV
>   with implicitly setting SB_I_NODEV on the filesystem superblock
>   instead.
>=20
>   Using SB_I_NODEV is a stronger form that happens to make this state
>   user invisible.  The user visibility can be managed but it caused
>   problems when it was introduced from applications reasonably expectin=
g
>   mount flags to be what they were set to.
>=20
> There is a little bit of work remaining before it is safe to support
> mounting filesystems with backing store in user namespaces, beyond
> what is in this set of changes.
>=20
> - Verifying the mounter has permission to read/write the block device
>   during mount.
>=20
> - Teaching the integrity modules IMA and EVM to handle filesystems
>   mounted with only user namespace root and to reduce trust in
>   their security xattrs accordingly.
>=20
> - Capturing the mounters credentials and using that for permission
>   checks in d_automount and the like.  (Given that overlayfs already
>   does this, and we need the work in d_automount it make sense to
>   generalize this case).
>=20
> Furthermore there are a few changes that are on the wishlist.
> - Get all filesystems supporting posix acls using the generic posix acl=
s
>   so that posix_acl_fix_xattr_from_user and posix_acl_fix_xattr_to_user=

>   may be removed.  [Maintainability]
>=20
> - Reducing the permission checks in places such as remount
>   to allow the superblock owner to perform them.
>=20
> - Allowing the superblock owner to chown files with unmapped
>   uids and gids to something that is mapped so the files
>   may be treated normally.
>=20
> I am not considering even obvious relaxations of permission checks unti=
l
> it is clear there are no more corner cases that need to be locked down
> and handled generically.
>=20
> Many thanks to Seth Forshee who kept this code alive, and putting up
> with me rewriting substantial portions of what he did to handle more
> corner cases, and for his diligent testing and reviewing of my changes.=

>=20
> Andy Lutomirski (1):
>       fs: Treat foreign mounts as nosuid
>=20
> Eric W. Biederman (20):
>       mnt: Refactor fs_fully_visible into mount_too_revealing
>       ipc: Initialize ipc_namespace->user_ns early.
>       vfs: Pass data, ns, and ns->userns to mount_ns
>       proc: Convert proc_mount to use mount_ns.
>       fs: Add user namespace member to struct super_block
>       mnt: Move the FS_USERNS_MOUNT check into sget_userns
>       kernfs: The cgroup filesystem also benefits from SB_I_NOEXEC
>       ipc/mqueue: The mqueue filesystem should never contain executable=
s
>       vfs: Generalize filesystem nodev handling.
>       mnt: Simplify mount_too_revealing
>       userns: Remove implicit MNT_NODEV fragility.
>       userns: Remove the now unnecessary FS_USERNS_DEV_MOUNT flag
>       userns: Handle -1 in k[ug]id_has_mapping when !CONFIG_USER_NS
>       vfs: Verify acls are valid within superblock's s_user_ns.
>       vfs: Don't modify inodes with a uid or gid unknown to the vfs
>       vfs: Don't create inodes with a uid or gid unknown to the vfs
>       quota: Ensure qids map to the filesystem
>       quota: Handle quota data stored in s_user_ns in quota_setxquota
>       dquot: For now explicitly don't support filesystems outside of in=
it_user_ns
>       fs: Call d_automount with the filesystems creds
>=20
> Seth Forshee (9):
>       fs: Limit file caps to the user namespace of the super block
>       Smack: Add support for unprivileged mounts from user namespaces
>       Smack: Handle labels consistently in untrusted mounts
>       selinux: Add support for unprivileged mounts from user namespaces=

>       fs: Refuse uid/gid changes which don't map into s_user_ns
>       fs: Check for invalid i_uid in may_follow_link()
>       cred: Reject inodes with invalid ids in set_create_file_as()
>       evm: Translate user/group ids relative to s_user_ns when computin=
g HMAC
>       fs: Update i_[ug]id_(read|write) to translate relative to s_user_=
ns
>=20
>  drivers/staging/lustre/lustre/mdc/mdc_request.c |  2 +-
>  fs/9p/acl.c                                     |  2 +-
>  fs/attr.c                                       | 19 +++++
>  fs/block_dev.c                                  |  2 +-
>  fs/devpts/inode.c                               |  3 +-
>  fs/exec.c                                       |  2 +-
>  fs/inode.c                                      |  7 ++
>  fs/kernfs/mount.c                               |  5 +-
>  fs/namei.c                                      | 55 +++++++++++---
>  fs/namespace.c                                  | 99 ++++++++++++-----=
--------
>  fs/nfsd/nfsctl.c                                | 13 +---
>  fs/posix_acl.c                                  |  8 +-
>  fs/proc/inode.c                                 |  8 +-
>  fs/proc/internal.h                              |  3 +-
>  fs/proc/root.c                                  | 54 ++------------
>  fs/quota/dquot.c                                |  8 ++
>  fs/quota/quota.c                                | 14 ++--
>  fs/super.c                                      | 69 +++++++++++++++--=

>  fs/sysfs/mount.c                                |  5 +-
>  fs/xattr.c                                      |  7 ++
>  include/linux/fs.h                              | 79 ++++++++++++-----=
---
>  include/linux/mount.h                           |  1 +
>  include/linux/posix_acl.h                       |  2 +-
>  include/linux/quota.h                           | 10 +++
>  include/linux/uidgid.h                          |  4 +-
>  include/linux/user_namespace.h                  |  6 ++
>  ipc/mqueue.c                                    | 20 +++--
>  ipc/namespace.c                                 |  5 +-
>  kernel/cred.c                                   |  2 +
>  kernel/user_namespace.c                         | 14 ++++
>  net/sunrpc/rpc_pipe.c                           |  8 +-
>  security/commoncap.c                            | 10 ++-
>  security/integrity/evm/evm_crypto.c             |  4 +-
>  security/selinux/hooks.c                        | 25 ++++++-
>  security/smack/smack.h                          |  8 +-
>  security/smack/smack_lsm.c                      | 34 ++++++++-
>  36 files changed, 411 insertions(+), 206 deletions(-)
>=20
> The conflict resolution of my test-merge:
>=20
> diff --cc fs/posix_acl.c
> index edc452c2a563,647c28180675..59d47ab0791a
> --- a/fs/posix_acl.c
> +++ b/fs/posix_acl.c
> @@@ -833,24 -839,6 +833,24 @@@ set_posix_acl(struct inode *inode, int=20
>   	if (!inode_owner_or_capable(inode))
>   		return -EPERM;
>  =20
>  +	if (acl) {
> - 		int ret =3D posix_acl_valid(acl);
> ++		int ret =3D posix_acl_valid(inode->i_sb->s_user_ns, acl);
>  +		if (ret)
>  +			return ret;
>  +	}
>  +	return inode->i_op->set_acl(inode, acl, type);
>  +}
>  +EXPORT_SYMBOL(set_posix_acl);
>  +
>  +static int
>  +posix_acl_xattr_set(const struct xattr_handler *handler,
>  +		    struct dentry *unused, struct inode *inode,
>  +		    const char *name, const void *value,
>  +		    size_t size, int flags)
>  +{
>  +	struct posix_acl *acl =3D NULL;
>  +	int ret;
>  +
>   	if (value) {
>   		acl =3D posix_acl_from_xattr(&init_user_ns, value, size);
>   		if (IS_ERR(acl))
> diff --cc fs/proc/inode.c
> index 42305ddcbaa0,a5b2c33745b7..6b1843e78bd7
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@@ -462,6 -463,11 +463,18 @@@ int proc_fill_super(struct super_block=20
>   	struct inode *root_inode;
>   	int ret;
>  =20
> ++	/*
> ++	 * procfs isn't actually a stacking filesystem; however, there is
> ++	 * too much magic going on inside it to permit stacking things on
> ++	 * top of it
> ++	 */
> ++	s->s_stack_depth =3D FILESYSTEM_MAX_STACK_DEPTH;
> ++
> + 	if (!proc_parse_options(data, ns))
> + 		return -EINVAL;
> +=20
> + 	/* User space would break if executables or devices appear on proc *=
/
> + 	s->s_iflags |=3D SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
>   	s->s_flags |=3D MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
>   	s->s_blocksize =3D 1024;
>   	s->s_blocksize_bits =3D 10;
>=20
> Eric
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--qVxNNBI4KVAijMUBi47nru9peUE4iEIfg--

--Pm6Vgs1t6BhiqHI5Jw292av2aURFqLpgN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQE4BAEBCAAiBQJXl++xGxx3ZWJjemF0XzIwMEBwb2N6dGEub25ldC5wbAAKCRCZ
HGg9mcgU+aa2B/9OlicRDoC3KhHvrfWk25lXOKiqdMZwmWVtll5+dSf1qXrR23MM
4LDT1BAwIqQKdbYCV3qkgJbW+PB1xa5RDVoNJOYAei56jdcfDbyGpXJeOfJbITkN
NV0e+t2qTKELyeQ/HD+NXOq2AtT2l8eQt2HXLpnVSgefBJp3RSJrz45bAMvviwVu
HuP1SwCfD0W7Scro8DaO0F0SqYEI1keQWj0X0Y1uFV1JDTuZfEY3BAWmST6Uz4nK
aI2mTaAIg3St+mfJGItm8GuzzTwqvuT0wnZzu5qN29c8JCWHfF+RF5+/L+7JQfoG
4BreiwKLf4dGotFXulGQ7sEP1K/xR1X/Vddd
=F3At
-----END PGP SIGNATURE-----

--Pm6Vgs1t6BhiqHI5Jw292av2aURFqLpgN--

--===============1677382520496190230==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============1677382520496190230==--
