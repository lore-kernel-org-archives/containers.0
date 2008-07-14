From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Mon, 14 Jul 2008 15:37:17 +0200
Message-ID: <1216042637.12595.76.camel__36081.3063839034$1216042745$gmane$org@twins>
References: <20080709060034.0CB2D5A29@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080709060034.0CB2D5A29-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-07-09 at 15:00 +0900, YAMAMOTO Takashi wrote:
> hi,
> 
> the following patch is a simple implementation of
> dirty balancing for cgroups.  any comments?
> 
> it depends on the following fix:
> 	http://lkml.org/lkml/2008/7/8/428
> 
> YAMAMOTO Takashi
> 
> 
> Signed-off-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> ---

Yamamoto-san,

> @@ -408,7 +412,11 @@ get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
>  
>  		*pbdi_dirty = bdi_dirty;
>  		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
> -		task_dirty_limit(current, pbdi_dirty);
> +		task_dirty = *pbdi_dirty;
> +		task_dirty_limit(current, &task_dirty);
> +		cgroup_dirty = *pbdi_dirty;
> +		memdirtylimitcgroup_dirty_limit(current, &cgroup_dirty);
> +		*pbdi_dirty = min(task_dirty, cgroup_dirty);
>  	}
>  }

I think this is wrong - is basically breaks task dirty throttling within
groups. You'd need a multiplicative operation, something like:

  bdi_dirty = dirty * p(bdi) * p(cgroup) * (1 - p(task))

However then we still have problems... see the next email further down
the thread.
