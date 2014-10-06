From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH V5 01/13] namespaces: assign each namespace instance a
	serial	number
Date: Mon, 6 Oct 2014 09:16:40 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E5DAB74@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <cover.1412543112.git.rgb@redhat.com>
	<8bc6e9595dea17bba389f4d2ce4077c30b3eb137.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8bc6e9595dea17bba389f4d2ce4077c30b3eb137.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



> -----Original Message-----
> From: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> [mailto:containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org] On Behalf Of Richard Guy
> Briggs
> Sent: Monday, October 06, 2014 1:08 PM
> To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org;
> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
> Subject: [PATCH V5 01/13] namespaces: assign each namespace instance a serial
> number
> 
> Generate and assign a serial number per namespace instance since boot.
> 
> Use a serial number per namespace (unique across one boot of one kernel)
> instead of the inode number (which is claimed to have had the right to change
> reserved and is not necessarily unique if there is more than one proc fs) to
> uniquely identify it per kernel boot.
> 
> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/mount.h                     |    1 +
>  fs/namespace.c                 |    1 +
>  include/linux/ipc_namespace.h  |    1 +
>  include/linux/nsproxy.h        |   10 ++++++++++
>  include/linux/pid_namespace.h  |    1 +
>  include/linux/user_namespace.h |    1 +
>  include/linux/utsname.h        |    1 +
>  include/net/net_namespace.h    |    1 +
>  init/version.c                 |    1 +
>  ipc/msgutil.c                  |    1 +
>  ipc/namespace.c                |    2 ++
>  kernel/nsproxy.c               |   18 ++++++++++++++++++
>  kernel/pid.c                   |    1 +
>  kernel/pid_namespace.c         |    2 ++
>  kernel/user.c                  |    1 +
>  kernel/user_namespace.c        |    2 ++
>  kernel/utsname.c               |    2 ++
>  net/core/net_namespace.c       |    8 +++++++-
>  18 files changed, 54 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/mount.h b/fs/mount.h
> index d55297f..c076f99 100644
> --- a/fs/mount.h
> +++ b/fs/mount.h
> @@ -5,6 +5,7 @@
>  struct mnt_namespace {
>  	atomic_t		count;
>  	unsigned int		proc_inum;
> +	long long	serial_num;
>  	struct mount *	root;
>  	struct list_head	list;
>  	struct user_namespace	*user_ns;
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 182bc41..9af49ff 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2486,6 +2486,7 @@ static struct mnt_namespace *alloc_mnt_ns(struct
> user_namespace *user_ns)
>  		kfree(new_ns);
>  		return ERR_PTR(ret);
>  	}
> +	new_ns->serial_num = ns_serial();
>  	new_ns->seq = atomic64_add_return(1, &mnt_ns_seq);
>  	atomic_set(&new_ns->count, 1);
>  	new_ns->root = NULL;
> diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
> index 35e7eca..8ccfb2d 100644
> --- a/include/linux/ipc_namespace.h
> +++ b/include/linux/ipc_namespace.h
> @@ -69,6 +69,7 @@ struct ipc_namespace {
>  	struct user_namespace *user_ns;
> 
>  	unsigned int	proc_inum;
> +	long long	serial_num;
>  };
> 
>  extern struct ipc_namespace init_ipc_ns;
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index b4ec59d..9d627b5 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -66,6 +66,16 @@ static inline struct nsproxy *task_nsproxy(struct task_struct
> *tsk)
>  	return rcu_dereference(tsk->nsproxy);
>  }
> 
> +long long ns_serial(void);
> +enum {
> +	NS_IPC_INIT_SN	= 1,
> +	NS_UTS_INIT_SN	= 2,
> +	NS_USER_INIT_SN	= 3,
> +	NS_PID_INIT_SN	= 4,
> +	__NS_MAX_INIT_SN= 5,

You may need a space before '='.

The rest looks good to me.

Thanks,

- Chen
