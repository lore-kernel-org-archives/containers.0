From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH 4/4] parse options in the vfs level
Date: Sun, 31 Jul 2011 11:34:56 +1000
Message-ID: <20110731013456.GM5404__35200.1890344129$1312076140$gmane$org@dastard>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311947059-17209-5-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 29, 2011 at 05:44:19PM +0400, Glauber Costa wrote:
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

IMO, the whole point of having a configurable cache size maximum is
that is can be changed at runtime. Tying it to mount options is a
painful way to acheive that because the only way to change it would
be via a remount command.

I'm not sure what the best API is, but I'd prefer something that is
specific to a superblock, not a vfs mount. Perhaps something in
/sys/fs?

> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> ---
>  fs/namespace.c |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 89 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 22bfe82..11ce45d 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -31,6 +31,7 @@
>  #include <linux/idr.h>
>  #include <linux/fs_struct.h>
>  #include <linux/fsnotify.h>
> +#include <linux/parser.h>
>  #include <asm/uaccess.h>
>  #include <asm/unistd.h>
>  #include "pnode.h"
> @@ -2271,6 +2272,82 @@ int copy_mount_string(const void __user *data, char **where)
>  	return 0;
>  }
>  
> +static const match_table_t tokens = {
> +	{1, "vfs_dcache_size=%u"},
> +};
> +
> +struct vfs_options {
> +	unsigned long vfs_dcache_size;
> +};
> +
> +/**
> + * Generic option parsing for the VFS.
> + *
> + * Since most of the filesystems already do their own option parsing, and with
> + * very few code shared between them, this function strips out any options that
> + * we succeed in parsing ourselves. Passing them forward would just give the
> + * underlying fs an option it does not expect, leading it to fail.
> + *
> + * We don't yet have a pointer to the super block as well, since this is
> + * pre-mount. We accumulate in struct vfs_options whatever data we collected,
> + * and act on it later.
> + */
> +static int vfs_parse_options(char *options, struct vfs_options *ops)
> +{
> +	substring_t args[MAX_OPT_ARGS];
> +	unsigned int option;
> +	char *p;
> +	char *opt;
> +	char *start = NULL;
> +	int ret;
> +	
> +	if (!options)
> +		return 0;
> +
> +	opt = kstrdup(options, GFP_KERNEL);
> +	if (!opt)
> +		return 1;
> +	
> +	ret = 1;
> +
> +	start = opt;
> +	while ((p = strsep(&opt, ",")) != NULL) {
> +		int token;
> +		if (!*p)
> +			continue;
> +
> +		/*
> +		 * Initialize args struct so we know whether arg was
> +		 * found; some options take optional arguments.
> +		 */
> +		args[0].to = args[0].from = 0;
> +		token = match_token(p, tokens, args);
> +		switch (token) {
> +		case 1:
> +			if (!args[0].from)
> +				break;
> +
> +			if (match_int(&args[0], &option))
> +				break;
> +			else

No need fo the else.

> +				ops->vfs_dcache_size = option;

Bounds checking? What are valid values? e.g. setting it to a
negative number would be bad, as would a number that is too small
(e.g. 1)....

> +
> +			ret = 0;
> +			if (!opt) /* it is the last option listed */
> +				*(options + (p - start)) = '\0';
> +			else
> +				strcpy(options + (p - start), opt);

What's this for? I don't see any of the other mount option code
doing this sort of thing...

> @@ -2350,6 +2434,11 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
>  	else
>  		retval = do_new_mount(&path, type_page, flags, mnt_flags,
>  				      dev_name, data_page);
> +
> +	if (!retval)
> +		vfs_set_dcache_size(path.mnt->mnt_sb,
> +				    vfs_options.vfs_dcache_size);
> +			

Hmmmm -  doesn't that mean bind mounts will override the value for
the original, underlying filesytem mount? Isn't that a bad thing to
do? i.e. the limiting is supposed to be per-sb, not per-vfsmnt?

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
