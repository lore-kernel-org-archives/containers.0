From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 05/12] hugetlb_cgroup: convert away from cftype->read()
Date: Thu, 28 Nov 2013 09:29:27 +0100
Message-ID: <20131128082927.GC2761@dhcp22.suse.cz>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 27-11-13 18:42:32, Tejun Heo wrote:
> In preparation of conversion to kernfs, cgroup file handling is being
> consolidated so that it can be easily mapped to the seq_file based
> interface of kernfs.
> 
> All users of cftype->read() can be easily served, usually better, by
> seq_file and other methods.  Update hugetlb_cgroup_read() to return
> u64 instead of printing itself and rename it to
> hugetlb_cgroup_read_u64().
> 
> This patch doesn't make any visible behavior changes.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Thanks!

> ---
>  mm/hugetlb_cgroup.c | 22 ++++++++--------------
>  1 file changed, 8 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index bda8e44..d747a84 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -242,22 +242,16 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  	return;
>  }
>  
> -static ssize_t hugetlb_cgroup_read(struct cgroup_subsys_state *css,
> -				   struct cftype *cft, struct file *file,
> -				   char __user *buf, size_t nbytes,
> -				   loff_t *ppos)
> +static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
> +				   struct cftype *cft)
>  {
> -	u64 val;
> -	char str[64];
> -	int idx, name, len;
> +	int idx, name;
>  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
>  
>  	idx = MEMFILE_IDX(cft->private);
>  	name = MEMFILE_ATTR(cft->private);
>  
> -	val = res_counter_read_u64(&h_cg->hugepage[idx], name);
> -	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
> -	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
> +	return res_counter_read_u64(&h_cg->hugepage[idx], name);
>  }
>  
>  static int hugetlb_cgroup_write(struct cgroup_subsys_state *css,
> @@ -337,28 +331,28 @@ static void __init __hugetlb_cgroup_file_init(int idx)
>  	cft = &h->cgroup_files[0];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.limit_in_bytes", buf);
>  	cft->private = MEMFILE_PRIVATE(idx, RES_LIMIT);
> -	cft->read = hugetlb_cgroup_read;
> +	cft->read_u64 = hugetlb_cgroup_read_u64;
>  	cft->write_string = hugetlb_cgroup_write;
>  
>  	/* Add the usage file */
>  	cft = &h->cgroup_files[1];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.usage_in_bytes", buf);
>  	cft->private = MEMFILE_PRIVATE(idx, RES_USAGE);
> -	cft->read = hugetlb_cgroup_read;
> +	cft->read_u64 = hugetlb_cgroup_read_u64;
>  
>  	/* Add the MAX usage file */
>  	cft = &h->cgroup_files[2];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.max_usage_in_bytes", buf);
>  	cft->private = MEMFILE_PRIVATE(idx, RES_MAX_USAGE);
>  	cft->trigger = hugetlb_cgroup_reset;
> -	cft->read = hugetlb_cgroup_read;
> +	cft->read_u64 = hugetlb_cgroup_read_u64;
>  
>  	/* Add the failcntfile */
>  	cft = &h->cgroup_files[3];
>  	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
>  	cft->private  = MEMFILE_PRIVATE(idx, RES_FAILCNT);
>  	cft->trigger  = hugetlb_cgroup_reset;
> -	cft->read = hugetlb_cgroup_read;
> +	cft->read_u64 = hugetlb_cgroup_read_u64;
>  
>  	/* NULL terminate the last cft */
>  	cft = &h->cgroup_files[4];
> -- 
> 1.8.4.2
> 

-- 
Michal Hocko
SUSE Labs
