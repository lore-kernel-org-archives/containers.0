From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 5/5] Move alloc_pid call to copy_process
Date: Tue, 17 Jul 2007 17:34:30 +0400
Message-ID: <20070717133430.GA214@tv-sign.ru>
References: <20070715123600.GA210@tv-sign.ru> <20070716225411.GH25053@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756664AbXGQNeD@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070716225411.GH25053@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Cedric Le Goater <clg@fr.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Herbert Poetzel <herbert@13thfloor.at>, Pavel Emelianov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 07/16, sukadev@us.ibm.com wrote:
>
> Oleg Nesterov [oleg@tv-sign.ru] wrote:
> | 
> | Could you please give more details why we need this change?
> 
> Well, with multiple pid namespaces, we may need to allocate a new
> 'struct pid_namespace' if the CLONE_NEWPID flag is specified. And
> as a part of initializing this pid_namespace, we need the 'task_struct'
> that will be the reaper of the new pid namespace.
> 
> And this task_struct is allocated in copy_process(). So we could
> still alloc_pid() in do_fork(), as we are doing currently and set
> the reaper of the new pid_namespace later in copy_process(). But
> that seemed to complicate error handling and add checks again in
> copy_process() for the CLONE_NEWPID.

OK, thanks.

> 
> | Even if we really need this, can't we do these checks in copy_process() ?
> 
> We could and I did have a check in copy_process() in one of my earlier
> versions to Containers@ list.  We thought it cluttered copy_process() a
> bit.

Yes, but having the "pid == &init_struct_pid" in free_pid() is imho worse,

>  	container_exit(p, container_callbacks_done);
>  	delayacct_tsk_free(p);
> +	free_pid(pid);
> +bad_fork_put_binfmt_module:
> [...snip...]
> @@ -206,6 +206,10 @@ fastcall void free_pid(struct pid *pid)
>  	/* We can be called with write_lock_irq(&tasklist_lock) held */
>  	unsigned long flags;
>  
> +	/* check this here to keep copy_process() cleaner */
> +	if (unlikely(pid == &init_struct_pid))
> +		return;
> +

Wouldn't it better if copy_process()'s error path does

	if (pid != &init_struct_pid)
		free_pid(pid);

instead? OK, "cleaner" is a matter of taste, but from the perfomance POV
this would be better, even if not noticable.

Oleg.
