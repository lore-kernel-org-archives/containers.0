From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] [RFC] Add file f_flags to cgroup write_string ops
Date: Wed, 28 Oct 2009 09:04:10 +0800
Message-ID: <4AE7988A.6080601@cn.fujitsu.com>
References: <1256570129-13107-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256570129-13107-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley wrote:
> cgroup subsystems may find the O_APPEND and O_NONBLOCK flags useful
> in determining the way they handle writes. For now only pass these
> flags through the write_string op.
> 
> A subsequent patch will make use of the O_NONBLOCK flag in the
> cgroup freezer write_string op.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> (Cc'ing mem controller maintainers in case they find this useful..)
> Cc: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> ---
>  include/linux/cgroup.h   |    3 ++-
>  kernel/cgroup.c          |    5 +++--
>  kernel/cgroup_freezer.c  |    5 ++---
>  kernel/cpuset.c          |    2 +-
>  mm/memcontrol.c          |    2 +-
>  security/device_cgroup.c |    2 +-
>  6 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 90bba9e..627da35 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -315,8 +315,9 @@ struct cftype {
>  	 * buffer of maximum length determined by max_write_len.
>  	 * Returns 0 or -ve error code.
>  	 */
> +#define CFTYPE_F_FLAGS (O_APPEND|O_NONBLOCK)
>  	int (*write_string)(struct cgroup *cgrp, struct cftype *cft,
> -			    const char *buffer);
> +			    unsigned int f_flags, const char *buffer);

I think maybe it's better to store struct file *file to struct cftype,
so we don't need to change write_string(), write(), write_u64()
and write_s64().

>  	/*
>  	 * trigger() callback can be used to get some kick from the
>  	 * userspace, when the actual string written is not important
