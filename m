From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V5 10/13] audit: log on switching namespace (setns)
Date: Mon, 13 Oct 2014 15:22:53 +0200
Message-ID: <20141013132253.GI24703@mail.hallyn.com>
References: <cover.1412543112.git.rgb@redhat.com>
	<5df56a7fa372cf86ca7d5f3807178710097b4c27.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5df56a7fa372cf86ca7d5f3807178710097b4c27.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Added six new audit message types, AUDIT_NS_SET_* and function
> audit_log_ns_set() to log a switch of namespace.
> 
> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/audit.h      |    4 +++
>  include/uapi/linux/audit.h |    6 +++++
>  kernel/audit.c             |   46 ++++++++++++++++++++++++++++++++++++++++++++
>  kernel/nsproxy.c           |    3 ++
>  4 files changed, 59 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 1474334..9de9b25 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -26,6 +26,7 @@
>  #include <linux/sched.h>
>  #include <linux/ptrace.h>
>  #include <uapi/linux/audit.h>
> +#include <linux/proc_ns.h>
>  
>  struct audit_sig_info {
>  	uid_t		uid;
> @@ -484,6 +485,7 @@ static inline void	    audit_log_ns_info(struct task_struct *tsk)
>  extern int		    audit_log_ns_init(int type, long long old_snum,
>  					      long long snum);
>  extern int		    audit_log_ns_del(int type, long long snum);
> +extern void		    audit_log_ns_set(const struct proc_ns_operations *ops, void *ns);
>  
>  extern int		    audit_update_lsm_rules(void);
>  
> @@ -547,6 +549,8 @@ static inline int audit_log_ns_init(int type, long long old_snum,
>  { }
>  static inline int audit_log_ns_del(int type, long long snum)
>  { }
> +static inline void audit_log_ns_set(const struct proc_ns_operations *ops, void *ns)
> +{ }
>  #define audit_enabled 0
>  #endif /* CONFIG_AUDIT */
>  static inline void audit_log_string(struct audit_buffer *ab, const char *buf)
> diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
> index 1acfea7..7ec7209 100644
> --- a/include/uapi/linux/audit.h
> +++ b/include/uapi/linux/audit.h
> @@ -123,6 +123,12 @@
>  #define AUDIT_NS_DEL_USER	1339	/* Record USER namespace instance deletion */
>  #define AUDIT_NS_DEL_PID	1340	/* Record PID namespace instance deletion */
>  #define AUDIT_NS_DEL_NET	1341	/* Record NET namespace instance deletion */
> +#define AUDIT_NS_SET_MNT	1342	/* Record mount namespace instance deletion */
> +#define AUDIT_NS_SET_UTS	1343	/* Record UTS namespace instance deletion */
> +#define AUDIT_NS_SET_IPC	1344	/* Record IPC namespace instance deletion */
> +#define AUDIT_NS_SET_USER	1345	/* Record USER namespace instance deletion */
> +#define AUDIT_NS_SET_PID	1346	/* Record PID namespace instance deletion */
> +#define AUDIT_NS_SET_NET	1347	/* Record NET namespace instance deletion */
>  
>  #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
>  #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
> diff --git a/kernel/audit.c b/kernel/audit.c
> index cc63445..84590d1 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -2021,6 +2021,52 @@ int audit_log_ns_del(int type, long long snum)
>  	audit_log_end(ab);
>  	return 0;
>  }
> +
> +/**
> + * audit_log_ns_set - report a namespace set change
> + * @ops: the ops structure for the namespace to be changed
> + * @ns: the new namespace
> + */
> +void audit_log_ns_set(const struct proc_ns_operations *ops, void *ns)
> +{
> +	struct audit_buffer *ab;
> +	void *old_ns;
> +	int msg_type;
> +
> +	switch (ops->type) {
> +	case CLONE_NEWNS:
> +		msg_type = AUDIT_NS_SET_MNT;
> +		break;
> +	case CLONE_NEWUTS:
> +		msg_type = AUDIT_NS_SET_UTS;
> +		break;
> +	case CLONE_NEWIPC:
> +		msg_type = AUDIT_NS_SET_IPC;
> +		break;
> +	case CLONE_NEWUSER:
> +		msg_type = AUDIT_NS_SET_USER;
> +		break;
> +	case CLONE_NEWPID:
> +		msg_type = AUDIT_NS_SET_PID;
> +		break;
> +	case CLONE_NEWNET:
> +		msg_type = AUDIT_NS_SET_NET;
> +		break;
> +	default:
> +		return;
> +	}
> +	//ab = audit_log_start(tsk->audit_context, GFP_KERNEL, msg_type);
> +	//audit_log_format(ab, " pid=%d", current->pid);

Are these commented lines an accident, a 'TODO', or something else?

> +	audit_log_common_recv_msg(&ab, ops->type);
> +	if (!ab)
> +		return;
> + 	old_ns = ops->get(current);
> +	audit_log_format(ab, " old-%ssn=%llx %ssn=%llx",
> +			 ops->name, ops->snum(old_ns),
> +			 ops->name, ops->snum(ns));
> +	ops->put(old_ns);
> +	audit_log_end(ab);
> +}
>  #endif /* CONFIG_NAMESPACES */
>  
>  /**
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 2cdc16b..e37409a 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -275,6 +275,9 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
>  		goto out;
>  	}
>  	switch_task_namespaces(tsk, new_nsproxy);
> +
> +	audit_log_ns_set(ops, ei->ns);
> +
>  out:
>  	fput(file);
>  	return err;
> -- 
> 1.7.1
