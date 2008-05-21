From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH -mm] remove node_ prefix_from ns subsystem
Date: Wed, 21 May 2008 15:03:47 -0500
Message-ID: <20080521200347.GA25307@sergelap.austin.ibm.com>
References: <48344409.9090903@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932964AbYEUUEc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48344409.9090903@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Serge E. Hallyn" <serue@us.ibm.com>, Paul Menage <menage@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg@fr.ibm.com):
> From: Cedric Le Goater <clg@fr.ibm.com>
> 
> This is a slight change in the namespace cgroup subsystem api.
> 
> Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>

I agree that is preferable.

Acked-by: Serge Hallyn <serue@us.ibm.com>

> ---
>  kernel/cgroup.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: 2.6.26-rc2-mm1/kernel/cgroup.c
> ===================================================================
> --- 2.6.26-rc2-mm1.orig/kernel/cgroup.c
> +++ 2.6.26-rc2-mm1/kernel/cgroup.c
> @@ -2903,7 +2903,7 @@ int cgroup_clone(struct task_struct *tsk
>  	cg = tsk->cgroups;
>  	parent = task_cgroup(tsk, subsys->subsys_id);
> 
> -	snprintf(nodename, MAX_CGROUP_TYPE_NAMELEN, "node_%d", tsk->pid);
> +	snprintf(nodename, MAX_CGROUP_TYPE_NAMELEN, "%d", tsk->pid);
> 
>  	/* Pin the hierarchy */
>  	atomic_inc(&parent->root->sb->s_active);
