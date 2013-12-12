From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -next] cgroup: fix missing unlock on error in
	cgroup_load_subsys()
Date: Thu, 12 Dec 2013 14:02:25 +0800
Message-ID: <52A95171.3060009@huawei.com>
References: <CAPgLHd8s94-e2=tynt-jKKNmoSXzNFHs+vYeUS1uW3+Ohk_OVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAPgLHd8s94-e2=tynt-jKKNmoSXzNFHs+vYeUS1uW3+Ohk_OVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/12/9 20:38, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> 
> Add the missing unlock before return from function cgroup_load_subsys()
> in the error handling case.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

but it conflicts with Vladimir's bug fix.

> ---
>  kernel/cgroup.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index fb1193b..402f7aa 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4618,6 +4618,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
>  	if (IS_ERR(css)) {
>  		/* failure case - need to deassign the cgroup_subsys[] slot. */
>  		cgroup_subsys[ss->subsys_id] = NULL;
> +		mutex_unlock(&cgroup_root_mutex);
>  		mutex_unlock(&cgroup_mutex);
>  		return PTR_ERR(css);
>  	}
> 
> 
