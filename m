From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 32/36] Export fs/exec.c:exec_mmap()
Date: Thu, 9 Apr 2009 16:06:57 -0500
Message-ID: <20090409210657.GB5115@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-33-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239107264-21775-33-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Used in the next patch to attach an existing mm descriptor to a
> restarting process.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  fs/exec.c          |    2 +-
>  include/linux/mm.h |    3 +++
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 929b580..40f8d44 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -714,7 +714,7 @@ int kernel_read(struct file *file, unsigned long offset,
> 
>  EXPORT_SYMBOL(kernel_read);
> 
> -static int exec_mmap(struct mm_struct *mm)
> +int exec_mmap(struct mm_struct *mm)
>  {
>  	struct task_struct *tsk;
>  	struct mm_struct * old_mm, *active_mm;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e9bdc00..bc73f18 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1175,6 +1175,9 @@ extern int do_munmap(struct mm_struct *, unsigned long, size_t);
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
> 1.5.4.3
