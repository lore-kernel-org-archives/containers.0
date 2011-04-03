From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Make exec_mmap extern
Date: Sun, 3 Apr 2011 11:56:09 -0500
Message-ID: <20110403165609.GA15044__6385.02549049935$1301849888$gmane$org@hallyn.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-2-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1298936432-29607-2-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> 
> Restoration of process state from a checkpoint image is similar to
> exec in that the calling task's mm is replaced.  Make exec_mmap
> available for this purpose.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> [ntl: extracted from Oren's "c/r: dump memory address space (private memory)"]
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/exec.c          |    2 +-
>  include/linux/mm.h |    3 +++
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index c62efcb..9d8c27a 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -767,7 +767,7 @@ int kernel_read(struct file *file, loff_t offset,
>  
>  EXPORT_SYMBOL(kernel_read);
>  
> -static int exec_mmap(struct mm_struct *mm)
> +int exec_mmap(struct mm_struct *mm)
>  {
>  	struct task_struct *tsk;
>  	struct mm_struct * old_mm, *active_mm;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 721f451..5397237 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1321,6 +1321,9 @@ extern int do_munmap(struct mm_struct *, unsigned long, size_t);
>  
>  extern unsigned long do_brk(unsigned long, unsigned long);
>  
> +/* fs/exec.c */
> +extern int exec_mmap(struct mm_struct *mm);
> +
>  /* filemap.c */
>  extern unsigned long page_unuse(struct page *);
>  extern void truncate_inode_pages(struct address_space *, loff_t);
> -- 
> 1.7.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
