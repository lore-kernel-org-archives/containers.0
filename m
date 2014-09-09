From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/3] procfs: check uniq proc_dir_entry subdir name
Date: Wed, 10 Sep 2014 01:17:15 +0200
Message-ID: <20140909231715.GA25668@mail.hallyn.com>
References: <1409740200-26461-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1409740200-26461-2-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1409740200-26461-2-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Chen Hanxiao (chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> Check whether a proc dir has a subdir
> with a specific name.
> Will be used in a later patch.
> 
> Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  fs/proc/generic.c       | 15 +++++++++++++++
>  include/linux/proc_fs.h |  3 +++
>  2 files changed, 18 insertions(+)
> 
> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
> index b7f268e..4d576c2 100644
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -173,6 +173,21 @@ static const struct inode_operations proc_link_inode_operations = {
>  	.follow_link	= proc_follow_link,
>  };
>  
> +/* check whether dir has @name member */
> +struct proc_dir_entry *proc_uniq_dir(struct proc_dir_entry *de, char *name)
> +{
> +	spin_lock(&proc_subdir_lock);
> +	for (de = de->subdir; de ; de = de->next) {
> +		if (!strcmp(de->name, name)) {

Should you pde_get(de) here?

> +			spin_unlock(&proc_subdir_lock);
> +			return de;
> +		}
> +	}
> +	spin_unlock(&proc_subdir_lock);
> +	return NULL;
> +}
> +EXPORT_SYMBOL(proc_uniq_dir);
> +
>  /*
>   * Don't create negative dentries here, return -ENOENT by hand
>   * instead.
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index 9d117f6..38e87aa 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -41,6 +41,7 @@ extern void *proc_get_parent_data(const struct inode *);
>  extern void proc_remove(struct proc_dir_entry *);
>  extern void remove_proc_entry(const char *, struct proc_dir_entry *);
>  extern int remove_proc_subtree(const char *, struct proc_dir_entry *);
> +extern struct proc_dir_entry *proc_uniq_dir(struct proc_dir_entry *, char *);
>  
>  #else /* CONFIG_PROC_FS */
>  
> @@ -71,6 +72,8 @@ static inline void *proc_get_parent_data(const struct inode *inode) { BUG(); ret
>  static inline void proc_remove(struct proc_dir_entry *de) {}
>  #define remove_proc_entry(name, parent) do {} while (0)
>  static inline int remove_proc_subtree(const char *name, struct proc_dir_entry *parent) { return 0; }
> +static inline struct proc_dir_entry *proc_uniq_dir(struct proc_dir_entry *,
> +	char *) {return 0; }
>  
>  #endif /* CONFIG_PROC_FS */
>  
> -- 
> 1.9.0
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
