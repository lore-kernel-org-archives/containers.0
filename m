From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH 3/4] dcache set size
Date: Sun, 31 Jul 2011 11:38:43 +1000
Message-ID: <20110731013843.GN5404__19989.4983241849$1312076362$gmane$org@dastard>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311947059-17209-4-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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

On Fri, Jul 29, 2011 at 05:44:18PM +0400, Glauber Costa wrote:
> Simple patch that provides a function allowing its caller to set
> the maximum number of dentries that can exist at the same time
> at a given super block. Will be used in a later patch.

Pretty simple - probably better to put it in the patch that uses it,
I think.

> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> ---
>  fs/dcache.c            |   12 ++++++++++++
>  include/linux/dcache.h |    1 +
>  2 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 3bdb106..4369aa2 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1202,6 +1202,18 @@ static int dcache_mem_check(struct super_block *sb)
>  	return -ENOMEM;
>  }
>  
> +int vfs_set_dcache_size(struct super_block *sb, int size)
> +{
> +	unsigned long dr = percpu_counter_sum_positive(&sb->s_nr_dentry); 
> +
> +	if (size != sb->s_nr_dentry_max)
> +		prune_dcache_sb(sb, dr - size);

And why shrink if the new size > the current sb->s_nr_dentry_max?

And what happens when size > dr?

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
