From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v12][PATCH 8/9] Define eclone() syscall
Date: Thu, 12 Nov 2009 19:12:48 -0600
Message-ID: <20091113011248.GA7899@us.ibm.com>
References: <20091111043440.GA9377@suka> <20091111044509.GH11393@suka>
	<20091111224049.GI24988@suka> <20091113004356.GA23615@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091113004356.GA23615-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> (Trimmed Cc to Containers list).
> 
> Updated patch to ignore ->child_stack_size on architectures that don't
> need it.
> 
> ---
> >From e1e9b0b6eb511058961c1fb526f44b597790bfd7 Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <suka@suka.(none)>
> Date: Tue, 20 Oct 2009 22:04:57 -0700
> Subject: [v13][PATCH 8/9] Define eclone() syscall
> 
> Container restart requires that a task have the same pid it had when it was
> checkpointed. When containers are nested the tasks within the containers
> exist in multiple pid namespaces and hence have multiple pids to specify
> during restart.
> 
> eclone(), intended for use during restart, is the same as
> clone(), except that it takes a 'pids' paramter. This parameter lets
> caller choose specific pid numbers for the child process, in the
> process's active and ancestor pid namespaces. (Descendant pid namespaces
> in general don't matter since processes don't have pids in them anyway,
> but see comments in copy_target_pids() regarding CLONE_NEWPID).
> 
> eclone() also attempts to address a second limitation of the
> clone() system call. clone() is restricted to 32 clone flags and all but
> one of these are in use. If more new clone flags are needed, we will be
> forced to define a new variant of the clone() system call. To address
> this, eclone() allows at least 64 clone flags with some room
> for more if necessary.
> 
> To prevent unprivileged processes from misusing this interface,
> eclone() currently needs CAP_SYS_ADMIN, when the 'pids' parameter
> is non-NULL.
> 
> See Documentation/eclone in next patch for more details and an
> example of its usage.
> 
> NOTE:
> 	- System calls are restricted to 6 parameters and the number and sizes
> 	  of parameters needed for eclone() exceed 6 integers. The new
> 	  prototype works around this restriction while providing some
> 	  flexibility if eclone() needs to be further extended in the
> 	  future.
> TODO:
> 	- We should convert clone-flags to 64-bit value in all architectures.
> 	  Its probably best to do that as a separate patchset since clone_flags
> 	  touches several functions and that patchset seems independent of this
> 	  new system call.
> 
> Changelog[v13-rc1]:
> 	- [Nathan Lynch, Serge Hallyn] Rename ->child_stack_base to
> 	  ->child_stack and ensure ->child_stack_size is 0 on architectures
> 	  that don't need it (see comments in types.h for details).
> 
> Changelog[v12]:
> 	- [Serge Hallyn] Ignore ->child_stack_size if ->child_stack_base
> 	  is NULL.
> 	- [Oren Laadan, Serge Hallyn] Rename clone_with_pids() to eclone()
> Changelog[v11]:
> 	- [Dave Hansen] Move clone_args validation checks to arch-indpeendent
> 	  code.
> 	- [Oren Laadan] Make args_size a parameter to system call and remove
> 	  it from 'struct clone_args'
> 
> Changelog[v10]:
> 	- Rename clone3() to clone_with_pids()
> 	- [Linus Torvalds] Use PTREGSCALL() rather than the generic syscall
> 	  implementation
> 
> Changelog[v9]:
> 	- [Roland McGrath, H. Peter Anvin] To avoid confusion on 64-bit
> 	  architectures split the new clone-flags into 'low' and 'high'
> 	  words and pass in the 'lower' flags as the first argument.
> 	  This would maintain similarity of the clone3() with clone()/
> 	  clone2(). Also has the side-effect of the name matching the
> 	  number of parameters :-)
> 	- [Roland McGrath] Rename structure to 'clone_args' and add a
> 	  'child_stack_size' field
> 
> Changelog[v8]
> 	- [Oren Laadan] parent_tid and child_tid fields in 'struct clone_arg'
> 	  must be 64-bit.
> 	- clone2() is in use in IA64. Rename system call to clone3().
> 
> Changelog[v7]:
> 	- [Peter Zijlstra, Arnd Bergmann] Rename system call to clone2()
> 	  and group parameters into a new 'struct clone_struct' object.
> 
> Changelog[v6]:
> 	- (Nathan Lynch, Arnd Bergmann, H. Peter Anvin, Linus Torvalds)
> 	  Change 'pid_set.pids' to a 'pid_t pids[]' so size of 'struct pid_set'
> 	  is constant across architectures.
> 	- (Nathan Lynch) Change pid_set.num_pids to unsigned and remove
> 	  'unum_pids < 0' check.
> 
> Changelog[v4]:
> 	- (Oren Laadan) rename 'struct target_pid_set' to 'struct pid_set'
> 
> Changelog[v3]:
> 	- (Oren Laadan) Allow CLONE_NEWPID flag (by allocating an extra pid
> 	  in the target_pids[] list and setting it 0. See copy_target_pids()).
> 	- (Oren Laadan) Specified target pids should apply only to youngest
> 	  pid-namespaces (see copy_target_pids())
> 	- (Matt Helsley) Update patch description.
> 
> Changelog[v2]:
> 	- Remove unnecessary printk and add a note to callers of
> 	  copy_target_pids() to free target_pids.
> 	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
> 	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
> 	  'num_pids == 0' (fall back to normal clone()).
> 	- Move arch-independent code (sanity checks and copy-in of target-pids)
> 	  into kernel/fork.c and simplify sys_clone_with_pids()
> 
> Changelog[v1]:
> 	- Fixed some compile errors (had fixed these errors earlier in my
> 	  git tree but had not refreshed patches before emailing them)
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
