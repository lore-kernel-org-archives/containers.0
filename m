From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] [PATCH 2/2] sys_restore: set the pid number
Date: Sun, 27 Jul 2008 06:33:33 +0400
Message-ID: <488BDE7D.7090602@openvz.org>
References: <20080725225655.GA28276@us.ibm.com>
	<20080725225935.GB28764@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080725225935.GB28764-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Set the pid number for a restored task.  This is purely a toy, as it
> only sets the pidnr in the lowest level pid namespace.
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/fork.c |    5 +++++
>  kernel/pid.c  |   19 +++++++++++++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 0e43f69..41c46d2 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1685,6 +1685,8 @@ int unshare_files(struct files_struct **displaced)
>  char buf[CKPT_SIZE];
>  char exe_filename[PAGE_SIZE];
>  
> +extern int choose_pidmap(struct pid *pid, int new);
> +
>  /*
>   * userspace will already have made us a new pidns
>   */
> @@ -1717,6 +1719,9 @@ long do_restore(unsigned int fd,
>  	if (nr_scanned != 2)
>  		return -EINVAL;
>  
> +	ret = choose_pidmap(task_pid(current), pid);
> +	if (!ret)
> +		return -EAGAIN;
>  
>  	ret = do_execve(exe_filename, argv, envp, regs);
>  out:
> diff --git a/kernel/pid.c b/kernel/pid.c
> index 30bd5d4..88a5e2a 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -122,6 +122,25 @@ static void free_pidmap(struct upid *upid)
>  	atomic_inc(&map->nr_free);
>  }
>  
> +int choose_pidmap(struct pid *pid, int new)
> +{
> +	struct pidmap *map;
> +	int level = pid->level;
> +	struct upid *upid = &pid->numbers[level];
> +	struct pid_namespace *pid_ns = upid->ns;
> +	int old = upid->nr;
> +
> +	map = &pid_ns->pidmap[new/BITS_PER_PAGE];
> +	if (!test_and_set_bit(new, map->page)) {

This and...

> +		map = &pid_ns->pidmap[old/BITS_PER_PAGE];
> +		clear_bit(old, map->page);

this are both a bit buggy, since the bit number on the page
is not the same as the pid id itself ;)

> +		upid->nr = new;
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +
>  static int alloc_pidmap(struct pid_namespace *pid_ns)
>  {
>  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
