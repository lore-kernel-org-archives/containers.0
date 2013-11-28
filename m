From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 07/12] cgroup: unify cgroup_write_X64() and
	cgroup_write_string()
Date: Thu, 28 Nov 2013 12:18:18 +0100
Message-ID: <20131128111818.GG2761@dhcp22.suse.cz>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-8-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 27-11-13 18:42:34, Tejun Heo wrote:
> cgroup_write_X64() and cgroup_write_string() both implement about the
> same buffering logic. 

> Unify the two into cgroup_file_write() which always allocates dynamic
> buffer for simplicity

It's true that this is simpler but the allocation might cause some
issues with memcg. Although it is not common that userspace oom handler
is a part of the target memcg there are users (e.g. Google) who do that.

Why is that a problem? Consider that a memcg is under OOM, handler gets
notified and tries to solve the situation by enlarging the hard limit.
This worked before this patch because cgroup_write_X64 used an on stack
buffer but now it would use kmalloc which might be accounted and trip
over the same OOM situation.

This is not limited to the OOM handling. The group might be close to OOM
and the last thing user expects is to trigger OOM when he tries to
enlarge the limit.

Is the additional simplicity worth breaking those usecases?

> and uses kstrto*() instead of simple_strto*().
> 
> This patch doesn't make any visible behavior changes except for
> possibly different error value from kstrsto*().
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  kernel/cgroup.c | 112 ++++++++++++++++++--------------------------------------
>  1 file changed, 36 insertions(+), 76 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 3592515..23abe8e 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2249,90 +2249,50 @@ static int cgroup_sane_behavior_show(struct cgroup_subsys_state *css,
>  /* A buffer size big enough for numbers or short strings */
>  #define CGROUP_LOCAL_BUFFER_SIZE 64
>  
> -static ssize_t cgroup_write_X64(struct cgroup_subsys_state *css,
> -				struct cftype *cft, struct file *file,
> -				const char __user *userbuf, size_t nbytes,
> -				loff_t *unused_ppos)
> -{
> -	char buffer[CGROUP_LOCAL_BUFFER_SIZE];
> -	int retval = 0;
> -	char *end;
> -
> -	if (!nbytes)
> -		return -EINVAL;
> -	if (nbytes >= sizeof(buffer))
> -		return -E2BIG;
> -	if (copy_from_user(buffer, userbuf, nbytes))
> -		return -EFAULT;
> -
> -	buffer[nbytes] = 0;     /* nul-terminate */
> -	if (cft->write_u64) {
> -		u64 val = simple_strtoull(strstrip(buffer), &end, 0);
> -		if (*end)
> -			return -EINVAL;
> -		retval = cft->write_u64(css, cft, val);
> -	} else {
> -		s64 val = simple_strtoll(strstrip(buffer), &end, 0);
> -		if (*end)
> -			return -EINVAL;
> -		retval = cft->write_s64(css, cft, val);
> -	}
> -	if (!retval)
> -		retval = nbytes;
> -	return retval;
> -}
> -
> -static ssize_t cgroup_write_string(struct cgroup_subsys_state *css,
> -				   struct cftype *cft, struct file *file,
> -				   const char __user *userbuf, size_t nbytes,
> -				   loff_t *unused_ppos)
> +static ssize_t cgroup_file_write(struct file *file, const char __user *userbuf,
> +				 size_t nbytes, loff_t *ppos)
>  {
> -	char local_buffer[CGROUP_LOCAL_BUFFER_SIZE];
> -	int retval = 0;
> -	size_t max_bytes = cft->max_write_len;
> -	char *buffer = local_buffer;
> +	struct cfent *cfe = __d_cfe(file->f_dentry);
> +	struct cftype *cft = __d_cft(file->f_dentry);
> +	struct cgroup_subsys_state *css = cfe->css;
> +	size_t max_bytes = cft->max_write_len ?: CGROUP_LOCAL_BUFFER_SIZE - 1;
> +	char *buf;
> +	int ret;
>  
> -	if (!max_bytes)
> -		max_bytes = sizeof(local_buffer) - 1;
>  	if (nbytes >= max_bytes)
>  		return -E2BIG;
> -	/* Allocate a dynamic buffer if we need one */
> -	if (nbytes >= sizeof(local_buffer)) {
> -		buffer = kmalloc(nbytes + 1, GFP_KERNEL);
> -		if (buffer == NULL)
> -			return -ENOMEM;
> -	}
> -	if (nbytes && copy_from_user(buffer, userbuf, nbytes)) {
> -		retval = -EFAULT;
> -		goto out;
> -	}
>  
> -	buffer[nbytes] = 0;     /* nul-terminate */
> -	retval = cft->write_string(css, cft, strstrip(buffer));
> -	if (!retval)
> -		retval = nbytes;
> -out:
> -	if (buffer != local_buffer)
> -		kfree(buffer);
> -	return retval;
> -}
> +	buf = kmalloc(nbytes + 1, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
>  
> -static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
> -				 size_t nbytes, loff_t *ppos)
> -{
> -	struct cfent *cfe = __d_cfe(file->f_dentry);
> -	struct cftype *cft = __d_cft(file->f_dentry);
> -	struct cgroup_subsys_state *css = cfe->css;
> +	if (copy_from_user(buf, userbuf, nbytes)) {
> +		ret = -EFAULT;
> +		goto out_free;
> +	}
>  
> -	if (cft->write_u64 || cft->write_s64)
> -		return cgroup_write_X64(css, cft, file, buf, nbytes, ppos);
> -	if (cft->write_string)
> -		return cgroup_write_string(css, cft, file, buf, nbytes, ppos);
> -	if (cft->trigger) {
> -		int ret = cft->trigger(css, (unsigned int)cft->private);
> -		return ret ? ret : nbytes;
> +	buf[nbytes] = '\0';
> +
> +	if (cft->write_string) {
> +		ret = cft->write_string(css, cft, strstrip(buf));
> +	} else if (cft->write_u64) {
> +		unsigned long long v;
> +		ret = kstrtoull(buf, 0, &v);
> +		if (!ret)
> +			ret = cft->write_u64(css, cft, v);
> +	} else if (cft->write_s64) {
> +		long long v;
> +		ret = kstrtoll(buf, 0, &v);
> +		if (!ret)
> +			ret = cft->write_s64(css, cft, v);
> +	} else if (cft->trigger) {
> +		ret = cft->trigger(css, (unsigned int)cft->private);
> +	} else {
> +		ret = -EINVAL;
>  	}
> -	return -EINVAL;
> +out_free:
> +	kfree(buf);
> +	return ret ?: nbytes;
>  }
>  
>  static ssize_t cgroup_read_u64(struct cgroup_subsys_state *css,
> -- 
> 1.8.4.2
> 

-- 
Michal Hocko
SUSE Labs
