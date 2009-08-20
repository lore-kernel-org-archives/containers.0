From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/8] Use vmalloc for large cgroups pidlist allocations
Date: Thu, 20 Aug 2009 10:37:36 +0800
Message-ID: <4A8CB6F0.1020308__39469.8247583166$1250735981$gmane$org@cn.fujitsu.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235827.22531.60306.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090818235827.22531.60306.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> 
> Use vmalloc for large cgroups pidlist allocations
> 
> Separates all pidlist allocation requests to a separate function that judges
> based on the requested size whether or not the array needs to be vmalloced or
> can be gotten via kmalloc, and similar for kfree/vfree.
> 
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

> ---
> 
>  kernel/cgroup.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
>  1 files changed, 42 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index d207871..7e2b285 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -50,6 +50,7 @@
>  #include <linux/smp_lock.h>
>  #include <linux/pid_namespace.h>
>  #include <linux/idr.h>
> +#include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
>  
>  #include <asm/atomic.h>
>  
> @@ -2351,6 +2352,42 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
>   */
>  
>  /*
> + * The following two functions "fix" the issue where there are more pids
> + * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
> + * TODO: replace with a kernel-wide solution to this problem
> + */

I come to realize the "procs" file will make it much harder to convert
vmalloc/kmalloc with a different solution..
