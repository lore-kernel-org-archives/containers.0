From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/3] Quick vmalloc vs kmalloc fix to the case where array
	size	is too large
Date: Mon, 13 Jul 2009 11:03:03 +0800
Message-ID: <4A5AA3E7.9070800__36826.7344929793$1247454238$gmane$org@cn.fujitsu.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230205.16778.11707.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090710230205.16778.11707.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Ben Blum wrote:
> Quick vmalloc vs kmalloc fix to the case where array size is too large
> 
> Separates all pidlist allocation requests to a separate function that judges
> based on the requested size whether or not the array needs to be vmalloced or
> can be gotten via kmalloc, and similar for kfree/vfree. Should be replaced
> entirely with a kernel-wide solution to this general problem.
> 
> Depends on cgroup-pidlist-namespace.patch, cgroup-procs.patch
> 

Since this is a patchset, you don't need to tell the dependencies of
this patch, at least not in changelog, but can put it ...

> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 

... here

---  <- followed by this mark

>  kernel/cgroup.c |   34 ++++++++++++++++++++++++++++------
>  1 files changed, 28 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 33d89be..0ed85fa 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -48,6 +48,7 @@
>  #include <linux/namei.h>
>  #include <linux/smp_lock.h>
>  #include <linux/pid_namespace.h>
> +#include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
>  

Is this TODO different with the below one?

>  #include <asm/atomic.h>
>  
> @@ -2121,6 +2122,27 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
>   */
>  
>  /*
> + * The following two functions "fix" the issue where there are more pids
> + * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
> + * TODO: replace with a kernel-wide solution to this problem
> + */
> +#define PIDLIST_TOO_LARGE(c) ((c) * sizeof(pid_t) > (PAGE_SIZE * 2))

I think order-0 is most robust and should be used as much as possible.

> +static inline void *pidlist_allocate(int count)

It's better to let gcc decide to inline it or not.

> +{
> +	if (PIDLIST_TOO_LARGE(count))
> +		return vmalloc(count * sizeof(pid_t));
> +	else
> +		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
> +}
> +static inline void pidlist_free(void *p)

ditto

> +{
> +	if (is_vmalloc_addr(p))
> +		vfree(p);
> +	else
> +		kfree(p);
> +}
> +
