From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 12/12] cgroup: unify pidlist and other file handling
Date: Wed, 4 Dec 2013 14:20:22 +0800
Message-ID: <529EC9A6.903__18079.3482614265$1386138153$gmane$org@huawei.com>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-13-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385595759-17656-13-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

> +static void *cgroup_seqfile_start(struct seq_file *seq, loff_t *ppos)
> +{
> +	struct cftype *cft = seq_cft(seq);
> +
> +	if (cft->seq_start) {
> +		return cft->seq_start(seq, ppos);
> +	} else {
> +		/*
> +		 * The same behavior and code as single_open().  Returns
> +		 * !NULL if pos is at the beginning; otherwise, NULL.
> +		 */

Isn't it simpler to choose between seq_open() and single_open() depending
on if cft->seq_start is implemented?

> +		return NULL + !*ppos;
> +	}
> +}
...
>  static int cgroup_file_open(struct inode *inode, struct file *file)
>  {
>  	struct cfent *cfe = __d_cfe(file->f_dentry);
> @@ -2338,20 +2384,17 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
>  	WARN_ON_ONCE(cfe->css && cfe->css != css);
>  	cfe->css = css;
>  
> -	if (cft->open) {
> -		err = cft->open(inode, file);
> -	} else {
> -		err = single_open_size(file, cgroup_seqfile_show, cfe,
> -				       sizeof(struct cgroup_open_file));
> -		if (!err) {
> -			struct seq_file *sf = file->private_data;
> -			struct cgroup_open_file *of = sf->private;
> +	err = seq_open_private(file, &cgroup_seq_operations,
> +			       sizeof(struct cgroup_open_file));
> +	if (!err) {
> +		struct seq_file *sf = file->private_data;
> +		struct cgroup_open_file *of = sf->private;
>  
> -			of->cfe = cfe;
> -		}
> +		of->cfe = cfe;
> +		return 0;
>  	}
>  
> -	if (css->ss && err)
> +	if (css->ss)
>  		css_put(css);
>  	return err;
>  }
