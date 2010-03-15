From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH] block: make CONFIG_BLK_CGROUP visible
Date: Mon, 15 Mar 2010 00:31:43 -0400
Message-ID: <20100315043143.GA7953@unix31.andrew.cmu.edu>
References: <4B9DA6F5.3070606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B9DA6F5.3070606-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, Gui Jianfeng <GuiJianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 11:18:13AM +0800, Li Zefan wrote:
> Make the config visible, so we can choose from CONFIG_BLK_CGROUP=y
> and CONFIG_BLK_CGROUP=m when CONFIG_IOSCHED_CFQ=m.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/Kconfig |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/block/Kconfig b/block/Kconfig
> index 62a5921..906950c 100644
> --- a/block/Kconfig
> +++ b/block/Kconfig
> @@ -78,8 +78,9 @@ config BLK_DEV_INTEGRITY
>  	Protection.  If in doubt, say N.
>  
>  config BLK_CGROUP
> -	tristate
> +	tristate "Block cgroup support"
>  	depends on CGROUPS
> +	depends on CFQ_GROUP_IOSCHED
>  	default n
>  	---help---
>  	Generic block IO controller cgroup interface. This is the common
> @@ -91,7 +92,7 @@ config BLK_CGROUP
>  	to such task groups.
>  
>  config DEBUG_BLK_CGROUP
> -	bool
> +	bool "Block cgroup debugging help"
>  	depends on BLK_CGROUP
>  	default n
>  	---help---
> -- 
> 1.6.3
> 
> 

LGTM.

Acked-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
