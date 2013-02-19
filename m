From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH review 02/16] xfs: Store projectid as a single variable.
Date: Tue, 19 Feb 2013 11:36:08 +1100
Message-ID: <20130219003608.GF26694__40908.180588349$1361234199$gmane$org@dastard>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
	<1361149870-27732-2-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1361149870-27732-2-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Sun, Feb 17, 2013 at 05:10:55PM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> xfs_get_projid is torturous to read and it will not work at all when
> project ids are stored in a kprojid_t.  So add a i_projid to
> xfs_inode, that is cheap to read and can handle future needs, and
> update all callers of xfs_get_projid to use i_projid.
> 
> Retain xfs_set_projid to handle the needed double updates, as there
> are now two places the value needs to be set.
> 
> In xfs_iread after filling in i_d drom the on-disk inode update the
> new i_projid field.
> 
> Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
> Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/xfs/xfs_icache.c   |    2 +-
>  fs/xfs/xfs_inode.c    |    6 +++++-
>  fs/xfs/xfs_inode.h    |    7 ++-----
>  fs/xfs/xfs_ioctl.c    |    6 +++---
>  fs/xfs/xfs_iops.c     |    2 +-
>  fs/xfs/xfs_itable.c   |    4 ++--
>  fs/xfs/xfs_qm.c       |   10 +++++-----
>  fs/xfs/xfs_qm_bhv.c   |    2 +-
>  fs/xfs/xfs_rename.c   |    2 +-
>  fs/xfs/xfs_vnodeops.c |    6 +++---
>  10 files changed, 24 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> index 96e344e..4f109ca 100644
> --- a/fs/xfs/xfs_icache.c
> +++ b/fs/xfs/xfs_icache.c
> @@ -1210,7 +1210,7 @@ xfs_inode_match_id(
>  		return 0;
>  
>  	if (eofb->eof_flags & XFS_EOF_FLAGS_PRID &&
> -	    xfs_get_projid(ip) != eofb->eof_prid)
> +	    ip->i_projid != eofb->eof_prid)
>  		return 0;

Please retain the xfs_get_projid(ip) wrapper and do all the
necessary conversions via that wrapper. We don't need a second copy
of the project ID to support namespace aware project ID support.

>  	return 1;
> diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
> index 66282dc..51c2597 100644
> --- a/fs/xfs/xfs_inode.c
> +++ b/fs/xfs/xfs_inode.c
> @@ -1013,6 +1013,10 @@ xfs_iread(
>  	 */
>  	if (dip->di_mode) {
>  		xfs_dinode_from_disk(&ip->i_d, dip);
> +
> +		ip->i_projid = ((projid_t)ip->i_d.di_projid_hi << 16) |
> +					  ip->i_d.di_projid_lo;
> +

This does not belong here. At minimum, it would need to be in
xfs_iformat(). Further, if there is a requirement it is initialised
correctly, it needs to be zeroed in xfs_inode_alloc() where we pull
a newly allocated inode out of the slab.

As it is, however, having read further through the patches, I can't
really see why we need even need a separate variable - the
conversions shoul dbe done at the edge of the filesystem (i.e. VFS
and ioctl interfaces, and the core of the filesystem left completely
untouched.

>  static inline void
>  xfs_set_projid(struct xfs_inode *ip,
>  		prid_t projid)
>  {
> +	ip->i_projid = projid;
>  	ip->i_d.di_projid_hi = (__uint16_t) (projid >> 16);
>  	ip->i_d.di_projid_lo = (__uint16_t) (projid & 0xffff);
>  }

As all you are doing is introduing a requirement that we keep two
variables in sync and increase the size of the struct xfs_inode
unnecessarily. History says this sort of duplication is a source of
subtle bugs....

> diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
> index 2ea7d40..cf5b1d0 100644
> --- a/fs/xfs/xfs_itable.c
> +++ b/fs/xfs/xfs_itable.c
> @@ -91,8 +91,8 @@ xfs_bulkstat_one_int(
>  	 * further change.
>  	 */
>  	buf->bs_nlink = dic->di_nlink;
> -	buf->bs_projid_lo = dic->di_projid_lo;
> -	buf->bs_projid_hi = dic->di_projid_hi;
> +	buf->bs_projid_lo = (u16)(ip->i_projid & 0xffff);
> +	buf->bs_projid_hi = (u16)(ip->i_projid >> 16);

There is no need for this change at all. Even if we have a second
variable, the two are in sync and of reading from the dic is
perfectly OK.

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
