From: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH review 25/85] ocfs2: Compare kuids and kgids using uid_eq
	and gid_eq
Date: Thu, 14 Feb 2013 00:37:49 -0800
Message-ID: <20130214083748.GF18408@localhost>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-25-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1360777934-5663-25-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 13, 2013 at 09:51:14AM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
> Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/ocfs2/file.c         |    8 ++++----
>  fs/ocfs2/refcounttree.c |    2 +-
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
> index 8ee9332..0a2924a 100644
> --- a/fs/ocfs2/file.c
> +++ b/fs/ocfs2/file.c
> @@ -1175,14 +1175,14 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
>  		}
>  	}
>  
> -	if ((attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
> -	    (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid)) {
> +	if ((attr->ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)) ||
> +	    (attr->ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid))) {

Will the code work if built just before this patch?  IOW, does the
original comparison (attr->ia_gid != inode->i_gid) work when the system
is in the init_user_namespace?  If not, then the previous patches are
not leaving a functional filesystem.

Joel

>  		/*
>  		 * Gather pointers to quota structures so that allocation /
>  		 * freeing of quota structures happens here and not inside
>  		 * dquot_transfer() where we have problems with lock ordering
>  		 */
> -		if (attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid
> +		if (attr->ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)
>  		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
>  		    OCFS2_FEATURE_RO_COMPAT_USRQUOTA)) {
>  			transfer_to[USRQUOTA] = dqget(sb, make_kqid_uid(attr->ia_uid));
> @@ -1191,7 +1191,7 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
>  				goto bail_unlock;
>  			}
>  		}
> -		if (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid
> +		if (attr->ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid)
>  		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
>  		    OCFS2_FEATURE_RO_COMPAT_GRPQUOTA)) {
>  			transfer_to[GRPQUOTA] = dqget(sb, make_kqid_gid(attr->ia_gid));
> diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
> index 30a0550..934a4ac 100644
> --- a/fs/ocfs2/refcounttree.c
> +++ b/fs/ocfs2/refcounttree.c
> @@ -4407,7 +4407,7 @@ static int ocfs2_vfs_reflink(struct dentry *old_dentry, struct inode *dir,
>  	 * rights to do so.
>  	 */
>  	if (preserve) {
> -		if ((current_fsuid() != inode->i_uid) && !capable(CAP_CHOWN))
> +		if (!uid_eq(current_fsuid(), inode->i_uid) && !capable(CAP_CHOWN))
>  			return -EPERM;
>  		if (!in_group_p(inode->i_gid) && !capable(CAP_CHOWN))
>  			return -EPERM;
> -- 
> 1.7.5.4
> 

-- 

"Where are my angels?
 Where's my golden one?
 And where is my hope
 Now that my heroes are gone?"

			http://www.jlbec.org/
			jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org
