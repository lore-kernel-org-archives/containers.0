From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] block: make CONFIG_BLK_CGROUP visible
Date: Mon, 15 Mar 2010 09:21:49 -0400
Message-ID: <20100315132149.GA21127@redhat.com>
References: <4B9DA6F5.3070606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B9DA6F5.3070606@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Gui Jianfeng <GuiJianfeng@cn.fujitsu.com>, Ben Blum <bblum@andrew.cmu.edu>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 11:18:13AM +0800, Li Zefan wrote:
> Make the config visible, so we can choose from CONFIG_BLK_CGROUP=y
> and CONFIG_BLK_CGROUP=m when CONFIG_IOSCHED_CFQ=m.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
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

Hi Gui,

This part makes sense. If need to give user an option to keep BLK_CGROUP=y
even if CFQ=m.

>  	---help---
>  	Generic block IO controller cgroup interface. This is the common
> @@ -91,7 +92,7 @@ config BLK_CGROUP
>  	to such task groups.
>  
>  config DEBUG_BLK_CGROUP
> -	bool
> +	bool "Block cgroup debugging help"


Why are you making DEBUG_BLK_CGROUP this as a user visible/configurable
option? This is already controlled by DEBUG_CFQ_IOSCHED. If you don't want
the DEBUG overhead, just set DEBUG_CFQ_IOSCHED=n and DEBUG_BLK_CGROUP will
not be selected? Making it user visible does not seem to be buying us
anything?

Thanks
Vivek
