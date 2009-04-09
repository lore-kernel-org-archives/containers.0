From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 11/36] add generic checkpoint f_op to ext fses
Date: Wed, 8 Apr 2009 20:59:26 -0500
Message-ID: <20090409015926.GA20112@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-12-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239107264-21775-12-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> This marks ext[234] as being checkpointable.  There will be many
> more to do this to, but this is a start.
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  fs/ext2/dir.c  |    1 +
>  fs/ext2/file.c |    2 ++
>  fs/ext3/dir.c  |    1 +
>  fs/ext3/file.c |    1 +
>  fs/ext4/dir.c  |    1 +
>  fs/ext4/file.c |    1 +
>  6 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
> index 2999d72..4f1dd79 100644
> --- a/fs/ext2/dir.c
> +++ b/fs/ext2/dir.c
> @@ -721,4 +721,5 @@ const struct file_operations ext2_dir_operations = {
>  	.compat_ioctl	= ext2_compat_ioctl,
>  #endif
>  	.fsync		= ext2_sync_file,
> +	.checkpoint	= generic_file_checkpoint,

The checkpoint() method is only defined in struct file_operations if
CONFIG_CHECKPOINT=y.  So this can't possibly compile when
CONFIG_CHECKPOINT=n...

>  };
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 45ed071..e1731c5 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -58,6 +58,7 @@ const struct file_operations ext2_file_operations = {
>  	.fsync		= ext2_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +	.checkpoint	= generic_file_checkpoint,
>  };
> 
>  #ifdef CONFIG_EXT2_FS_XIP
> @@ -73,6 +74,7 @@ const struct file_operations ext2_xip_file_operations = {
>  	.open		= generic_file_open,
>  	.release	= ext2_release_file,
>  	.fsync		= ext2_sync_file,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  #endif
> 
> diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
> index 5853f44..aa579e1 100644
> --- a/fs/ext3/dir.c
> +++ b/fs/ext3/dir.c
> @@ -48,6 +48,7 @@ const struct file_operations ext3_dir_operations = {
>  #endif
>  	.fsync		= ext3_sync_file,	/* BKL held */
>  	.release	= ext3_release_dir,
> +	.checkpoint	= generic_file_checkpoint,
>  };
> 
> 
> diff --git a/fs/ext3/file.c b/fs/ext3/file.c
> index 3be1e06..45f73fa 100644
> --- a/fs/ext3/file.c
> +++ b/fs/ext3/file.c
> @@ -122,6 +122,7 @@ const struct file_operations ext3_file_operations = {
>  	.fsync		= ext3_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +	.checkpoint	= generic_file_checkpoint,
>  };
> 
>  const struct inode_operations ext3_file_inode_operations = {
> diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
> index 2df2e40..9baf728 100644
> --- a/fs/ext4/dir.c
> +++ b/fs/ext4/dir.c
> @@ -48,6 +48,7 @@ const struct file_operations ext4_dir_operations = {
>  #endif
>  	.fsync		= ext4_sync_file,
>  	.release	= ext4_release_dir,
> +	.checkpoint	= generic_file_checkpoint,
>  };
> 
> 
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index f731cb5..bd84dce 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -156,6 +156,7 @@ const struct file_operations ext4_file_operations = {
>  	.fsync		= ext4_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +	.checkpoint	= generic_file_checkpoint,
>  };
> 
>  const struct inode_operations ext4_file_inode_operations = {
> -- 
> 1.5.4.3
