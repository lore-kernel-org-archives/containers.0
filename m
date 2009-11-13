From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v12][PATCH 9/9] Document eclone() syscall
Date: Thu, 12 Nov 2009 19:17:36 -0600
Message-ID: <20091113011736.GB7899@us.ibm.com>
References: <20091111043440.GA9377@suka> <20091111044527.GI11393@suka>
	<20091111224126.GJ24988@suka> <20091113004531.GB23615@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091113004531.GB23615-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> (Trimmed Cc to Containers list)
> 
> Updated patch to ignore 'child_stack_size' on architectures that don't
> need it (see changelog v13).
> 
> ---
> 
> >From f87cceae72c2032d67e7855953c0f702957f723a Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 12 Nov 2009 15:00:38 -0800
> Subject: [v13][PATCH 9/9] Document eclone() syscall
> 
> This gives a brief overview of the eclone() system call.  We should
> eventually describe more details in existing clone(2) man page or in
> a new man page.
> 
> Changelog[v13-rc1]:
> 	- [Nathan Lynch, Serge Hallyn] Rename ->child_stack_base to
> 	  ->child_stack and ensure ->child_stack_size is 0 on architectures
> 	  that don't need it.
> 
> Changelog[v12]:
> 	- [Serge Hallyn] Fix/simplify stack-setup in the example code
> 	- [Serge Hallyn, Oren Laadan] Rename syscall to eclone()
> 
> Changelog[v11]:
> 	- [Dave Hansen] Move clone_args validation checks to arch-indpendent
> 	  code.
> 	- [Oren Laadan] Make args_size a parameter to system call and remove
> 	  it from 'struct clone_args'
> 	- [Oren Laadan] Fix some typos and clarify the order of pids in the
> 	  @pids parameter.
> 
> Changelog[v10]:
> 	- Rename clone3() to clone_with_pids() and fix some typos.
> 	- Modify example to show usage with the ptregs implementation.
> Changelog[v9]:
> 	- [Pavel Machek]: Fix an inconsistency and rename new file to
> 	  Documentation/clone3.
> 	- [Roland McGrath, H. Peter Anvin] Updates to description and
> 	  example to reflect new prototype of clone3() and the updated/
> 	  renamed 'struct clone_args'.
> 
> Changelog[v8]:
> 	- clone2() is already in use in IA64. Rename syscall to clone3()
> 	- Add notes to say that we return -EINVAL if invalid clone flags
> 	  are specified or if the reserved fields are not 0.
> Changelog[v7]:
> 	- Rename clone_with_pids() to clone2()
> 	- Changes to reflect new prototype of clone2() (using clone_struct).
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-8jLBTbqmX/OZamtmwQBW5tBPR1lH4CV8@public.gmane.org>
> Acked-by: Oren Laadan  <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

except:

...

> +/*
> + * Allocate a stack for the clone-child and arrange to have the child
> + * execute @child_fn with @child_arg as the argument.
> + */
> +void *setup_stack(int (*child_fn)(void *), void *child_arg, int size)
> +{
> +	void *stack_base;
> +	void **stack_top;
> +
> +	stack_base = malloc(size + size);

what is this (size + size) about?
