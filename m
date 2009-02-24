From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: debugging threaded apps running under a clone(CLONE_NEWPID)
Date: Tue, 24 Feb 2009 12:28:52 +0100
Message-ID: <1235474932.12827.62.camel@bahia>
References: <499EE0D1.1010001@fr.ibm.com>
	 <20090223182153.GD13151@us.ibm.com>  <49A3C314.6010806@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756353AbZBXL3O@vger.kernel.org>
In-Reply-To: <49A3C314.6010806@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-02-24 at 10:51 +0100, Cedric Le Goater wrote:
> Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
> ---
>  fs/proc/base.c |   19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> Index: 2.6.27-mcr.git/fs/proc/base.c
> ===================================================================
> --- 2.6.27-mcr.git.orig/fs/proc/base.c
> +++ 2.6.27-mcr.git/fs/proc/base.c
> @@ -2444,6 +2444,23 @@ static int proc_tgid_io_accounting(struc
>  }
>  #endif /* CONFIG_TASK_IO_ACCOUNTING */
> 
> +static int proc_pid_vpids(struct task_struct *task, char *buffer)
> +{
> +	struct pid_namespace *pid_ns = task->nsproxy->pid_ns;
> +

This breaks if task is a zombie...

> +	return sprintf(buffer, "%6d %6d %6d %6d %6d %6d %6d %6d %6d %6d\n",
> +		       task_pid_nr_ns(task, pid_ns), // pid
> +		       task_pid_nr(task),
> +		       task_tgid_nr_ns(task, pid_ns), // tgid
> +		       task_tgid_nr(task),
> +		       task_tgid_nr_ns(task->real_parent, pid_ns), // ppid
> +		       task_tgid_nr(task->real_parent),
> +		       task_pgrp_nr_ns(task, pid_ns), // pgid
> +		       task_pgrp_nr(task),
> +		       task_session_nr_ns(task, pid_ns), // sid
> +		       task_session_nr(task));
> +}
> +
>  /*
>   * Thread groups
>   */
> @@ -2519,6 +2536,7 @@ static const struct pid_entry tgid_base_
>  #ifdef CONFIG_TASK_IO_ACCOUNTING
>  	INF("io",	S_IRUGO, tgid_io_accounting),
>  #endif
> +	INF("vpids",	S_IRUGO, pid_vpids),
>  };
> 
>  static int proc_tgid_base_readdir(struct file * filp,
> @@ -2854,6 +2872,7 @@ static const struct pid_entry tid_base_s
>  #ifdef CONFIG_TASK_IO_ACCOUNTING
>  	INF("io",	S_IRUGO, tid_io_accounting),
>  #endif
> +	INF("vpids",	S_IRUGO, pid_vpids),
>  };
> 
>  static int proc_tid_base_readdir(struct file * filp,
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
