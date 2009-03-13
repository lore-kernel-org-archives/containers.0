From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 05/11] add generic checkpoint f_op to ext fses
Date: Thu, 12 Mar 2009 22:50:19 -0400
Message-ID: <49B9C9EB.90408@cs.columbia.edu>
References: <20090305163857.0C18F3FD@kernel> <20090305163904.D9CFC631@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305163904.D9CFC631@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Note that as far as I understand, ext4 does _not_ support a "relink"
operation. By "re-link" I mean an operation that re-links an (orphan)
inode to a filename.  (By "orphan" I mean a file that was opened and
unlinked, so it does not appear in any directory anymore).

This feature is very useful to efficiently checkpoint unlinked files.

Oren.


Dave Hansen wrote:
> This marks ext[234] as being checkpointable.  There will be many
> more to do this to, but this is a start.
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
> 
>  linux-2.6.git-dave/fs/ext2/dir.c  |    1 +
>  linux-2.6.git-dave/fs/ext2/file.c |    2 ++
>  linux-2.6.git-dave/fs/ext3/dir.c  |    1 +
>  linux-2.6.git-dave/fs/ext3/file.c |    1 +
>  linux-2.6.git-dave/fs/ext4/dir.c  |    1 +
>  linux-2.6.git-dave/fs/ext4/file.c |    1 +
>  6 files changed, 7 insertions(+)
> 
> diff -puN fs/ext2/dir.c~add-stupid-checkpoint-to-lots-of-fses-take0 fs/ext2/dir.c
> --- linux-2.6.git/fs/ext2/dir.c~add-stupid-checkpoint-to-lots-of-fses-take0	2009-03-05 08:37:01.000000000 -0800
> +++ linux-2.6.git-dave/fs/ext2/dir.c	2009-03-05 08:37:01.000000000 -0800
> @@ -721,4 +721,5 @@ const struct file_operations ext2_dir_op
>  	.compat_ioctl	= ext2_compat_ioctl,
>  #endif
>  	.fsync		= ext2_sync_file,
> +	.checkpoint	= generic_file_checkpoint,
>  };
> diff -puN fs/ext2/file.c~add-stupid-checkpoint-to-lots-of-fses-take0 fs/ext2/file.c
> --- linux-2.6.git/fs/ext2/file.c~add-stupid-checkpoint-to-lots-of-fses-take0	2009-03-05 08:37:01.000000000 -0800
> +++ linux-2.6.git-dave/fs/ext2/file.c	2009-03-05 08:37:01.000000000 -0800
> @@ -58,6 +58,7 @@ const struct file_operations ext2_file_o
>  	.fsync		= ext2_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  
>  #ifdef CONFIG_EXT2_FS_XIP
> @@ -73,6 +74,7 @@ const struct file_operations ext2_xip_fi
>  	.open		= generic_file_open,
>  	.release	= ext2_release_file,
>  	.fsync		= ext2_sync_file,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  #endif
>  
> diff -puN fs/ext3/dir.c~add-stupid-checkpoint-to-lots-of-fses-take0 fs/ext3/dir.c
> --- linux-2.6.git/fs/ext3/dir.c~add-stupid-checkpoint-to-lots-of-fses-take0	2009-03-05 08:37:01.000000000 -0800
> +++ linux-2.6.git-dave/fs/ext3/dir.c	2009-03-05 08:37:01.000000000 -0800
> @@ -48,6 +48,7 @@ const struct file_operations ext3_dir_op
>  #endif
>  	.fsync		= ext3_sync_file,	/* BKL held */
>  	.release	= ext3_release_dir,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  
>  
> diff -puN fs/ext3/file.c~add-stupid-checkpoint-to-lots-of-fses-take0 fs/ext3/file.c
> --- linux-2.6.git/fs/ext3/file.c~add-stupid-checkpoint-to-lots-of-fses-take0	2009-03-05 08:37:01.000000000 -0800
> +++ linux-2.6.git-dave/fs/ext3/file.c	2009-03-05 08:37:01.000000000 -0800
> @@ -122,6 +122,7 @@ const struct file_operations ext3_file_o
>  	.fsync		= ext3_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  
>  const struct inode_operations ext3_file_inode_operations = {
> diff -puN fs/ext4/dir.c~add-stupid-checkpoint-to-lots-of-fses-take0 fs/ext4/dir.c
> --- linux-2.6.git/fs/ext4/dir.c~add-stupid-checkpoint-to-lots-of-fses-take0	2009-03-05 08:37:01.000000000 -0800
> +++ linux-2.6.git-dave/fs/ext4/dir.c	2009-03-05 08:37:01.000000000 -0800
> @@ -48,6 +48,7 @@ const struct file_operations ext4_dir_op
>  #endif
>  	.fsync		= ext4_sync_file,
>  	.release	= ext4_release_dir,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  
>  
> diff -puN fs/ext4/file.c~add-stupid-checkpoint-to-lots-of-fses-take0 fs/ext4/file.c
> --- linux-2.6.git/fs/ext4/file.c~add-stupid-checkpoint-to-lots-of-fses-take0	2009-03-05 08:37:01.000000000 -0800
> +++ linux-2.6.git-dave/fs/ext4/file.c	2009-03-05 08:37:01.000000000 -0800
> @@ -156,6 +156,7 @@ const struct file_operations ext4_file_o
>  	.fsync		= ext4_sync_file,
>  	.splice_read	= generic_file_splice_read,
>  	.splice_write	= generic_file_splice_write,
> +	.checkpoint	= generic_file_checkpoint,
>  };
>  
>  const struct inode_operations ext4_file_inode_operations = {
> _
> 
