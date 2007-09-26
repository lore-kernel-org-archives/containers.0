From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] Remove unused member from nsproxy
Date: Wed, 26 Sep 2007 08:28:10 -0500
Message-ID: <20070926132810.GA27366@sergelap.austin.ibm.com>
References: <46FA5B39.1010204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758727AbXIZN20@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46FA5B39.1010204@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Serge Hallyn <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul@openvz.org):
> The nslock spinlock is not used in the kernel at all. 
> Remove it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Serge Hallyn <serue@us.ibm.com>

> ---
> 
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index a3f2541..cae35b6 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -73,7 +73,6 @@ extern struct nsproxy init_nsproxy;
>  #define INIT_NSPROXY(nsproxy) {						\
>  	.pid_ns		= &init_pid_ns,					\
>  	.count		= ATOMIC_INIT(1),				\
> -	.nslock		= __SPIN_LOCK_UNLOCKED(nsproxy.nslock),		\
>  	.uts_ns		= &init_uts_ns,					\
>  	.mnt_ns		= NULL,						\
>  	INIT_NET_NS(net_ns)                                             \
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index 4d564d8..0e66b57 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -23,7 +23,6 @@ struct pid_namespace;
>   */
>  struct nsproxy {
>  	atomic_t count;
> -	spinlock_t nslock;
>  	struct uts_namespace *uts_ns;
>  	struct ipc_namespace *ipc_ns;
>  	struct mnt_namespace *mnt_ns;
