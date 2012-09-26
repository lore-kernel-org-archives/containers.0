From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 10/14] userns: Convert s390 hypfs to use kuid and kgid
	where appropriate
Date: Wed, 26 Sep 2012 12:52:24 -0500
Message-ID: <20120926175224.GC30620__3934.19583929262$1348681965$gmane$org@sergelap>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<1348187330-6616-10-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1348187330-6616-10-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
> Cc: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  arch/s390/hypfs/inode.c |   20 ++++++++++++++------
>  1 files changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
> index 6767b43..124ec1a 100644
> --- a/arch/s390/hypfs/inode.c
> +++ b/arch/s390/hypfs/inode.c
> @@ -31,8 +31,8 @@ static struct dentry *hypfs_create_update_file(struct super_block *sb,
>  					       struct dentry *dir);
>  
>  struct hypfs_sb_info {
> -	uid_t uid;			/* uid used for files and dirs */
> -	gid_t gid;			/* gid used for files and dirs */
> +	kuid_t uid;			/* uid used for files and dirs */
> +	kgid_t gid;			/* gid used for files and dirs */
>  	struct dentry *update_file;	/* file to trigger update */
>  	time_t last_update;		/* last update time in secs since 1970 */
>  	struct mutex lock;		/* lock to protect update process */
> @@ -229,6 +229,8 @@ static int hypfs_parse_options(char *options, struct super_block *sb)
>  {
>  	char *str;
>  	substring_t args[MAX_OPT_ARGS];
> +	kuid_t uid;
> +	kgid_t gid;
>  
>  	if (!options)
>  		return 0;
> @@ -243,12 +245,18 @@ static int hypfs_parse_options(char *options, struct super_block *sb)
>  		case opt_uid:
>  			if (match_int(&args[0], &option))
>  				return -EINVAL;
> -			hypfs_info->uid = option;
> +			uid = make_kuid(current_user_ns(), option);
> +			if (!uid_valid(uid))
> +				return -EINVAL;
> +			hypfs_info->uid = uid;
>  			break;
>  		case opt_gid:
>  			if (match_int(&args[0], &option))
>  				return -EINVAL;
> -			hypfs_info->gid = option;
> +			gid = make_kgid(current_user_ns(), option);
> +			if (!gid_valid(gid))
> +				return -EINVAL;
> +			hypfs_info->gid = gid;
>  			break;
>  		case opt_err:
>  		default:
> @@ -263,8 +271,8 @@ static int hypfs_show_options(struct seq_file *s, struct dentry *root)
>  {
>  	struct hypfs_sb_info *hypfs_info = root->d_sb->s_fs_info;
>  
> -	seq_printf(s, ",uid=%u", hypfs_info->uid);
> -	seq_printf(s, ",gid=%u", hypfs_info->gid);
> +	seq_printf(s, ",uid=%u", from_kuid_munged(&init_user_ns, hypfs_info->uid));
> +	seq_printf(s, ",gid=%u", from_kgid_munged(&init_user_ns, hypfs_info->gid));
>  	return 0;
>  }
>  
> -- 
> 1.7.5.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
