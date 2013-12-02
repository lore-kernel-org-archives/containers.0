From: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/12] cgroup: replace cftype->read_seq_string() with
	cftype->seq_show()
Date: Mon, 2 Dec 2013 09:41:07 -0500
Message-ID: <20131202144107.GI17404@redhat.com>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-12-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-12-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 27, 2013 at 06:42:38PM -0500, Tejun Heo wrote:
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -274,10 +274,9 @@ static void set_majmin(char *str, unsigned m)
>  		sprintf(str, "%u", m);
>  }
>  
> -static int devcgroup_seq_read(struct cgroup_subsys_state *css,
> -			      struct cftype *cft, struct seq_file *m)
> +static int devcgroup_seq_show(struct seq_file *m, void *v)
>  {
> -	struct dev_cgroup *devcgroup = css_to_devcgroup(css);
> +	struct dev_cgroup *devcgroup = css_to_devcgroup(seq_css(m));
>  	struct dev_exception_item *ex;
>  	char maj[MAJMINLEN], min[MAJMINLEN], acc[ACCLEN];
>  
> @@ -679,7 +678,7 @@ static struct cftype dev_cgroup_files[] = {
>  	},
>  	{
>  		.name = "list",
> -		.read_seq_string = devcgroup_seq_read,
> +		.seq_show = devcgroup_seq_show,
>  		.private = DEVCG_LIST,
>  	},
>  	{ }	/* terminate */

Acked-by: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

-- 
Aristeu
