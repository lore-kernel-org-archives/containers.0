From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] Remove unused member from nsproxy
Date: Wed, 26 Sep 2007 15:31:18 +0200
Message-ID: <46FA5F26.2030100@fr.ibm.com>
References: <46FA5B39.1010204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758962AbXIZNbe@vger.kernel.org>
In-Reply-To: <46FA5B39.1010204@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> The nslock spinlock is not used in the kernel at all. 

it's also useless now that you have put some RCU rules around it.
right ? 

C.

> Remove it.
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
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
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
