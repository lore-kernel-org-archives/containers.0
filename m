From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH review 07/16] xfs: Update ioctl(XFS_IOC_FREE_EOFBLOCKS)
	to handle callers in any userspace
Date: Tue, 19 Feb 2013 12:48:40 +1100
Message-ID: <20130219014840.GI26694@dastard>
References: <87txpaph4n.fsf@xmission.com>
	<1361149870-27732-1-git-send-email-ebiederm@xmission.com>
	<1361149870-27732-7-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1361149870-27732-7-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Sun, Feb 17, 2013 at 05:11:00PM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> - Modify the ioctl to convert from uids, gid, and projids in the
>   current user namespace to kuids, kgids, and kprojids, and to report
>   an error if the conversion fails.

Please just convert to xfs_dqid_t at the interface.

> - Create struct xfs_internal_eofblocks to hold the same information as
>   struct xfs_eofblocks but with uids, gids, and projids stored as
>   kuids, kgids, and kprojids preventing confusion.

No need. Just convert the struct xfs_eof_blocks to define them all
as xfs_dqid_t and convert them in place to the type that is
compatible with the XFS core use of these fields (i.e. comparing
them with the on-disk inode uid/gid/prid values).

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
