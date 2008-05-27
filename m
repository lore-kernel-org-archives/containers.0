From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC 2/4] memcg: high-low watermark
Date: Tue, 27 May 2008 15:51:40 +0800
Message-ID: <483BBD8C.3040803@cn.fujitsu.com>
References: <20080527140116.fb04b06b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080527140703.97b69ed3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080527140703.97b69ed3.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, "xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> Add high/low watermarks to res_counter.
> *This patch itself has no behavior changes to memory resource controller.
> 
> Changelog: very old one -> this one (v1)
>  - watarmark_state is removed and all state check is done under lock.
>  - changed res_counter_charge() interface. The only user is memory
>    resource controller. Anyway, returning -ENOMEM here is a bit starnge.
>  - Added watermark enable/disable flag for someone don't want watermarks.
>  - Restarted against 2.6.25-mm1.
>  - some subsystem which doesn't want high-low watermark can work withou it.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> From: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
> ---
>  include/linux/res_counter.h |   41 ++++++++++++++++++++++++---
>  kernel/res_counter.c        |   66 ++++++++++++++++++++++++++++++++++++++++----
>  mm/memcontrol.c             |    2 -
>  3 files changed, 99 insertions(+), 10 deletions(-)
> 
> Index: mm-2.6.26-rc2-mm1/include/linux/res_counter.h
> ===================================================================
> --- mm-2.6.26-rc2-mm1.orig/include/linux/res_counter.h
> +++ mm-2.6.26-rc2-mm1/include/linux/res_counter.h
> @@ -16,6 +16,16 @@
>  #include <linux/cgroup.h>
>  
>  /*
> + * status of resource coutner's usage.
> + */
> +enum res_state {
> +	RES_BELOW_LOW,	/* usage < lwmark */

It seems it's 'usage <= lwmark'

> +	RES_BELOW_HIGH,	/* lwmark < usage < hwmark */

and 'lwmark < usage <= hwmark'

> +	RES_BELOW_LIMIT,	/* hwmark < usage < limit. */

and 'hwmark < usage <= limit'
