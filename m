From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH review 03/16] xfs: Always read uids and gids from the vfs
	inode
Date: Tue, 19 Feb 2013 12:14:22 +1100
Message-ID: <20130219011422.GG26694@dastard>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
	<1361149870-27732-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1361149870-27732-3-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Feb 17, 2013 at 05:10:56PM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Add xfs_set_uid and xfs_set_gid to encapsulate the double write
> needed when updating uid and gids, and uset them for all uid
> and gid writes.
>
> Update VFS()->i_uid and VFS_I()->i_gid immediately after reading
> on-disk inode values so that all of the cached uid and gid values
> are always in sync allowing VFS()->i_uid and VFS()->i_gid to safely
> be used everywhere.
>
> Replace reads of i_d.di_uid and i_d.di_gid with VFS_I()->i_uid and
> VFS_I()->i_gid.

tl;dr: gross layering violation.

> diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
> index 51c2597..846166d 100644
> --- a/fs/xfs/xfs_inode.c
> +++ b/fs/xfs/xfs_inode.c
> @@ -1016,6 +1016,8 @@ xfs_iread(
>  
>  		ip->i_projid = ((projid_t)ip->i_d.di_projid_hi << 16) |
>  					  ip->i_d.di_projid_lo;
> +		VFS_I(ip)->i_uid = ip->i_d.di_uid;
> +		VFS_I(ip)->i_gid = ip->i_d.di_gid;

This is layers below anything VFS related and as such is a a gross
layering violation. There are many operations done in XFS on inodes
outside the life cycle of the struct inode, and so we cannot safely
use anything in the struct inode outside of those contexts.

The VFS struct inode values are only valid inside the defined life
cycle of the VFS inode, and that means from xfs_setup_inode() to
xfs_fs_evict_inode()/xfs_inactive(). Any use of uid/gid/prid outside
those boundaries is completely internal to XFS and needs to be
treated as such.

> @@ -1201,8 +1203,8 @@ xfs_ialloc(
>  	ip->i_d.di_onlink = 0;
>  	ip->i_d.di_nlink = nlink;
>  	ASSERT(ip->i_d.di_nlink == nlink);
> -	ip->i_d.di_uid = current_fsuid();
> -	ip->i_d.di_gid = current_fsgid();
> +	xfs_set_uid(ip, current_fsuid());
> +	xfs_set_gid(ip, current_fsgid());

Same layering violation.


>  	xfs_set_projid(ip, prid);
>  	memset(&(ip->i_d.di_pad[0]), 0, sizeof(ip->i_d.di_pad));
>  
> @@ -1228,7 +1230,7 @@ xfs_ialloc(
>  		xfs_bump_ino_vers2(tp, ip);
>  
>  	if (pip && XFS_INHERIT_GID(pip)) {
> -		ip->i_d.di_gid = pip->i_d.di_gid;
> +		xfs_set_gid(ip, VFS_I(pip)->i_gid);

NACK. This is a pure parent->child value inheritence internal to
XFS, and is way below the visibility of the VFS.

>  		if ((pip->i_d.di_mode & S_ISGID) && S_ISDIR(mode)) {
>  			ip->i_d.di_mode |= S_ISGID;
>  		}
> @@ -1241,7 +1243,7 @@ xfs_ialloc(
>  	 */
>  	if ((irix_sgid_inherit) &&
>  	    (ip->i_d.di_mode & S_ISGID) &&
> -	    (!in_group_p((gid_t)ip->i_d.di_gid))) {
> +	    (!in_group_p(VFS_I(ip)->i_gid))) {
>  		ip->i_d.di_mode &= ~S_ISGID;
>  	}

If this needs to be namespace aware, then convert the
ip->i_d.di_gid to the namespace structure dynamically for the call
to in_group_p().

> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 4afb509..db274d4 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -949,8 +949,8 @@ xfs_ioctl_setattr(
>  	 * because the i_*dquot fields will get updated anyway.
>  	 */
>  	if (XFS_IS_QUOTA_ON(mp) && (mask & FSX_PROJID)) {
> -		code = xfs_qm_vop_dqalloc(ip, ip->i_d.di_uid,
> -					 ip->i_d.di_gid, fa->fsx_projid,
> +		code = xfs_qm_vop_dqalloc(ip, VFS_I(ip)->i_uid,
> +					 VFS_I(ip)->i_gid, fa->fsx_projid,
>  					 XFS_QMOPT_PQUOTA, &udqp, &gdqp);

The quota code assumes a direct relationship between the values in
the struct xfs_inode and the dquot ID. It is not a relationship that
namespaces enter into. namespace conversion should happen at the
edge of the filesystem quota subsystem, (i.e. into an xfs_dqid_t)
and the rest of the code left alone.

> @@ -500,13 +500,13 @@ xfs_setattr_nonsize(
>  			uid = iattr->ia_uid;
>  			qflags |= XFS_QMOPT_UQUOTA;
>  		} else {
> -			uid = ip->i_d.di_uid;
> +			uid = VFS_I(ip)->i_uid;
>  		}
>  		if ((mask & ATTR_GID) && XFS_IS_GQUOTA_ON(mp)) {
>  			gid = iattr->ia_gid;
>  			qflags |= XFS_QMOPT_GQUOTA;
>  		}  else {
> -			gid = ip->i_d.di_gid;
> +			gid = VFS_I(ip)->i_gid;
>  		}

Same again - quota IDs are related to the on disk inode value, not
the VFS, namespace aware value.

> @@ -539,8 +539,8 @@ xfs_setattr_nonsize(
>  		 * while we didn't have the inode locked, inode's dquot(s)
>  		 * would have changed also.
>  		 */
> -		iuid = ip->i_d.di_uid;
> -		igid = ip->i_d.di_gid;
> +		iuid = VFS_I(ip)->i_uid;
> +		igid = VFS_I(ip)->i_gid;
>  		gid = (mask & ATTR_GID) ? iattr->ia_gid : igid;
>  		uid = (mask & ATTR_UID) ? iattr->ia_uid : iuid;
>  
> @@ -587,8 +587,7 @@ xfs_setattr_nonsize(
>  				olddquot1 = xfs_qm_vop_chown(tp, ip,
>  							&ip->i_udquot, udqp);
>  			}
> -			ip->i_d.di_uid = uid;
> -			inode->i_uid = uid;
> +			xfs_set_uid(ip, uid);

PLease keep these as separate updates, that way we can see clearly
that we are updating both the VFS inode and the XFS inode here.

> @@ -1155,8 +1153,6 @@ xfs_setup_inode(
>  
>  	inode->i_mode	= ip->i_d.di_mode;
>  	set_nlink(inode, ip->i_d.di_nlink);
> -	inode->i_uid	= ip->i_d.di_uid;
> -	inode->i_gid	= ip->i_d.di_gid;

Which further empahsises the layer violation...

>  	switch (inode->i_mode & S_IFMT) {
>  	case S_IFBLK:
> diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
> index cf5b1d0..a9e07dd 100644
> --- a/fs/xfs/xfs_itable.c
> +++ b/fs/xfs/xfs_itable.c
> @@ -95,8 +95,8 @@ xfs_bulkstat_one_int(
>  	buf->bs_projid_hi = (u16)(ip->i_projid >> 16);
>  	buf->bs_ino = ino;
>  	buf->bs_mode = dic->di_mode;
> -	buf->bs_uid = dic->di_uid;
> -	buf->bs_gid = dic->di_gid;
> +	buf->bs_uid = VFS_I(ip)->i_uid;
> +	buf->bs_gid = VFS_I(ip)->i_gid;

Same as the project ID changes - bulkstat is supposed to return the
raw on disk values, not namespace munged values.

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
