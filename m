From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] proc: #68991 Fix GPF in /proc/$PID/map_files
Date: Fri, 07 Mar 2014 12:17:56 -0800
Message-ID: <87r46dvk3v.fsf@xmission.com>
References: <20140308022033.GC5690@owamsq.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140308022033.GC5690-z1oL5kbKe2PzvzwRvDUw0Q@public.gmane.org> (Artem Fetishev's message
	of "Sat, 8 Mar 2014 05:20:33 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Artem Fetishev <artem_fetishev-uRwfk40T5oI@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, alexandr_terekhov-uRwfk40T5oI@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Artem Fetishev <artem_fetishev-uRwfk40T5oI@public.gmane.org> writes:

> https://bugzilla.kernel.org/show_bug.cgi?id=68991
>
> The expected logic of proc_map_files_get_link() is either to return 0 and
> initialize 'path' or return an error and leave 'path' uninitialized. By the time
> dname_to_vma_addr() returns 0 the corresponding vma may have already be gone. In
> this case the path is not initialized but the return value is still 0. This
> results in 'general protection fault' inside d_path().
>
> Steps to reproduce:
> CONFIG_CHECKPOINT_RESTORE=y
>
> fd = open(...);
> while (1) {
> 	mmap(fd, ...);
> 	munmap(fd, ...);
> }
>
> ls -la /proc/$PID/map_files
>
> Signed-off-by: Artem Fetishev <artem_fetishev-uRwfk40T5oI@public.gmane.org>
> Signed-off-by: Aleksandr Terekhov <aleksandr_terekhov-uRwfk40T5oI@public.gmane.org>
Reviewed-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 5150706..b976062 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1824,6 +1824,7 @@ static int proc_map_files_get_link(struct dentry *dentry, struct path *path)
>  	if (rc)
>  		goto out_mmput;
>  
> +	rc = -ENOENT;
>  	down_read(&mm->mmap_sem);
>  	vma = find_exact_vma(mm, vm_start, vm_end);
>  	if (vma && vma->vm_file) {
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
