From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] ext2: fix return values on parse_options() failure
Date: Tue, 9 Oct 2012 08:29:50 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1210090819590.11244@dhcp-1-104.brq.redhat.com>
References: <5073B9C4.9070009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5073B9C4.9070009-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 9 Oct 2012, Zhao Hongjiang wrote:

> Date: Tue, 09 Oct 2012 13:44:36 +0800
> From: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> To: jack-AlSwsSmVLrQ@public.gmane.org
> Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
>     Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
>     containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Subject: [PATCH] ext2: fix return values on parse_options() failure
> 
> From: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> parse_options() in ext2 should return 0 when parse the mount options fails.
> 
> Signed-off-by: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Reviewed-by: Lukas Czerner <lczerner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Thanks!
-Lukas

> ---
>  fs/ext2/super.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/ext2/super.c b/fs/ext2/super.c
> index 6c205d0..fa04d02 100644
> --- a/fs/ext2/super.c
> +++ b/fs/ext2/super.c
> @@ -469,7 +469,7 @@ static int parse_options(char *options, struct super_block *sb)
>  			uid = make_kuid(current_user_ns(), option);
>  			if (!uid_valid(uid)) {
>  				ext2_msg(sb, KERN_ERR, "Invalid uid value %d", option);
> -				return -1;
> +				return 0;
> 
>  			}
>  			sbi->s_resuid = uid;
> @@ -480,7 +480,7 @@ static int parse_options(char *options, struct super_block *sb)
>  			gid = make_kgid(current_user_ns(), option);
>  			if (!gid_valid(gid)) {
>  				ext2_msg(sb, KERN_ERR, "Invalid gid value %d", option);
> -				return -1;
> +				return 0;
>  			}
>  			sbi->s_resgid = gid;
>  			break;
> -- 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
