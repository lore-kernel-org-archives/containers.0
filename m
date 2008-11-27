From: Nadia Derbey <Nadia.Derbey@bull.net>
Subject: Re: [RFC][PATCH 2/5] pid: Generalize task_active_pid_ns
Date: Thu, 27 Nov 2008 14:09:31 +0100
Message-ID: <1227791371.2615.109.camel@frecb000730.frec.bull.fr>
References: <20081126034242.GA23120@us.ibm.com>
	 <20081126034528.GB23238@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755799AbYK0NLf@vger.kernel.org>
In-Reply-To: <20081126034528.GB23238@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Tue, 2008-11-25 at 19:45 -0800, Sukadev Bhattiprolu wrote:
> >From 7f7caaa9d9014d7230dc0b1e0f75536f0b6ccdbf Mon Sep 17 00:00:00 2001
> From: Eric W. Biederman <ebiederm@xmission.com>
> Date: Mon, 10 Nov 2008 19:12:02 -0800
> Subject: [PATCH 2/5] pid: Generalize task_active_pid_ns
> 
> Currently task_active_pid_ns is not safe to call after a
> task becomes a zombie and exit_task_namespaces is called,
> as nsproxy becomes NULL.  By reading the pid namespace from
> the pid of the task we can trivially solve this problem at
> the cost of one extra memory read in what should be the
> same cacheline as we read the namespace from.
> 
> When moving things around I have made task_active_pid_ns
> out of line because keeping it in pid_namespace.h would
> require adding includes of pid.h and sched.h that I
> don't think we want.
> 
> This change does make task_active_pid_ns unsafe to call during
> copy_process until we attach a pid on the task_struct which
> seems to be a reasonable trade off.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/linux/pid_namespace.h |    6 +-----
>  kernel/fork.c                 |    4 ++--
>  kernel/pid.c                  |    6 ++++++
>  3 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
> index d82fe82..38d1032 100644
> --- a/include/linux/pid_namespace.h
> +++ b/include/linux/pid_namespace.h
> @@ -79,11 +79,7 @@ static inline void zap_pid_ns_processes(struct pid_namespace *ns)
>  }
>  #endif /* CONFIG_PID_NS */
>  
> -static inline struct pid_namespace *task_active_pid_ns(struct task_struct *tsk)
> -{
> -	return tsk->nsproxy->pid_ns;
> -}
> -
> +extern struct pid_namespace *task_active_pid_ns(struct task_struct *tsk);
>  void pidhash_init(void);
>  void pidmap_init(void);
>  
> diff --git a/kernel/fork.c b/kernel/fork.c
> index f608356..28be39a 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1111,12 +1111,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  

Suka,

I'm wondering if it is still safe to keep the call to
task_active_pid_ns() in create_new_namespaces(): copy_namespaces() is
called a couple of lines above this sequence and it calls
create_new_namespaces(). So I don't see why you're now referencing
p->nsproxy->pid_ns here and not in create_new_namespaces()?

Regards,
Nadia

>  	if (pid != &init_struct_pid) {
>  		retval = -ENOMEM;
> -		pid = alloc_pid(task_active_pid_ns(p));
> +		pid = alloc_pid(p->nsproxy->pid_ns);
>  		if (!pid)
>  			goto bad_fork_cleanup_io;
>  
>  		if (clone_flags & CLONE_NEWPID) {
> -			retval = pid_ns_prepare_proc(task_active_pid_ns(p));
> +			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
>  			if (retval < 0)
>  				goto bad_fork_free_pid;
>  		}
> diff --git a/kernel/pid.c b/kernel/pid.c
> index 064e76a..c5513fe 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -474,6 +474,12 @@ pid_t task_session_nr_ns(struct task_struct *tsk, struct pid_namespace *ns)
>  }
>  EXPORT_SYMBOL(task_session_nr_ns);
>  
> +struct pid_namespace *task_active_pid_ns(struct task_struct *tsk)
> +{
> +	return ns_of_pid(task_pid(tsk));
> +}
> +EXPORT_SYMBOL_GPL(task_active_pid_ns);
> +
>  /*
>   * Used by proc to find the first pid that is greater then or equal to nr.
>   *
-- 
Nadia Derbey <Nadia.Derbey@bull.net>
