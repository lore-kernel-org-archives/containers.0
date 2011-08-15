From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v3 4/4] parse options in the vfs level
Date: Mon, 15 Aug 2011 17:09:32 +1000
Message-ID: <20110815070932.GF26978__5365.15316130153$1313392213$gmane$org@dastard>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1313334832-1150-5-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Aug 14, 2011 at 07:13:52PM +0400, Glauber Costa wrote:
> This patch introduces a simple generic vfs option parser.
> Right now, the only option we have is to limit the size of the dcache.
> 
> So any user that wants to have a dcache entries limit, can specify:
> 
>   mount -o whatever_options,vfs_dcache_size=XXX <dev> <mntpoint>
> 
> It is supposed to work well with remounts, allowing it to change
> multiple over the course of the filesystem's lifecycle.
> 
> I find mount a natural interface for handling filesystem options,
> so that's what I've choosen. Feel free to yell at it at will if
> you disagree.

It's already been noted by both myself and Al that there is not a
1:1 mapping between mount point and superblocks....

> @@ -2350,6 +2449,12 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
>  	else
>  		retval = do_new_mount(&path, type_page, flags, mnt_flags,
>  				      dev_name, data_page);
> +
> +	/* bind mounts get to respect their parents decision */
> +	if (!retval && !(flags & MS_BIND))
> +		vfs_set_dcache_size(path.mnt->mnt_sb,
> +				    vfs_options.vfs_dcache_size);
> +			

And I'm not sure that silently ignoring it in certain cases
is the best way around that problem.

>  dput_out:
>  	path_put(&path);
>  	return retval;
> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index d37d2a7..1a309f3 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -251,6 +251,10 @@ extern int d_invalidate(struct dentry *);
>  
>  /* only used at mount-time */
>  extern struct dentry * d_alloc_root(struct inode *);
> +extern int vfs_set_dcache_size(struct super_block *sb, int size);
> +
> +#define DCACHE_MIN_SIZE 1024
> +extern int vfs_set_dcache_size(struct super_block *sb, int size);

Where did this minimum size come from and why was that figure
chosen? Needs documenting.

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
