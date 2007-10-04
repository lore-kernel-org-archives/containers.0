From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Typedefs the read and write functions in cftype
Date: Thu, 4 Oct 2007 08:18:22 -0700
Message-ID: <6599ad830710040818x2300360eyf90d571789085ddb@mail.gmail.com>
References: <4704AFC9.4030606@openvz.org> <4704AFFF.4000000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4704AFFF.4000000-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/4/07, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> This is just to reduce the code amount in the future.
>
> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

>
> ---
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 8747932..0635004 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -178,6 +178,15 @@ struct css_set {
>   *     - the 'cftype' of the file is file->f_dentry->d_fsdata
>   */
>
> +struct cftype;
> +
> +typedef ssize_t (*cft_read) (struct cgroup *cont, struct cftype *cft,
> +                        struct file *file,
> +                        char __user *buf, size_t nbytes, loff_t *ppos);
> +typedef ssize_t (*cft_write) (struct cgroup *cont, struct cftype *cft,
> +                         struct file *file,
> +                         const char __user *buf, size_t nbytes, loff_t *ppos);
> +
>  #define MAX_CFTYPE_NAME 64
>  struct cftype {
>         /* By convention, the name should begin with the name of the
> @@ -185,18 +194,14 @@ struct cftype {
>         char name[MAX_CFTYPE_NAME];
>         int private;
>         int (*open) (struct inode *inode, struct file *file);
> -       ssize_t (*read) (struct cgroup *cont, struct cftype *cft,
> -                        struct file *file,
> -                        char __user *buf, size_t nbytes, loff_t *ppos);
> +       cft_read read;
>         /*
>          * read_uint() is a shortcut for the common case of returning a
>          * single integer. Use it in place of read()
>          */
>         u64 (*read_uint) (struct cgroup *cont, struct cftype *cft);
> -       ssize_t (*write) (struct cgroup *cont, struct cftype *cft,
> -                         struct file *file,
> -                         const char __user *buf, size_t nbytes, loff_t *ppos);
>
> +       cft_write write;
>         /*
>          * write_uint() is a shortcut for the common case of accepting
>          * a single integer (as parsed by simple_strtoull) from
>
>
