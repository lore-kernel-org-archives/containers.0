From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH review 05/16] xfs: Update xfs_ioctl_setattr to handle
	projids in any user namespace
Date: Mon, 29 Jul 2013 17:51:09 +1000
Message-ID: <20130729075109.GF13468__42613.4601388641$1375084592$gmane$org@dastard>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
	<1361149870-27732-5-git-send-email-ebiederm@xmission.com>
	<20130219015550.GJ26694@dastard> <51F616F2.5040906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51F616F2.5040906-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

[ cc xfs list ]

On Mon, Jul 29, 2013 at 03:17:06PM +0800, Gao feng wrote:
> On 02/19/2013 09:55 AM, Dave Chinner wrote:
> > On Sun, Feb 17, 2013 at 05:10:58PM -0800, Eric W. Biederman wrote:
> >> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >>
> >> - Convert the userspace value in fa->fsx_projid into a kprojid and
> >>   store it in the variable projid.
> >> - Verify that xfs can store the projid after it is converted into
> >>   xfs's user namespace.
> >> - Replace uses of fa->fsx_projid with projid throughout
> >>   xfs_ioctl_setattr.
> >>
> >> Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
> >> Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >> Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> >> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> ---
> >>  fs/xfs/xfs_ioctl.c |   26 ++++++++++++++++++--------
> >>  1 files changed, 18 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> >> index 016624b..4a55f50 100644
> >> --- a/fs/xfs/xfs_ioctl.c
> >> +++ b/fs/xfs/xfs_ioctl.c
> >> @@ -925,6 +925,7 @@ xfs_ioctl_setattr(
> >>  	struct xfs_dquot	*gdqp = NULL;
> >>  	struct xfs_dquot	*olddquot = NULL;
> >>  	int			code;
> >> +	kprojid_t		projid = INVALID_PROJID;
> >>  
> >>  	trace_xfs_ioctl_setattr(ip);
> >>  
> >> @@ -934,11 +935,20 @@ xfs_ioctl_setattr(
> >>  		return XFS_ERROR(EIO);
> >>  
> >>  	/*
> >> -	 * Disallow 32bit project ids when projid32bit feature is not enabled.
> >> +	 * Verify the specifid project id is valid.
> >>  	 */
> >> -	if ((mask & FSX_PROJID) && (fa->fsx_projid > (__uint16_t)-1) &&
> >> -			!xfs_sb_version_hasprojid32bit(&ip->i_mount->m_sb))
> >> -		return XFS_ERROR(EINVAL);
> >> +	if (mask & FSX_PROJID) {
> >> +		projid = make_kprojid(current_user_ns(), fa->fsx_projid);
> >> +		if (!projid_valid(projid))
> >> +			return XFS_ERROR(EINVAL);
> >> +
> >> +		/*
> >> +		 * Disallow 32bit project ids when projid32bit feature is not enabled.
> >> +		 */
> >> +		if ((from_kprojid(&init_user_ns, projid) > (__uint16_t)-1) &&
> >> +		    !xfs_sb_version_hasprojid32bit(&ip->i_mount->m_sb))
> >> +			return XFS_ERROR(EINVAL);
> >> +	}
> > 
> > That looks busted. Why does one use current_user_ns() and the other
> > &init_user_ns()?
> > 
> 
> hmm, through this thread had been stopped discussing for a long time, but I'm working on converting
> ids to kids for xfs now, and I want to remove the finial dependenciy for user namespace.

You're duplicating work that is already going on - we've been
talking about this stuff on the XFS list and reviewing patches for
the last 3-4 weeks for this.

http://oss.sgi.com/pipermail/xfs/2013-July/028467.html

Basically, the discussion we are currently having is whether project
IDs should be exposed to user namespaces at all. e.g:

http://oss.sgi.com/pipermail/xfs/2013-July/028497.html
http://oss.sgi.com/pipermail/xfs/2013-July/028551.html

"Basically, until we have worked out *if* project quotas can be used
safely within user namespaces, we need to reject any attempt to use
them from within a user namespace container."

i.e. the whole "project IDs are part of user namespaces because of
quotas" looks like a bad decision to have been made. Project IDs are
independent of users and groups and can be used to account for usage
across discontiguous directory and permission heirarchies, so trying
to contain them to a "user namespace" really matches their
functionality.

> I think maybe just modifying from_kprojid(&init_user_ns, projid) to projid.val here is easier
> to understand.

The problem is not a question of how to implement mappings - it's a
question of how to deal with fundamental impedence mismatch of
user namespaces and project IDs....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
