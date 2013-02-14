From: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH review 23/85] ocfs2: Convert uid and gids between in core
	and on disk inodes
Date: Thu, 14 Feb 2013 00:35:48 -0800
Message-ID: <20130214083547.GE18408@localhost>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-23-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1360777934-5663-23-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

This has the same problem with two machines in different userspace
namespaces.  Should this be punted to the sysadmin or helped out in the
filesystem?  Do you define this case as unsupported?

Joel

On Wed, Feb 13, 2013 at 09:51:12AM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
> Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/ocfs2/inode.c |   12 ++++++------
>  fs/ocfs2/namei.c |    4 ++--
>  2 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/ocfs2/inode.c b/fs/ocfs2/inode.c
> index d89e08a..f87f9bd 100644
> --- a/fs/ocfs2/inode.c
> +++ b/fs/ocfs2/inode.c
> @@ -269,8 +269,8 @@ void ocfs2_populate_inode(struct inode *inode, struct ocfs2_dinode *fe,
>  	inode->i_generation = le32_to_cpu(fe->i_generation);
>  	inode->i_rdev = huge_decode_dev(le64_to_cpu(fe->id1.dev1.i_rdev));
>  	inode->i_mode = le16_to_cpu(fe->i_mode);
> -	inode->i_uid = le32_to_cpu(fe->i_uid);
> -	inode->i_gid = le32_to_cpu(fe->i_gid);
> +	i_uid_write(inode, le32_to_cpu(fe->i_uid));
> +	i_gid_write(inode, le32_to_cpu(fe->i_gid));
>  
>  	/* Fast symlinks will have i_size but no allocated clusters. */
>  	if (S_ISLNK(inode->i_mode) && !fe->i_clusters) {
> @@ -1259,8 +1259,8 @@ int ocfs2_mark_inode_dirty(handle_t *handle,
>  
>  	fe->i_size = cpu_to_le64(i_size_read(inode));
>  	ocfs2_set_links_count(fe, inode->i_nlink);
> -	fe->i_uid = cpu_to_le32(inode->i_uid);
> -	fe->i_gid = cpu_to_le32(inode->i_gid);
> +	fe->i_uid = cpu_to_le32(i_uid_read(inode));
> +	fe->i_gid = cpu_to_le32(i_gid_read(inode));
>  	fe->i_mode = cpu_to_le16(inode->i_mode);
>  	fe->i_atime = cpu_to_le64(inode->i_atime.tv_sec);
>  	fe->i_atime_nsec = cpu_to_le32(inode->i_atime.tv_nsec);
> @@ -1290,8 +1290,8 @@ void ocfs2_refresh_inode(struct inode *inode,
>  	ocfs2_set_inode_flags(inode);
>  	i_size_write(inode, le64_to_cpu(fe->i_size));
>  	set_nlink(inode, ocfs2_read_links_count(fe));
> -	inode->i_uid = le32_to_cpu(fe->i_uid);
> -	inode->i_gid = le32_to_cpu(fe->i_gid);
> +	i_uid_write(inode, le32_to_cpu(fe->i_uid));
> +	i_gid_write(inode, le32_to_cpu(fe->i_gid));
>  	inode->i_mode = le16_to_cpu(fe->i_mode);
>  	if (S_ISLNK(inode->i_mode) && le32_to_cpu(fe->i_clusters) == 0)
>  		inode->i_blocks = 0;
> diff --git a/fs/ocfs2/namei.c b/fs/ocfs2/namei.c
> index f1fd074..04ee1b5 100644
> --- a/fs/ocfs2/namei.c
> +++ b/fs/ocfs2/namei.c
> @@ -512,8 +512,8 @@ static int __ocfs2_mknod_locked(struct inode *dir,
>  	fe->i_suballoc_loc = cpu_to_le64(suballoc_loc);
>  	fe->i_suballoc_bit = cpu_to_le16(suballoc_bit);
>  	fe->i_suballoc_slot = cpu_to_le16(inode_ac->ac_alloc_slot);
> -	fe->i_uid = cpu_to_le32(inode->i_uid);
> -	fe->i_gid = cpu_to_le32(inode->i_gid);
> +	fe->i_uid = cpu_to_le32(i_uid_read(inode));
> +	fe->i_gid = cpu_to_le32(i_gid_read(inode));
>  	fe->i_mode = cpu_to_le16(inode->i_mode);
>  	if (S_ISCHR(inode->i_mode) || S_ISBLK(inode->i_mode))
>  		fe->id1.dev1.i_rdev = cpu_to_le64(huge_encode_dev(dev));
> -- 
> 1.7.5.4
> 

-- 

"Sometimes when reading Goethe I have the paralyzing suspicion
 that he is trying to be funny."
         - Guy Davenport

			http://www.jlbec.org/
			jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org
