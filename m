From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 21/23] cgroup: make cftype->[un]register_event() deal
	with cgroup_subsys_state instead of cgroup
Date: Fri, 2 Aug 2013 12:08:51 +0800
Message-ID: <51FB30D3.9030900__4531.98813270337$1375416770$gmane$org@huawei.com>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-22-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-22-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> @@ -506,15 +506,17 @@ struct cftype {
>  	 * you want to provide this functionality. Use eventfd_signal()
>  	 * on eventfd to send notification to userspace.
>  	 */
> -	int (*register_event)(struct cgroup *cgrp, struct cftype *cft,
> -			struct eventfd_ctx *eventfd, const char *args);
> +	int (*register_event)(struct cgroup_subsys_state *css,
> +			      struct cftype *cft, struct eventfd_ctx *eventfd,
> +			      const char *args);
>  	/*
>  	 * unregister_event() callback will be called when userspace
>  	 * closes the eventfd or on cgroup removing.
>  	 * This callback must be implemented, if you want provide
>  	 * notification functionality.
>  	 */
> -	void (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
> +	void (*unregister_event)(struct cgroup_subsys_state *css,
> +				 struct cftype *cft,
>  			struct eventfd_ctx *eventfd);

align this line?

>  };
