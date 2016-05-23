From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] userns: Allow init_user_ns to be used from non-gpl modules
Date: Mon, 23 May 2016 15:12:55 +0000
Message-ID: <20160523151255.GB1944@ubuntumail>
References: <1464004808-21214-1-git-send-email-n.borisov.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1464004808-21214-1-git-send-email-n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederman-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nikolay Borisov (n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> This patch changes the export attributes of the init_user_ns from
> GPL-only to any modules. This needed so that non-gpl modules, such as
> ZFS, utilize functions like i_(uid|gid)_(read|write).
> 
> Signed-off-by: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Seems reasonable to me,

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

but it seems clear the decision belongs to Eric.

thanks,
-serge

> ---
>  kernel/user.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/user.c b/kernel/user.c
> index b069ccbfb0b0..8bbd4e628b6e 100644
> --- a/kernel/user.c
> +++ b/kernel/user.c
> @@ -60,7 +60,7 @@ struct user_namespace init_user_ns = {
>  	__RWSEM_INITIALIZER(init_user_ns.persistent_keyring_register_sem),
>  #endif
>  };
> -EXPORT_SYMBOL_GPL(init_user_ns);
> +EXPORT_SYMBOL(init_user_ns);
>  
>  /*
>   * UID task count cache, to get fast user lookup in "alloc_uid"
> -- 
> 2.7.4
> 
