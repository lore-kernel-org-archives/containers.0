From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] cgroup: remove extra calls to find_existing_css_set
Date: Sun, 29 Jan 2012 12:37:49 -0800
Message-ID: <20120129203749.GE17211__30695.9669724622$1327869491$gmane$org@htj.dyndns.org>
References: <1327429591-8507-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1327429591-8507-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Manddep.

On Tue, Jan 24, 2012 at 10:26:31AM -0800, Mandeep Singh Baines wrote:
> In cgroup_attach_proc, we indirectly call find_existing_css_set 3
> times. It is an expensive call so we want to call it a minimum
> of times. This patch only calls it once and stores the result so
> that it can be used later on when we call cgroup_task_migrate.
> 
> This required modifying cgroup_task_migrate to take the new css_set
> (which we obtained from find_css_set) as a parameter. The nice side
> effect of this is that cgroup_task_migrate is now identical for
> cgroup_attach_task and cgroup_attach_proc. It also now returns a
> void since it can never fail.
> 
> Changes in V5:
> * https://lkml.org/lkml/2012/1/20/344 (Tejun Heo)
>   * Remove css_set_refs
             ^^^^^^^^^^^^
>  static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  {
> -	int retval, i, group_size;
> +	int retval, i, group_size, css_set_refs = 0;
				   ^^^^^^^^^^^^
Wrong patch?

Thanks.

-- 
tejun
