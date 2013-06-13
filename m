From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/11] cgroup: clean up css_[try]get() and css_put()
Date: Thu, 13 Jun 2013 10:38:14 +0800
Message-ID: <51B93096.5060702@huawei.com>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
	<1371070996-20613-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371070996-20613-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/13 5:03, Tejun Heo wrote:
> * __css_get() isn't used by anyone.  Fold it into css_get().
> 
> * Add proper function comments to all css reference functions.
> 
> This patch is purely cosmetic.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  include/linux/cgroup.h | 48 ++++++++++++++++++++++++------------------------
>  1 file changed, 24 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 0e32855..7b16882 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -94,33 +94,31 @@ enum {
>  	CSS_ONLINE	= (1 << 1), /* between ->css_online() and ->css_offline() */
>  };
>  
> -/* Caller must verify that the css is not for root cgroup */
> -static inline void __css_get(struct cgroup_subsys_state *css, int count)
> -{
> -	atomic_add(count, &css->refcnt);
> -}
> -
> -/*
> - * Call css_get() to hold a reference on the css; it can be used
> - * for a reference obtained via:
> - * - an existing ref-counted reference to the css
> - * - task->cgroups for a locked task
> +/**
> + * css_get - obtain a reference on the specified css
> + * @css: taget css

s/taget/target

> + *
> + * The caller must already have a reference.
>   */
> -
>  static inline void css_get(struct cgroup_subsys_state *css)
>  {
>  	/* We don't need to reference count the root state */
>  	if (!(css->flags & CSS_ROOT))
> -		__css_get(css, 1);
> +		atomic_inc(&css->refcnt);
>  }
>  
