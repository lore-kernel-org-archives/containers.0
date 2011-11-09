From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 6/6] protect cap_netlink_recv from user namespaces
Date: Wed, 9 Nov 2011 08:44:16 -0600
Message-ID: <20111109144416.GA4976__10662.6011817299$1320863349$gmane$org@sergelap>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-7-git-send-email-serge@hallyn.com>
	<1320694510.10093.23.camel@localhost>
	<20111108032902.GA29433@hallyn.com>
	<1320848342.10093.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1320848342.10093.57.camel@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On Tue, 2011-11-08 at 03:29 +0000, Serge E. Hallyn wrote:
> > Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> 
> > But, regardless, your point is valid in that I'm not tightening down as
> > much as I could.  So how about I don't change the security_netlink_recv()
> > and callers yet, and instead I change cap_netlink_recv() to do:
> > 
> > 	if (!IN_ROOT_USER_NS && !cap_raised(current_cap(), cap))
> 
> Actually better thought.  Remove the LSM hook altogether and just use
> capable() in the callers.  This hook, being used this way, was

Heh, that sounds terrific!  Only concern I have is it will cause
PF_SUPERPRIV to be set when successful, which it didn't use to.
Now it looks like that might be more correct, but it's a change.
Are people who care about accounting stats going to notice and be
surprised?

> introduced in c7bdb545 back when we took the effective perms from the
> skb.  We don't use the skb any more since netlink is synchronous.  This
> is functionally equivalent except the capabilities code checks against
> the init_user_ns (something we want) and it will now set PF_PRIV (which
> also seems like a good thing) Something like:
> 
> security: remove the security_netlink_recv hook as it is equivalent to capable()
>     
> Once upon a time netlink was not sync and we had to get the effective
> capabilities from the skb that was being received.  Today we instead get
> the capabilities from the current task.  This has rendered the entire
> purpose of the hook moot as it is now functionally equivalent to the
> capable() call.
>     
> Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

thanks,
-serge

> 
> ---
> 
>  drivers/scsi/scsi_netlink.c     |    2 +-
>  include/linux/security.h        |   14 --------------
>  kernel/audit.c                  |    4 ++--
>  net/core/rtnetlink.c            |    2 +-
>  net/decnet/netfilter/dn_rtmsg.c |    2 +-
>  net/ipv4/netfilter/ip_queue.c   |    2 +-
>  net/ipv6/netfilter/ip6_queue.c  |    2 +-
>  net/netfilter/nfnetlink.c       |    2 +-
>  net/netlink/genetlink.c         |    2 +-
>  net/xfrm/xfrm_user.c            |    2 +-
>  security/capability.c           |    1 -
>  security/commoncap.c            |    8 --------
>  security/security.c             |    6 ------
>  security/selinux/hooks.c        |   19 -------------------
>  14 files changed, 10 insertions(+), 58 deletions(-)
> 
> diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
> index 44f76e8..c77628a 100644
> --- a/drivers/scsi/scsi_netlink.c
> +++ b/drivers/scsi/scsi_netlink.c
> @@ -112,7 +112,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
>  			goto next_msg;
>  		}
>  
> -		if (security_netlink_recv(skb, CAP_SYS_ADMIN)) {
> +		if (!capable(CAP_SYS_ADMIN)) {
>  			err = -EPERM;
>  			goto next_msg;
>  		}
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 1bb742b..bb7e8a0 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -96,7 +96,6 @@ struct xfrm_user_sec_ctx;
>  struct seq_file;
>  
>  extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
> -extern int cap_netlink_recv(struct sk_buff *skb, int cap);
>  
>  void reset_security_ops(void);
>  
> @@ -798,12 +797,6 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	@skb contains the sk_buff structure for the netlink message.
>   *	Return 0 if the information was successfully saved and message
>   *	is allowed to be transmitted.
> - * @netlink_recv:
> - *	Check permission before processing the received netlink message in
> - *	@skb.
> - *	@skb contains the sk_buff structure for the netlink message.
> - *	@cap indicates the capability required
> - *	Return 0 if permission is granted.
>   *
>   * Security hooks for Unix domain networking.
>   *
> @@ -1564,7 +1557,6 @@ struct security_operations {
>  			  struct sembuf *sops, unsigned nsops, int alter);
>  
>  	int (*netlink_send) (struct sock *sk, struct sk_buff *skb);
> -	int (*netlink_recv) (struct sk_buff *skb, int cap);
>  
>  	void (*d_instantiate) (struct dentry *dentry, struct inode *inode);
>  
> @@ -1817,7 +1809,6 @@ void security_d_instantiate(struct dentry *dentry, struct inode *inode);
>  int security_getprocattr(struct task_struct *p, char *name, char **value);
>  int security_setprocattr(struct task_struct *p, char *name, void *value, size_t size);
>  int security_netlink_send(struct sock *sk, struct sk_buff *skb);
> -int security_netlink_recv(struct sk_buff *skb, int cap);
>  int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
>  int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
>  void security_release_secctx(char *secdata, u32 seclen);
> @@ -2505,11 +2496,6 @@ static inline int security_netlink_send(struct sock *sk, struct sk_buff *skb)
>  	return cap_netlink_send(sk, skb);
>  }
>  
> -static inline int security_netlink_recv(struct sk_buff *skb, int cap)
> -{
> -	return cap_netlink_recv(skb, cap);
> -}
> -
>  static inline int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
>  {
>  	return -EOPNOTSUPP;
> diff --git a/kernel/audit.c b/kernel/audit.c
> index 2c1d6ab..57e3f51 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -601,13 +601,13 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
>  	case AUDIT_TTY_SET:
>  	case AUDIT_TRIM:
>  	case AUDIT_MAKE_EQUIV:
> -		if (security_netlink_recv(skb, CAP_AUDIT_CONTROL))
> +		if (!capable(CAP_AUDIT_CONTROL))
>  			err = -EPERM;
>  		break;
>  	case AUDIT_USER:
>  	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
>  	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
> -		if (security_netlink_recv(skb, CAP_AUDIT_WRITE))
> +		if (!capable(CAP_AUDIT_WRITE))
>  			err = -EPERM;
>  		break;
>  	default:  /* bad msg */
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 39f8dd6..98ee1b6 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1930,7 +1930,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	sz_idx = type>>2;
>  	kind = type&3;
>  
> -	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
> +	if (kind != 2 && !capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
>  	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
> diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
> index 69975e0..1531135 100644
> --- a/net/decnet/netfilter/dn_rtmsg.c
> +++ b/net/decnet/netfilter/dn_rtmsg.c
> @@ -108,7 +108,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
>  	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
>  		return;
>  
> -	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +	if (!capable(CAP_NET_ADMIN))
>  		RCV_SKB_FAIL(-EPERM);
>  
>  	/* Eventually we might send routing messages too */
> diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
> index e59aabd..ffabb26 100644
> --- a/net/ipv4/netfilter/ip_queue.c
> +++ b/net/ipv4/netfilter/ip_queue.c
> @@ -430,7 +430,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
>  	if (type <= IPQM_BASE)
>  		return;
>  
> -	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +	if (!capable(CAP_NET_ADMIN))
>  		RCV_SKB_FAIL(-EPERM);
>  
>  	spin_lock_bh(&queue_lock);
> diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
> index e63c397..5e5ce77 100644
> --- a/net/ipv6/netfilter/ip6_queue.c
> +++ b/net/ipv6/netfilter/ip6_queue.c
> @@ -431,7 +431,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
>  	if (type <= IPQM_BASE)
>  		return;
>  
> -	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +	if (!capable(CAP_NET_ADMIN))
>  		RCV_SKB_FAIL(-EPERM);
>  
>  	spin_lock_bh(&queue_lock);
> diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
> index c879c1a..9da4fc5 100644
> --- a/net/netfilter/nfnetlink.c
> +++ b/net/netfilter/nfnetlink.c
> @@ -130,7 +130,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	const struct nfnetlink_subsystem *ss;
>  	int type, err;
>  
> -	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +	if (!capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
>  	/* All the messages must at least contain nfgenmsg */
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 482fa57..05fedbf 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -516,7 +516,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		return -EOPNOTSUPP;
>  
>  	if ((ops->flags & GENL_ADMIN_PERM) &&
> -	    security_netlink_recv(skb, CAP_NET_ADMIN))
> +	    !capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
>  	if (nlh->nlmsg_flags & NLM_F_DUMP) {
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index d0a42df..7ea716d 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -2290,7 +2290,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	link = &xfrm_dispatch[type];
>  
>  	/* All operations require privileges, even GET */
> -	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +	if (!capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
>  	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
> diff --git a/security/capability.c b/security/capability.c
> index 3cf5ae3..5c1aea0 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -1004,7 +1004,6 @@ void __init security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, sem_semctl);
>  	set_to_cap_if_null(ops, sem_semop);
>  	set_to_cap_if_null(ops, netlink_send);
> -	set_to_cap_if_null(ops, netlink_recv);
>  	set_to_cap_if_null(ops, d_instantiate);
>  	set_to_cap_if_null(ops, getprocattr);
>  	set_to_cap_if_null(ops, setprocattr);
> diff --git a/security/commoncap.c b/security/commoncap.c
> index 90fdf97..454e974 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -56,14 +56,6 @@ int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
>  	return 0;
>  }
>  
> -int cap_netlink_recv(struct sk_buff *skb, int cap)
> -{
> -	if (!cap_raised(current_cap(), cap))
> -		return -EPERM;
> -	return 0;
> -}
> -EXPORT_SYMBOL(cap_netlink_recv);
> -
>  /**
>   * cap_capable - Determine whether a task has a particular effective capability
>   * @cred: The credentials to use
> diff --git a/security/security.c b/security/security.c
> index 5560472..17ee1c0 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -983,12 +983,6 @@ int security_netlink_send(struct sock *sk, struct sk_buff *skb)
>  	return security_ops->netlink_send(sk, skb);
>  }
>  
> -int security_netlink_recv(struct sk_buff *skb, int cap)
> -{
> -	return security_ops->netlink_recv(skb, cap);
> -}
> -EXPORT_SYMBOL(security_netlink_recv);
> -
>  int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
>  {
>  	return security_ops->secid_to_secctx(secid, secdata, seclen);
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 3deee07..668fe48 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4731,24 +4731,6 @@ static int selinux_netlink_send(struct sock *sk, struct sk_buff *skb)
>  	return selinux_nlmsg_perm(sk, skb);
>  }
>  
> -static int selinux_netlink_recv(struct sk_buff *skb, int capability)
> -{
> -	int err;
> -	struct common_audit_data ad;
> -	u32 sid;
> -
> -	err = cap_netlink_recv(skb, capability);
> -	if (err)
> -		return err;
> -
> -	COMMON_AUDIT_DATA_INIT(&ad, CAP);
> -	ad.u.cap = capability;
> -
> -	security_task_getsecid(current, &sid);
> -	return avc_has_perm(sid, sid, SECCLASS_CAPABILITY,
> -			    CAP_TO_MASK(capability), &ad);
> -}
> -
>  static int ipc_alloc_security(struct task_struct *task,
>  			      struct kern_ipc_perm *perm,
>  			      u16 sclass)
> @@ -5477,7 +5459,6 @@ static struct security_operations selinux_ops = {
>  	.vm_enough_memory =		selinux_vm_enough_memory,
>  
>  	.netlink_send =			selinux_netlink_send,
> -	.netlink_recv =			selinux_netlink_recv,
>  
>  	.bprm_set_creds =		selinux_bprm_set_creds,
>  	.bprm_committing_creds =	selinux_bprm_committing_creds,
> 
> 
