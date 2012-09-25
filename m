From: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 17/25] userns: Convert minix to use kuid/kgid where
	appropriate
Date: Tue, 25 Sep 2012 17:17:41 +0800
Message-ID: <506176B5.9020104@gmail.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
	<1348141326-23355-17-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-17-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012-9-20 19:41, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/minix/inode.c |   16 ++++++++--------
>  init/Kconfig     |    1 -
>  2 files changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/minix/inode.c b/fs/minix/inode.c
> index 2a503ad..d0e42c6 100644
> --- a/fs/minix/inode.c
> +++ b/fs/minix/inode.c
> @@ -460,8 +460,8 @@ static struct inode *V1_minix_iget(struct inode *inode)
>  		return ERR_PTR(-EIO);
>  	}
>  	inode->i_mode = raw_inode->i_mode;
> -	inode->i_uid = (uid_t)raw_inode->i_uid;
> -	inode->i_gid = (gid_t)raw_inode->i_gid;
> +	i_uid_write(inode, raw_inode->i_uid);
> +	i_gid_write(inode, raw_inode->i_gid);


	i_uid_write(inode, (uid_t)raw_inode->i_uid);
	i_gid_write(inode, (gid_t)raw_inode->i_gid);

is more better?
>  	set_nlink(inode, raw_inode->i_nlinks);
>  	inode->i_size = raw_inode->i_size;
>  	inode->i_mtime.tv_sec = inode->i_atime.tv_sec = inode->i_ctime.tv_sec = raw_inode->i_time;
> @@ -493,8 +493,8 @@ static struct inode *V2_minix_iget(struct inode *inode)
>  		return ERR_PTR(-EIO);
>  	}
>  	inode->i_mode = raw_inode->i_mode;
> -	inode->i_uid = (uid_t)raw_inode->i_uid;
> -	inode->i_gid = (gid_t)raw_inode->i_gid;
> +	i_uid_write(inode, raw_inode->i_uid);
> +	i_gid_write(inode, raw_inode->i_gid);
>  	set_nlink(inode, raw_inode->i_nlinks);
>  	inode->i_size = raw_inode->i_size;
>  	inode->i_mtime.tv_sec = raw_inode->i_mtime;
> @@ -545,8 +545,8 @@ static struct buffer_head * V1_minix_update_inode(struct inode * inode)
>  	if (!raw_inode)
>  		return NULL;
>  	raw_inode->i_mode = inode->i_mode;
> -	raw_inode->i_uid = fs_high2lowuid(inode->i_uid);
> -	raw_inode->i_gid = fs_high2lowgid(inode->i_gid);
> +	raw_inode->i_uid = fs_high2lowuid(i_uid_read(inode));
> +	raw_inode->i_gid = fs_high2lowgid(i_gid_read(inode));
>  	raw_inode->i_nlinks = inode->i_nlink;
>  	raw_inode->i_size = inode->i_size;
>  	raw_inode->i_time = inode->i_mtime.tv_sec;
> @@ -572,8 +572,8 @@ static struct buffer_head * V2_minix_update_inode(struct inode * inode)
>  	if (!raw_inode)
>  		return NULL;
>  	raw_inode->i_mode = inode->i_mode;
> -	raw_inode->i_uid = fs_high2lowuid(inode->i_uid);
> -	raw_inode->i_gid = fs_high2lowgid(inode->i_gid);
> +	raw_inode->i_uid = fs_high2lowuid(i_uid_read(inode));
> +	raw_inode->i_gid = fs_high2lowgid(i_gid_read(inode));
>  	raw_inode->i_nlinks = inode->i_nlink;
>  	raw_inode->i_size = inode->i_size;
>  	raw_inode->i_mtime = inode->i_mtime.tv_sec;
> diff --git a/init/Kconfig b/init/Kconfig
> index 80edba8..c69e085 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -946,7 +946,6 @@ config UIDGID_CONVERTED
>  	depends on HPFS_FS = n
>  	depends on JFFS2_FS = n
>  	depends on JFS_FS = n
> -	depends on MINIX_FS = n
>  	depends on NCP_FS = n
>  	depends on NFSD = n
>  	depends on NFS_FS = n
> 
