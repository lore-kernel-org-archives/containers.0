From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 5/5] memcg: dirty pages instrumentation
Date: Mon, 15 Mar 2010 11:31:04 +0900
Message-ID: <20100315113104.b208571c.kamezawa.hiroyu__49013.0525817678$1268620533$gmane$org@jp.fujitsu.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-6-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268609202-15581-6-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Greg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Peter-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 15 Mar 2010 00:26:42 +0100
Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:

> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> [ NOTE: for now do not account WritebackTmp pages (FUSE) and NILFS2
> bounce pages. This depends on charging also bounce pages per cgroup. ]
> 
> As a bonus, make determine_dirtyable_memory() static again: this
> function isn't used anymore outside page writeback.
> 
> Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

A nitpick.

> @@ -660,6 +705,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	unsigned long dirty_thresh;
>  
>          for ( ; ; ) {
> +		unsigned long dirty;
> +
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
>  
>                  /*
> @@ -668,10 +715,10 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		dirty = get_dirty_writeback_pages();
> +		if (dirty <= dirty_thresh)
> +			break;
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/*
>  		 * The caller might hold locks which can prevent IO completion

"dirty" seems not to be necessary.
	if (get_dirty_writeback_pages() < dirty_thresh) ?

Thanks,
-Kame
