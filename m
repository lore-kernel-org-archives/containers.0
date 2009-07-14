From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-rc2,
	created. v2.6.27-rc5-45616-g96b7bc2
Date: Tue, 14 Jul 2009 17:15:25 -0400
Message-ID: <200907142115.n6ELFPpO009839@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v17-rc2 has been created
        at  96b7bc2d23eafb041f72be1f33911385e31835df (commit)

- Log -----------------------------------------------------------------
commit 96b7bc2d23eafb041f72be1f33911385e31835df
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:27 2009 -0400

    c/r: checkpoint and restore (shared) task's sighand_struct
    
    This patch adds the checkpointing and restart of signal handling
    state - 'struct sighand_struct'. Since the contents of this state
    only affect userspace, no input validation is required.
    
    Add _NSIG to kernel constants saved/tested with image header.
    
    Number of signals (_NSIG) is arch-dependent, but is within __KERNEL__
    and not visibile to userspace compile. Therefore, define per arch
    CKPT_ARCH_NSIG in <asm/checkpoint_hdr.h>.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c5f8ef7d9fb0281fa31f94094ac6122661965ca6
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:26 2009 -0400

    cr: restore file->f_cred
    
    Restore a file's f_cred.  This is set to the cred of the task doing
    the open, so often it will be the same as that of the restarted task.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit b6c9c855baafcb301bf8ad413cfd53cb86c44ce5
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:26 2009 -0400

    cr: checkpoint and restore task credentials
    
    This patch adds the checkpointing and restart of credentials
    (uids, gids, and capabilities) to Oren's c/r patchset (on top
    of v14).  It goes to great pains to re-use (and define when
    needed) common helpers, in order to make sure that as security
    code is modified, the cr code will be updated.  Some of the
    helpers should still be moved (i.e. _creds() functions should
    be in kernel/cred.c).
    
    When building the credentials for the restarted process, I
    1. create a new struct cred as a copy of the running task's
    cred (using prepare_cred())
    2. always authorize any changes to the new struct cred
    based on the permissions of current_cred() (not the current
    transient state of the new cred).
    
    While this may mean that certain transient_cred1->transient_cred2
    states are allowed which otherwise wouldn't be allowed, the
    fact remains that current_cred() is allowed to transition to
    transient_cred2.
    
    The reconstructed creds are applied to the task at the very
    end of the sys_restart call.  This ensures that any objects which
    need to be re-created (file, socket, etc) are re-created using
    the creds of the task calling sys_restart - preventing an unpriv
    user from creating a privileged object, and ensuring that a
    root task can restart a process which had started out privileged,
    created some privileged objects, then dropped its privilege.
    
    With these patches, the root user can restart checkpoint images
    (created by either hallyn or root) of user hallyn's tasks,
    resulting in a program owned by hallyn.
    
    Changelog:
    	Jun 15: Fix user_ns handling when !CONFIG_USER_N
    	        Set creator_ref=0 for root_ns (discard @flags)
    		Don't  overwrite global user-ns if CONFIG_USER_NS
    	Jun 10: Merge with ckpt-v16-dev (Oren Laadan)
    	Jun 01: Don't check ordering of groups in group_info, bc
    		set_groups() will sort it for us.
    	May 28: 1. Restore securebits
    		2. Address Alexey's comments: move prototypes out of
    		   sched.h, validate ngroups < NGROUPS_MAX, validate
    		   groups are sorted, and get rid of ckpt_hdr_cred->version.
    		3. remove bogus unused flag RESTORE_CREATE_USERNS
    	May 26: Move group, user, userns, creds c/r functions out
    		of checkpoint/process.c and into the appropriate files.
    	May 26: Define struct ckpt_hdr_task_creds and move task cred
    		objref c/r into {checkpoint_restore}_task_shared().
    	May 26: Take cred refs around checkpoint_write_creds()
    	May 20: Remove the limit on number of groups in groupinfo
    		at checkpoint time
    	May 20: Remove the depth limit on empty user namespaces
    	May 20: Better document checkpoint_user
    	May 18: fix more refcounting: if (userns 5, uid 0) had
    		no active tasks or child user_namespaces, then
    		it shouldn't exist at restart or it, its namespace,
    		and its whole chain of creators will be leaked.
    	May 14: fix some refcounting:
    		1. a new user_ns needs a ref to remain pinned
    		   by its root user
    		2. current_user_ns needs an extra ref bc objhash
    		   drops two on restart
    		3. cred needs a ref for the real credentials bc
    		   commit_creds eats one ref.
    	May 13: folded in fix to userns refcounting.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: merge with ckpt-v16-dev]

commit 14c39d14af79b65edef43393c28de6739ebc2109
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:26 2009 -0400

    cr: capabilities: define checkpoint and restore fns
    
    [ Andrew: I am punting on dealing with the subsystem cooperation
    issues in this version, in favor of trying to get LSM issues
    straightened out ]
    
    An application checkpoint image will store capability sets
    (and the bounding set) as __u64s.  Define checkpoint and
    restart functions to translate between those and kernel_cap_t's.
    
    Define a common function do_capset_tocred() which applies capability
    set changes to a passed-in struct cred.
    
    The restore function uses do_capset_tocred() to apply the restored
    capabilities to the struct cred being crafted, subject to the
    current task's (task executing sys_restart()) permissions.
    
    Changelog:
    	Jun 09: Can't choose securebits or drop bounding set if
    		file capabilities aren't compiled into the kernel.
    		Also just store caps in __u32s (looks cleaner).
    	Jun 01: Made the checkpoint and restore functions and the
    		ckpt_hdr_capabilities struct more opaque to the
    		rest of the c/r code, as suggested by Andrew Morgan,
    		and using naming suggested by Oren.
    	Jun 01: Add commented BUILD_BUG_ON() to point out that the
    		current implementation depends on 64-bit capabilities.
    		(Andrew Morgan and Alexey Dobriyan).
    	May 28: add helpers to c/r securebits
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 61bc6aaa6c6367f76fc42f8436d03f000fa8271e
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:25 2009 -0400

    tFrom: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    
    clone_with_pids: define the s390 syscall
    
    Hook up the clone_with_pids system call for s390x.  clone_with_pids()
    takes an additional argument over clone(), which we pass in through
    register 7.  Stub code for using the syscall looks like:
    
    struct target_pid_set {
            int num_pids;
            pid_t *target_pids;
            unsigned long flags;
    };
    
        register unsigned long int __r2 asm ("2") = (unsigned long int)(stack);
        register unsigned long int __r3 asm ("3") = (unsigned long int)(flags);
        register unsigned long int __r4 asm ("4") = (unsigned long int)(NULL);
        register unsigned long int __r5 asm ("5") = (unsigned long int)(NULL);
        register unsigned long int __r6 asm ("6") = (unsigned long int)(NULL);
        register unsigned long int __r7 asm ("7") = (unsigned long int)(setp);
        register unsigned long int __result asm ("2");
        __asm__ __volatile__(
                " lghi %%r1,332\n"
                " svc 0\n"
                : "=d" (__result)
                : "0" (__r2), "d" (__r3),
                  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7)
                : "1", "cc", "memory"
        );
                __result;
        })
    
        struct target_pid_set pid_set;
        int pids[1] = { 19799 };
        pid_set.num_pids = 1;
        pid_set.target_pids = &pids[0];
        pid_set.flags = 0;
    
        rc = do_clone_with_pids(topstack, clone_flags, setp);
        if (rc == 0)
    	printf("Child\n");
        else if (rc > 0)
    	printf("Parent: child pid %d\n", rc);
        else
    	printf("Error %d\n", rc);
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit af648275ebbe6713b8f7e476966fd649e34d3952
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:25 2009 -0400

    c/r: define s390-specific checkpoint-restart code
    
    Implement the s390 arch-specific checkpoint/restart helpers.  This
    is on top of Oren Laadan's c/r code.
    
    With these, I am able to checkpoint and restart simple programs as per
    Oren's patch intro.  While on x86 I never had to freeze a single task
    to checkpoint it, on s390 I do need to.  That is a prereq for consistent
    snapshots (esp with multiple processes) anyway so I don't see that as
    a problem.
    
    Changelog:
        Jun 15:
                . Fix checkpoint and restart compat wrappers
        May 28:
                . Export asm/checkpoint_hdr.h to userspace
                . Define CKPT_ARCH_ID for S390
        Apr 11:
                . Introduce ckpt_arch_vdso()
        Feb 27:
                . Add checkpoint_s390.h
                . Fixed up save and restore of PSW, with the non-address bits
                  properly masked out
        Feb 25:
                . Make checkpoint_hdr.h safe for inclusion in userspace
                . Replace comment about vsdo code
                . Add comment about restoring access registers
                . Write and read an empty ckpt_hdr_head_arch record to appease
                  code (mktree) that expects it to be there
                . Utilize NUM_CKPT_WORDS in checkpoint_hdr.h
        Feb 24:
                . Use CKPT_COPY() to unify the un/loading of cpu and mm state
                . Fix fprs definition in ckpt_hdr_cpu
                . Remove debug WARN_ON() from checkpoint.c
        Feb 23:
                . Macro-ize the un/packing of trace flags
                . Fix the crash when externally-linked
                . Break out the restart functions into restart.c
                . Remove unneeded s390_enable_sie() call
        Jan 30:
                . Switched types in ckpt_hdr_cpu to __u64 etc.
                  (Per Oren suggestion)
                . Replaced direct inclusion of structs in
                  ckpt_hdr_cpu with the struct members.
                  (Per Oren suggestion)
                . Also ended up adding a bunch of new things
                  into restart (mm_segment, ksp, etc) in vain
                  attempt to get code using fpu to not segfault
                  after restart.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 50ee8dcafcaf75b63ff0f51f017ac62d4e6a7c92
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:25 2009 -0400

    c/r: add CKPT_COPY() macro
    
    As suggested by Dave[1], this provides us a way to make the copy-in and
    copy-out processes symmetric.  CKPT_COPY_ARRAY() provides us a way to do
    the same thing but for arrays.  It's not critical, but it helps us unify
    the checkpoint and restart paths for some things.
    
    Changelog:
        Mar 04:
                . Removed semicolons
                . Added build-time check for __must_be_array in CKPT_COPY_ARRAY
        Feb 27:
                . Changed CKPT_COPY() to use assignment, eliminating the need
                  for the CKPT_COPY_BIT() macro
                . Add CKPT_COPY_ARRAY() macro to help copying register arrays,
                  etc
                . Move the macro definitions inside the CR #ifdef
        Feb 25:
                . Changed WARN_ON() to BUILD_BUG_ON()
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    
    1: https://lists.linux-foundation.org/pipermail/containers/2009-February/015821.html (all the way at the bottom)

commit 5107325f60e56dc04677090b564655e6561670eb
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:24 2009 -0400

    c/r: (s390): expose a constant for the number of words (CRs)
    
    We need to use this value in the checkpoint/restart code and would like to
    have a constant instead of a magic '3'.
    
    Changelog:
        Mar 30:
                . Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)
        Mar 03:
                . Picked up additional use of magic '3' in ptrace.h
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit e7c114704b543781c1b27f8d22894b197224fd22
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:24 2009 -0400

    c/r: support semaphore sysv-ipc
    
    Checkpoint of sysvipc semaphores is performed by iterating through all
    sem objects and dumping the contents of each one. The semaphore array
    of each sem is dumped with that object.
    
    The semaphore array (sem->sem_base) holds an array of 'struct sem',
    which is a {int, int}. Because this translates into the same format
    on 32- and 64-bit architectures, the checkpoint format is simply the
    dump of this array as is.
    
    TODO: this patch does not handle semaphore-undo -- this data should be
    saved per-task while iterating through the tasks.
    
    Changelog[v17]:
      - Restore objects in the right namespace
      - Forward declare struct msg_msg (instead of include linux/msg.h)
      - Fix typo in comment
      - Don't unlock ipc before calling freeary in error path
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 45d915251fea5df431536c0dd9318942003f08a6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:24 2009 -0400

    c/r: support message-queues sysv-ipc
    
    Checkpoint of sysvipc message-queues is performed by iterating through
    all 'msq' objects and dumping the contents of each one. The message
    queued on each 'msq' are dumped with that object.
    
    Message of a specific queue get written one by one. The queue lock
    cannot be held while dumping them, but the loop must be protected from
    someone (who ?) writing or reading. To do that we grab the lock, then
    hijack the entire chain of messages from the queue, drop the lock,
    and then safely dump them in a loop. Finally, with the lock held, we
    re-attach the chain while verifying that there isn't other (new) data
    on that queue.
    
    Writing the message contents themselves is straight forward. The code
    is similar to that in ipc/msgutil.c, the main difference being that
    we deal with kernel memory and not user memory.
    
    Changelog[v17]:
      - Allocate security context for msg_msg
      - Restore objects in the right namespace
      - Don't unlock ipc before freeing
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit af2c185e20e0cf71bc05341913bdaaebc6e0749c
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:23 2009 -0400

    c/r: support share-memory sysv-ipc
    
    Checkpoint of sysvipc shared memory is performed in two steps: first,
    the entire ipc namespace is dumped as a whole by iterating through all
    shm objects and dumping the contents of each one. The shmem inode is
    registered in the objhash. Second, for each vma that refers to ipc
    shared memory we find the inode in the objhash, and save the objref.
    
    (If we find a new inode, that indicates that the ipc namespace is not
    entirely frozen and someone must have manipulated it since step 1).
    
    Handling of shm objects that have been deleted (via IPC_RMID) is left
    to a later patch in this series.
    
    Changelog[v17]:
      - Restore objects in the right namespace
      - Properly initialize ctx->deferqueue
      - Fix compilation with CONFIG_CHECKPOINT=n
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 5850cd1d2170655d97a17fbc0f085055270c1bf9
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:23 2009 -0400

    c/r: save and restore sysvipc namespace basics
    
    Add the helpers to checkpoint and restore the contents of 'struct
    kern_ipc_perm'. Add header structures for ipc state. Put place-holders
    to save and restore ipc state.
    
    Save and restores the common state (parameters) of ipc namespace.
    
    Generic code to iterate through the objects of sysvipc shared memory,
    message queues and semaphores. The logic to save and restore the state
    of these objects will be added in the next few patches.
    
    Right now, we return -EPERM if the user calling sys_restart() isn't
    allowed to create an object with the checkpointed uid.  We may prefer
    to simply use the caller's uid in that case - but that could lead to
    subtle userspace bugs?  Unsure, so going for the stricter behavior.
    
    TODO: restore kern_ipc_perms->security.
    
    Changelog[v17]:
      - Collect nsproxy->ipc_ns
      - Restore objects in the right namespace
      - If !CONFIG_IPC_NS only restore objects, not global settings
      - Don't overwrite global ipc-ns if !CONFIG_IPC_NS
      - Reset the checkpointed uid and gid info on ipc objects
      - Fix compilation with CONFIG_SYSVIPC=n
    Changelog [Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>]
      - Fix compilation with CONFIG_SYSVIPC=n
      - Update to match UTS changes
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c6315e096564a043058c83f4b41eb97ff7cc7f1f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:23 2009 -0400

    c/r (ipc): allow allocation of a desired ipc identifier
    
    During restart, we need to allocate ipc objects that with the same
    identifiers as recorded during checkpoint. Modify the allocation
    code allow an in-kernel caller to request a specific ipc identifier.
    The system call interface remains unchanged.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 2e009ef7a182c1024f8c089cef743c677c5a77d5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:23 2009 -0400

    deferqueue: generic queue to defer work
    
    Add a interface to postpone an action until the end of the entire
    checkpoint or restart operation. This is useful when during the
    scan of tasks an operation cannot be performed in place, to avoid
    the need for a second scan.
    
    One use case is when restoring an ipc shared memory region that has
    been deleted (but is still attached), during restart it needs to be
    create, attached and then deleted. However, creation and attachment
    are performed in distinct locations, so deletion can not be performed
    on the spot. Instead, this work (delete) is deferred until later.
    (This example is in one of the following patches).
    
    This interface allows chronic procrastination in the kernel:
    
    deferqueue_create(void):
        Allocates and returns a new deferqueue.
    
    deferqueue_run(deferqueue):
        Executes all the pending works in the queue. Returns the number
        of works executed, or an error upon the first error reported by
        a deferred work.
    
    deferqueue_add(deferqueue, data, size, func, dtor):
        Enqueue a deferred work. @function is the callback function to
        do the work, which will be called with @data as an argument.
        @size tells the size of data. @dtor is a destructor callback
        that is invoked for deferred works remaining in the queue when
        the queue is destroyed. NOTE: for a given deferred work, @dtor
        is _not_ called if @func was already called (regardless of the
        return value of the latter).
    
    deferqueue_destroy(deferqueue):
        Free the deferqueue and any queued items while invoking the
        @dtor callback for each queued item.
    
    Why aren't we using the existing kernel workqueue mechanism?  We need
    to defer to work until the end of the operation: not earlier, since we
    need other things to be in place; not later, to not block waiting for
    it. However, the workqueue schedules the work for 'some time later'.
    Also, the kernel workqueue may run in any task context, but we require
    many times that an operation be run in the context of some specific
    restarting task (e.g., restoring IPC state of a certain ipc_ns).
    
    Instead, this mechanism is a simple way for the c/r operation as a
    whole, and later a task in particular, to defer some action until
    later (but not arbitrarily later) _in the restore_ operation.
    
    Changelog[v17]
      - Fix deferqueue_add() function
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 60d441c5a3315d65dce2a3ad3741ee9a0ca8898f
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:22 2009 -0400

    c/r: support for UTS namespace
    
    This patch adds a "phase" of checkpoint that saves out information about any
    namespaces the task(s) may have.  Do this by tracking the namespace objects
    of the tasks and making sure that tasks with the same namespace that follow
    get properly referenced in the checkpoint stream.
    
    Changes[v17]:
      - Collect nsproxy->uts_ns
      - Save uts string lengths once in ckpt_hdr_const
      - Save and restore all fields of uts-ns
      - Don't overwrite global uts-ns if !CONFIG_UTS_NS
      - Replace sys_unshare() with create_uts_ns()
      - Take uts_sem around access to uts data
    Changes:
      - Remove the kernel restore path
      - Punt on nested namespaces
      - Use __NEW_UTS_LEN in nodename and domainname buffers
      - Add a note to Documentation/checkpoint/internals.txt to indicate where
        in the save/restore process the UTS information is kept
      - Store (and track) the objref of the namespace itself instead of the
        nsproxy (based on comments from Dave on IRC)
      - Remove explicit check for non-root nsproxy
      - Store the nodename and domainname lengths and use ckpt_write_string()
        to store the actual name strings
      - Catch failure of ckpt_obj_add_ptr() in ckpt_write_namespaces()
      - Remove "types" bitfield and use the "is this new" flag to determine
        whether or not we should write out a new ns descriptor
      - Replace kernel restore path
      - Move the namespace information to be directly after the task
        information record
      - Update Documentation to reflect new location of namespace info
      - Support checkpoint and restart of nested UTS namespaces
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit f1c59e1daa86933efa233974da953463677a3e87
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:22 2009 -0400

    c/r: make ckpt_may_checkpoint_task() check each namespace individually
    
    For a given namespace type, say XXX, if a checkpoint was taken on a
    CONFIG_XXX_NS system, is restarted on a !CONFIG_XXX_NS, then ensure
    that:
    
    1) The global settings of the global (init) namespace do not get
    overwritten. Creating new objects in that namespace is ok, as long as
    the request identifier is available.
    
    2) All restarting tasks use a single namespace - because it is
    impossible to create additional namespaces to accommodate for what had
    been checkpointed.
    
    Original patch introducing nsproxy c/r by Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    
    Chagnelog[v17]:
      - Only collect sub-objects of struct_nsproxy once.
      - Restore namespace pieces directly instead of using sys_unshare()
      - Proper handling of restart from namespace(s) without namespace(s)
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 50c3d33d1163cca20007ed8aee8efad76f90b40f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:22 2009 -0400

    c/r: support for open pipes
    
    A pipe is a double-headed inode with a buffer attached to it. We
    checkpoint the pipe buffer only once, as soon as we hit one side of
    the pipe, regardless whether it is read- or write- end.
    
    To checkpoint a file descriptor that refers to a pipe (either end), we
    first lookup the inode in the hash table: If not found, it is the
    first encounter of this pipe. Besides the file descriptor, we also (a)
    save the pipe data, and (b) register the pipe inode in the hash. If
    found, it is the second encounter of this pipe, namely, as we hit the
    other end of the same pipe. In both cases we write the pipe-objref of
    the inode.
    
    To restore, create a new pipe and thus have two file pointers (read-
    and write- ends). We only use one of them, depending on which side was
    checkpointed first. We register the file pointer of the other end in
    the hash table, with the pipe_objref given for this pipe from the
    checkpoint, to be used later when the other arrives. At this point we
    also restore the contents of the pipe buffers.
    
    To save the pipe buffer, given a source pipe, use do_tee() to clone
    its contents into a temporary 'struct pipe_inode_info', and then use
    do_splice_from() to transfer it directly to the checkpoint image file.
    
    To restore the pipe buffer, with a fresh newly allocated target pipe,
    use do_splice_to() to splice the data directly between the checkpoint
    image file and the pipe.
    
    Changelog[v17]:
      - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 74bf2931853ccb1d7a0a55770b353f1e1c981613
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:21 2009 -0400

    splice: export pipe/file-to-pipe/file functionality
    
    During pipes c/r pipes we need to save and restore pipe buffers. But
    do_splice() requires two file descriptors, therefore we can't use it,
    as we always have one file descriptor (checkpoint image) and one
    pipe_inode_info.
    
    This patch exports interfaces that work at the pipe_inode_info level,
    namely link_pipe(), do_splice_to() and do_splice_from(). They are used
    in the following patch to to save and restore pipe buffers without
    unnecessary data copy.
    
    It slightly modifies both do_splice_to() and do_splice_from() to
    detect the case of pipe-to-pipe transfer, in which case they invoke
    splice_pipe_to_pipe() directly.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 31ac5ecf3232b5f7cd68fffd5d227ed19b63f423
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:21 2009 -0400

    c/r: restore anonymous- and file-mapped- shared memory
    
    The bulk of the work is in ckpt_read_vma(), which has been refactored:
    the part that create the suitable 'struct file *' for the mapping is
    now larger and moved to a separate function. What's left is to read
    the VMA description, get the file pointer, create the mapping, and
    proceed to read the contents in.
    
    Both anonymous shared VMAs that have been read earlier (as indicated
    by a look up to objhash) and file-mapped shared VMAs are skipped.
    Anonymous shared VMAs seen for the first time have their contents
    read in directly to the backing inode, as indexed by the page numbers
    (as opposed to virtual addresses).
    
    Changelog[v14]:
      - Introduce patch
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 8ecc6f36671611bacc1228c957fe9575767fbe6e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:21 2009 -0400

    c/r: dump anonymous- and file-mapped- shared memory
    
    We now handle anonymous and file-mapped shared memory. Support for IPC
    shared memory requires support for IPC first. We extend ckpt_write_vma()
    to detect shared memory VMAs and handle it separately than private
    memory.
    
    There is not much to do for file-mapped shared memory, except to force
    msync() on the region to ensure that the file system is consistent
    with the checkpoint image. Use our internal type CKPT_VMA_SHM_FILE.
    
    Anonymous shared memory is always backed by inode in shmem filesystem.
    We use that inode to look up the VMA in the objhash and register it if
    not found (on first encounter). In this case, the type of the VMA is
    CKPT_VMA_SHM_ANON, and we dump the contents. On the other hand, if it is
    found there, we must have already saved it before, so we change the
    type to CKPT_VMA_SHM_ANON_SKIP and skip it.
    
    To dump the contents of a shmem VMA, we loop through the pages of the
    inode in the shmem filesystem, and dump the contents of each dirty
    (allocated) page - unallocated pages must be clean.
    
    Note that we save the original size of a shmem VMA because it may have
    been re-mapped partially. The format itself remains like with private
    VMAs, except that instead of addresses we record _indices_ (page nr)
    into the backing inode.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 89e8044099e705beb3d7b6448036a3e3752dd65d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:20 2009 -0400

    c/r: export shmem_getpage() to support shared memory
    
    Export functionality to retrieve specific pages from shared memory
    given an inode in shmem-fs; this will be used in the next two patches
    to provide support for c/r of shared memory.
    
    mm/shmem.c:
    - shmem_getpage() and 'enum sgp_type' moved to linux/mm.h
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 6fca0df22281982abd6fee0a36e9592e6c2bfea1
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:20 2009 -0400

    c/r: restore memory address space (private memory)
    
    Restoring the memory address space begins with nuking the existing one
    of the current process, and then reading the vma state and contents.
    Call do_mmap_pgoffset() for each vma and then read in the data.
    
    Changelog[v17]:
      - Restore mm->{flags,def_flags,saved_auxv}
      - Fix bogus warning in do_restore_mm()
    Changelog[v16]:
      - Restore mm->exe_file
    Changelog[v14]:
      - Introduce per vma-type restore() function
      - Merge restart code into same file as checkpoint (memory.c)
      - Compare saved 'vdso' field of mm_context with current value
      - Check whether calls to ckpt_hbuf_get() fail
      - Discard field 'h->parent'
      - Revert change to pr_debug(), back to ckpt_debug()
    Changelog[v13]:
      - Avoid access to hh->vma_type after the header is freed
      - Test for no vma's in exit_mmap() before calling unmap_vma() (or it
        may crash if restart fails after having removed all vma's)
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v9]:
      - Introduce ckpt_ctx_checkpoint() for checkpoint-specific ctx setup
    Changelog[v7]:
      - Fix argument given to kunmap_atomic() in memory dump/restore
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
        (even though it's not really needed)
    Changelog[v5]:
      - Improve memory restore code (following Dave Hansen's comments)
      - Change dump format (and code) to allow chunks of <vaddrs, pages>
        instead of one long list of each
      - Memory restore now maps user pages explicitly to copy data into them,
        instead of reading directly to user space; got rid of mprotect_fixup()
    Changelog[v4]:
      - Use standard list_... for ckpt_pgarr
    
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit ce4e519bf5d3082a8ff150b966262076390adf0b
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:20 2009 -0400

    c/r: dump memory address space (private memory)
    
    For each vma, there is a 'struct ckpt_vma'; Then comes the actual
    contents, in one or more chunk: each chunk begins with a header that
    specifies how many pages it holds, then the virtual addresses of all
    the dumped pages in that chunk, followed by the actual contents of all
    dumped pages. A header with zero number of pages marks the end of the
    contents.  Then comes the next vma and so on.
    
    To checkpoint a vma, call the ops->checkpoint() method of that vma.
    Normally the per-vma function will invoke generic_vma_checkpoint()
    which first writes the vma description, followed by the specific
    logic to dump the contents of the pages.
    
    Currently for private mapped memory we save the pathname of the file
    that is mapped (restart will use it to re-open it and then map it).
    Later we change that to reference a file object.
    
    Changelog[v17]:
      - Only collect sub-objects of mm_struct once
      - Save mm->{flags,def_flags,saved_auxv}
    Changelog[v16]:
      - Precede vaddrs/pages with a buffer header
      - Checkpoint mm->exe_file
      - Handle shared task->mm
    Changelog[v14]:
      - Modify the ops->checkpoint method to be much more powerful
      - Improve support for VDSO (with special_mapping checkpoint callback)
      - Save new field 'vdso' in mm_context
      - Revert change to pr_debug(), back to ckpt_debug()
      - Check whether calls to ckpt_hbuf_get() fail
      - Discard field 'h->parent'
    Changelog[v13]:
      - pgprot_t is an abstract type; use the proper accessor (fix for
        64-bit powerpc (Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>)
    Changelog[v12]:
      - Hide pgarr management inside ckpt_private_vma_fill_pgarr()
      - Fix management of pgarr chain reset and alloc/expand: keep empty
        pgarr in a pool chain
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v11]:
      - Copy contents of 'init->fs->root' instead of pointing to them.
      - Add missing test for VM_MAYSHARE when dumping memory
    Changelog[v10]:
      - Acquire dcache_lock around call to __d_path() in ckpt_fill_name()
    Changelog[v9]:
      - Introduce ckpt_ctx_checkpoint() for checkpoint-specific ctx setup
      - Test if __d_path() changes mnt/dentry (when crossing filesystem
        namespace boundary). for now ckpt_fill_fname() fails the checkpoint.
    Changelog[v7]:
      - Fix argument given to kunmap_atomic() in memory dump/restore
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
        (even though it's not really needed)
    Changelog[v5]:
      - Improve memory dump code (following Dave Hansen's comments)
      - Change dump format (and code) to allow chunks of <vaddrs, pages>
        instead of one long list of each
      - Fix use of follow_page() to avoid faulting in non-present pages
    Changelog[v4]:
      - Use standard list_... for ckpt_pgarr
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit dba0c7ca96d9008bfeede6d63d3c4003c5c08866
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:19 2009 -0400

    c/r: introduce method '->checkpoint()' in struct vm_operations_struct
    
    Changelog[v17]
      - Forward-declare 'ckpt_ctx et-al, don't use checkpoint_types.h
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit b7348f33ec9db1b1cf29dd290dfdb33c1ef9802a
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:19 2009 -0400

    c/r: add generic '->checkpoint()' f_op to simple devices
    
    * /dev/null
    * /dev/zero
    * /dev/random
    * /dev/urandom
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit b1990378eacbb39729bb6f9d1badcb4f42200fd0
Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 17:08:18 2009 -0400

    c/r: add generic '->checkpoint' f_op to ext fses
    
    This marks ext[234] as being checkpointable.  There will be many
    more to do this to, but this is a start.
    
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit e7dd7f78fcd0d475f38ea6c5d56c46bd21e6b802
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:18 2009 -0400

    c/r: restore open file descriptors
    
    For each fd read 'struct ckpt_hdr_file_desc' and lookup objref in the
    hash table; If not found in the hash table, (first occurence), read in
    'struct ckpt_hdr_file', create a new file and register in the hash.
    Otherwise attach the file pointer from the hash as an FD.
    
    Changelog[v17]:
      - Validate f_mode after restore against saved f_mode
      - Fail if f_flags have O_CREAT|O_EXCL|O_NOCTTY|O_TRUN
      - Reorder patch (move earlier in series)
      - Handle shared files_struct objects
    Changelog[v14]:
      - Introduce a per file-type restore() callback
      - Revert change to pr_debug(), back to ckpt_debug()
      - Rename:  restore_files() => restore_fd_table()
      - Rename:  ckpt_read_fd_data() => restore_file()
      - Check whether calls to ckpt_hbuf_get() fail
      - Discard field 'hh->parent'
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
        (even though it's not really needed)
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e64abbd0cd0b36362c1ba0bae6fde52107a9ef23
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:18 2009 -0400

    c/r: dump open file descriptors
    
    Dump the file table with 'struct ckpt_hdr_file_table, followed by all
    open file descriptors. Because the 'struct file' corresponding to an
    fd can be shared, they are assigned an objref and registered in the
    object hash. A reference to the 'file *' is kept for as long as it
    lives in the hash (the hash is only cleaned up at the end of the
    checkpoint).
    
    Also provide generic_checkpoint_file() and generic_restore_file()
    which is good for normal files and directories. It does not support
    yet unlinked files or directories.
    
    Changelog[v17]:
      - Only collect sub-objects of files_struct once
      - Better file error debugging
      - Use (new) d_unlinked()
    Changelog[v16]:
      - Fix compile warning in checkpoint_bad()
    Changelog[v16]:
      - Reorder patch (move earlier in series)
      - Handle shared files_struct objects
    Changelog[v14]:
      - File objects are dumped/restored prior to the first reference
      - Introduce a per file-type restore() callback
      - Use struct file_operations->checkpoint()
      - Put code for generic file descriptors in a separate function
      - Use one CKPT_FILE_GENERIC for both regular files and dirs
      - Revert change to pr_debug(), back to ckpt_debug()
      - Use only unsigned fields in checkpoint headers
      - Rename:  ckpt_write_files() => checkpoint_fd_table()
      - Rename:  ckpt_write_fd_data() => checkpoint_file()
      - Discard field 'h->parent'
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v11]:
      - Discard handling of opened symlinks (there is no such thing)
      - ckpt_scan_fds() retries from scratch if hits size limits
    Changelog[v9]:
      - Fix a couple of leaks in ckpt_write_files()
      - Drop useless kfree from ckpt_scan_fds()
    Changelog[v8]:
      - initialize 'coe' to workaround gcc false warning
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
        (even though it's not really needed)
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 8ede64ce064c8cbb789c79913f4d48c47c425b44
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:18 2009 -0400

    c/r: introduce '->checkpoint()' method in 'struct file_operations'
    
    While we assume all normal files and directories can be checkpointed,
    there are, as usual in the VFS, specialized places that will always
    need an ability to override these defaults. Although we could do this
    completely in the checkpoint code, that would bitrot quickly.
    
    This adds a new 'file_operations' function for checkpointing a file.
    It is assumed that there should be a dirt-simple way to make something
    (un)checkpointable that fits in with current code.
    
    As you can see in the ext[234] patches down the road, all that we have
    to do to make something simple be supported is add a single "generic"
    f_op entry.
    
    Also introduce vfs_fcntl() so that it can be called from restart (see
    patch adding restart of files).
    
    Changelog[v17]
      - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 5595c713347321dc0dfe3c691a1245c0a0235ae8
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:17 2009 -0400

    c/r: detect resource leaks for whole-container checkpoint
    
    Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
    checkpoint, return an error code if the actual objects' counts are
    higher, indicating leaks (references to the objects from a task not
    being checkpointed).  Of course, by this time most of the checkpoint
    image has been written out to disk, so this is purely advisory.  But
    then, it's probably naive to argue that anything more than an advisory
    'this went wrong' error code is useful.
    
    The comparison of the objhash user counts to object refcounts as a
    basis for checking for leaks comes from Alexey's OpenVZ-based c/r
    patchset.
    
    "Leak detection" occurs _before_ any real state is saved, as a
    pre-step. This prevents races due to sharing with outside world where
    the sharing ceases before the leak test takes place, thus protecting
    the checkpoint image from inconsistencies.
    
    Once leak testing concludes, checkpoint will proceed. Because objects
    are already in the objhash, checkpoint_obj() cannot distinguish
    between the first and subsequent encounters. This is solved with a
    flag (CKPT_OBJ_CHECKPOINTED) per object.
    
    Two additional checks take place during checkpoint: for objects that
    were created during, and objects destroyed, while the leak-detection
    pre-step took place.
    
    Changelog[v17]:
      - Leak detection is performed in two-steps
      - Detect reverse-leaks (objects disappearing unexpectedly)
      - Skip reverse-leak detection if ops->ref_users isn't defined
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a98590564f0ce626b6d05c35f1894e96aae24d7f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:17 2009 -0400

    c/r: infrastructure for shared objects
    
    The state of shared objects is saved once. On the first encounter, the
    state is dumped and the object is assigned a unique identifier (objref)
    and also stored in a hash table (indexed by its physical kernel address).
    From then on the object will be found in the hash and only its identifier
    is saved.
    
    On restart the identifier is looked up in the hash table; if not found
    then the state is read, the object is created, and added to the hash
    table (this time indexed by its identifier). Otherwise, the object in
    the hash table is used.
    
    The hash is "one-way": objects added to it are never deleted until the
    hash it discarded. The hash is discarded at the end of checkpoint or
    restart, whether successful or not.
    
    The hash keeps a reference to every object that is added to it, matching
    the object's type, and maintains this reference during its lifetime.
    Therefore, it is always safe to use an object that is stored in the hash.
    
    Changelog[v17]:
      - Add ckpt_obj->flags with CKPT_OBJ_CHECKPOINTED flag
      - Add prototype of ckpt_obj_lookup
      - Complain on attempt to add NULL ptr to objhash
      - Prepare for 'leaks detection'
    Changelog[v16]:
      - Introduce ckpt_obj_lookup() to find an object by its ptr
    Changelog[v14]:
      - Introduce 'struct ckpt_obj_ops' to better modularize shared objs.
      - Replace long 'switch' statements with table lookups and callbacks.
      - Introduce checkpoint_obj() and restart_obj() helpers
      - Shared objects now dumped/saved right before they are referenced
      - Cleanup interface of shared objects
    Changelog[v13]:
      - Use hash_long() with 'unsigned long' cast to support 64bit archs
        (Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>)
    Changelog[v11]:
      - Doc: be explicit about grabbing a reference and object lifetime
    Changelog[v4]:
      - Fix calculation of hash table size
    Changelog[v3]:
      - Use standard hlist_... for hash table
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit fea789e4a2ccaa1cdd1e5e4c9fc9a2679b70ea9e
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 17:08:17 2009 -0400

    Save and restore the [compat_]robust_list member of the task struct.
    
    These lists record which futexes the task holds. To keep the overhead of
    robust futexes low the list is kept in userspace. When the task exits the
    kernel carefully walks these lists to recover held futexes that
    other tasks may be attempting to acquire with FUTEX_WAIT.
    
    Because they point to userspace memory that is saved/restored by
    checkpoint/restart saving the list pointers themselves is safe.
    
    While saving the pointers is safe during checkpoint, restart is tricky
    because the robust futex ABI contains provisions for changes based on
    checking the size of the list head. So we need to save the length of
    the list head too in order to make sure that the kernel used during
    restart is capable of handling that ABI. Since there is only one ABI
    supported at the moment taking the list head's size is simple. Should
    the ABI change we will need to use the same size as specified during
    sys_set_robust_list() and hence some new means of determining the length
    of this userspace structure in sys_checkpoint would be required.
    
    Rather than rewrite the logic that checks and handles the ABI we reuse
    sys_set_robust_list() by factoring out the body of the function and
    calling it during restart.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 681aac505a46b46177275bdf6cae425389a17ed5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:16 2009 -0400

    c/r: support for zombie processes
    
    During checkpoint, a zombie processes need only save p->comm,
    p->state, p->exit_state, and p->exit_code.
    
    During restart, zombie processes are created like all other
    processes. They validate the saved exit_code restore p->comm
    and p->exit_code. Then they call do_exit() instead of waking
    up the next task in line.
    
    But before, they place the @ctx in p->checkpoint_ctx, so that
    only at exit time they will wake up the next task in line,
    and drop the reference to the @ctx.
    
    This provides the guarantee that when the coordinator's wait
    completes, all normal tasks completed their restart, and all
    zombie tasks are already zombified (as opposed to perhap only
    becoming a zombie).
    
    Changelog[v17]:
      - Validate t->exit_signal for both threads and leader
      - Skip zombies in most of may_checkpoint_task()
      - Save/restore t->pdeath_signal
      - Validate ->exit_signal and ->pdeath_signal
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 07d0033191b3089d9dd65696951ac41ca5cc98e6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:16 2009 -0400

    c/r: introduce PF_RESTARTING, and skip notification on exit
    
    To restore zombie's we will create the a task, that, on its turn to
    run, calls do_exit(). Unlike normal tasks that exit, we need to
    prevent notification side effects that send signals to other
    processes, e.g. parent (SIGCHLD) or child tasks (per child's request).
    
    There are three main cases for such notifications:
    
    1) do_notify_parent(): parent of a process is notified about a change
     in status (e.g. become zombie, reparent, etc). If parent ignores,
     then mark child for immediate release (skip zombie).
    
    2) kill_orphan_pgrp(): a process group that becomes orphaned will
     signal stopped jobs (HUP then CONT).
    
    3) reparent_thread(): children of a process are signaled (per request)
     with p->pdeath_signal
    
    Remember that restoring signal state (for any restarting task) must
    complete _before_ it is allowed to resume execution, and not during
    the resume. Otherwise, a running task may send a signal to another
    task that hasn't restored yet, so the new signal will be lost
    soon-after.
    
    I considered two possible way to address this:
    
    1. Add another sync point to restart: all tasks will first restore
    their state without signals (all signals blocked), and zombies call
    do_exit(). A sync point then will ensure that all zombies are gone and
    their effects done. Then all tasks restore their signal state (and
    mask), and sync (new point) again. Only then they may resume
    execution.
    The main disadvantage is the added complexity and inefficiency,
    for no good reason.
    
    2. Introduce PF_RESTARTING: mark all restarting tasks with a new flag,
    and teach the above three notifications to skip sending the signal if
    theis flag is set.
    The main advantage is simplicity and completeness. Also, such a flag
    may to be useful later on. This the method implemented.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e8304d20bc3ad7c7cf725cd323763d2de3df5068
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 17:08:11 2009 -0400

    c/r: restart multiple processes
    
    Restarting of multiple processes expects all restarting tasks to call
    sys_restart(). Once inside the system call, each task will restart
    itself at the same order that they were saved. The internals of the
    syscall will take care of in-kernel synchronization bewteen tasks.
    
    This patch does _not_ create the task tree in the kernel. Instead it
    assumes that all tasks are created in some way and then invoke the
    restart syscall. You can use the userspace mktree.c program to do
    that.
    
    There is one special task - the coordinator - that is not part of the
    restarted hierarchy. The coordinator task allocates the restart
    context (ctx) and orchestrates the restart. Thus even if a restart
    fails after, or during the restore of the root task, the user
    perceives a clean exit and an error message.
    
    The coordinator task will:
     1) read header and tree, create @ctx (wake up restarting tasks)
     2) set the ->checkpoint_ctx field of itself and all descendants
     3) wait for all restarting tasks to reach sync point #1
     4) activate first restarting task (root task)
     5) wait for all other tasks to complete and reach sync point #3
     6) wake up everybody
    
    (Note that in step #2 the coordinator assumes that the entire task
    hierarchy exists by the time it enters sys_restart; this is arranged
    in user space by 'mktree')
    
    Task that are restarting has three sync points:
     1) wait for its ->checkpoint_ctx to be set (by the coordinator)
     2) wait for the task's turn to restore (be active)
     [...now the task restores its state...]
     3) wait for all other tasks to complete
    
    The third sync point ensures that a task may only resume execution
    after all tasks have successfully restored their state (or fail if an
    error has occured). This prevents tasks from returning to user space
    prematurely, before the entire restart completes.
    
    If a single task wishes to restart, it can set the "RESTART_TASKSELF"
    flag to restart(2) to skip the logic of the coordinator.
    
    The root-task is a child of the coordinator, identified by the @pid
    given to sys_restart() in the pid-ns of the coordinator. Restarting
    tasks that aren't the coordinator, should set the @pid argument of
    restart(2) syscall to zero.
    
    All tasks explicitly test for an error flag on the checkpoint context
    when they wakeup from sync points.  If an error occurs during the
    restart of some task, it will mark the @ctx with an error flag, and
    wakeup the other tasks.
    
    An array of pids (the one saved during the checkpoint) is used to
    synchronize the operation. The first task in the array is the init
    task (*). The restart context (@ctx) maintains a "current position" in
    the array, which indicates which task is currently active. Once the
    currently active task completes its own restart, it increments that
    position and wakes up the next task.
    
    Restart assumes that userspace provides meaningful data, otherwise
    it's garbage-in-garbage-out. In this case, the syscall may block
    indefinitely, but in TASK_INTERRUPTIBLE, so the user can ctrl-c or
    otherwise kill the stray restarting tasks.
    
    In terms of security, restart runs as the user the invokes it, so it
    will not allow a user to do more than is otherwise permitted by the
    usual system semantics and policy.
    
    Currently we ignore threads and zombies, as well as session ids.
    Add support for multiple processes
    
    (*) For containers, restart should be called inside a fresh container
    by the init task of that container. However, it is also possible to
    restart applications not necessarily inside a container, and without
    restoring the original pids of the processes (that is, provided that
    the application can tolerate such behavior). This is useful to allow
    multi-process restart of tasks not isolated inside a container, and
    also for debugging.
    
    Changelog[v17]:
      - Add uflag RESTART_FROZEN to freeze tasks after restart
      - Fix restore_retval() and use only for restarting tasks
      - Coordinator converts -ERSTART... to -EINTR
      - Coordinator marks and sets descendants' ->checkpoint_ctx
      - Coordinator properly detects errors when woken up from wait
      - Fix race where root_task could kick start too early
      - Add a sync point for restarting tasks
      - Multiple fixes to restart logic
    Changelog[v14]:
      - Revert change to pr_debug(), back to ckpt_debug()
      - Discard field 'h.parent'
      - Check whether calls to ckpt_hbuf_get() fail
    Changelog[v13]:
      - Clear root_task->checkpoint_ctx regardless of error condition
      - Remove unused argument 'ctx' from do_restore_task() prototype
      - Remove unused member 'pids_err' from 'struct ckpt_ctx'
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 1123b4105fe5bd8c29c93ea9f31ef43dc6d90e1d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:45:35 2009 -0400

    c/r: checkpoint multiple processes
    
    Checkpointing of multiple processes works by recording the tasks tree
    structure below a given "root" task. The root task is expected to be a
    container init, and then an entire container is checkpointed. However,
    passing CHECKPOINT_SUBTREE to checkpoint(2) relaxes this requirement
    and allows to checkpoint a subtree of processes from the root task.
    
    For a given root task, do a DFS scan of the tasks tree and collect them
    into an array (keeping a reference to each task). Using DFS simplifies
    the recreation of tasks either in user space or kernel space. For each
    task collected, test if it can be checkpointed, and save its pid, tgid,
    and ppid.
    
    The actual work is divided into two passes: a first scan counts the
    tasks, then memory is allocated and a second scan fills the array.
    
    Whether checkpoints and restarts require CAP_SYS_ADMIN is determined
    by sysctl 'ckpt_unpriv_allowed': if 1, then regular permission checks
    are intended to prevent privilege escalation, however if 0 it prevents
    unprivileged users from exploiting any privilege escalation bugs.
    
    The logic is suitable for creation of processes during restart either
    in userspace or by the kernel.
    
    Currently we ignore threads and zombies.
    
    Changelog[v16]:
      - CHECKPOINT_SUBTREE flags allows subtree (not whole container)
      - sysctl variable 'ckpt_unpriv_allowed' controls needed privileges
    Changelog[v14]:
      - Refuse non-self checkpoint if target task isn't frozen
      - Refuse checkpoint (for now) if task is ptraced
      - Revert change to pr_debug(), back to ckpt_debug()
      - Use only unsigned fields in checkpoint headers
      - Check retval of ckpt_tree_count_tasks() in ckpt_build_tree()
      - Discard 'h.parent' field
      - Check whether calls to ckpt_hbuf_get() fail
      - Disallow threads or siblings to container init
    Changelog[v13]:
      - Release tasklist_lock in error path in ckpt_tree_count_tasks()
      - Use separate index for 'tasks_arr' and 'hh' in ckpt_write_pids()
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit aa57087333333f0dea9ec5b08c7312d922050174
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:45:28 2009 -0400

    c/r: restart-blocks
    
    (Paraphrasing what's said this message:
    http://lists.openwall.net/linux-kernel/2007/12/05/64)
    
    Restart blocks are callbacks used cause a system call to be restarted
    with the arguments specified in the system call restart block. It is
    useful for system call that are not idempotent, i.e. the argument(s)
    might be a relative timeout, where some adjustments are required when
    restarting the system call. It relies on the system call itself to set
    up its restart point and the argument save area.  They are rare: an
    actual signal would turn that it an EINTR. The only case that should
    ever trigger this is some kernel action that interrupts the system
    call, but does not actually result in any user-visible state changes -
    like freeze and thaw.
    
    So restart blocks are about time remaining for the system call to
    sleep/wait. Generally in c/r, there are two possible time models that
    we can follow: absolute, relative. Here, I chose to save the relative
    timeout, measured from the beginning of the checkpoint. The time when
    the checkpoint (and restart) begin is also saved. This information is
    sufficient to restart in either model (absolute or negative).
    
    Which model to use should eventually be a per application choice (and
    possible configurable via cradvise() or some sort). For now, we adopt
    the relative model, namely, at restart the timeout is set relative to
    the beginning of the restart.
    
    To checkpoint, we check if a task has a valid restart block, and if so
    we save the *remaining* time that is has to wait/sleep, and the type
    of the restart block.
    
    To restart, we fill in the data required at the proper place in the
    thread information. If the system call return an error (which is
    possibly an -ERESTARTSYS eg), we not only use that error as our own
    return value, but also arrange for the task to execute the signal
    handler (by faking a signal). The handler, in turn, already has the
    code to handle these restart request gracefully.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a76235f381ee4ce422b00b746aa5fd5e259ce4ff
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:44:37 2009 -0400

    c/r: export functionality used in next patch for restart-blocks
    
    To support c/r of restart-blocks (system call that need to be
    restarted because they were interrupted but there was no userspace
    visible side-effect), export restart-block callbacks for poll()
    and futex() syscalls.
    
    More details on c/r of restart-blocks and how it works in the
    following patch.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 521f272dfa3a46d56f32403b35f5d3aaa7309410
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:44:16 2009 -0400

    c/r: external checkpoint of a task other than ourself
    
    Now we can do "external" checkpoint, i.e. act on another task.
    
    sys_checkpoint() now looks up the target pid (in our namespace) and
    checkpoints that corresponding task. That task should be the root of
    a container, unless CHECKPOINT_SUBTREE flag is given.
    
    Set state of freezer cgroup of checkpointed task hierarchy to
    "CHECKPOINTING" during a checkpoint, to ensure that task(s) cannot be
    thawed while at it.
    
    Ensure that all tasks belong to root task's freezer cgroup (the root
    task is also tested, to detect it if changes its freezer cgroups
    before it moves to "CHECKPOINTING").
    
    sys_restart() remains nearly the same, as the restart is always done
    in the context of the restarting task. However, the original task may
    have been frozen from user space, or interrupted from a syscall for
    the checkpoint. This is accounted for by restoring a suitable retval
    for the restarting task, according to how it was checkpointed.
    
    Changelog[v17]:
      - Move restore_retval() to this patch
      - Tighten ptrace ceckpoint for checkpoint to PTRACE_MODE_ATTACH
      - Use CHECKPOINTING state for hierarchy's freezer for checkpoint
    Changelog[v16]:
      - Use CHECKPOINT_SUBTREE to allow subtree (partial container)
    Changelog[v14]:
      - Refuse non-self checkpoint if target task isn't frozen
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v11]:
      - Copy contents of 'init->fs->root' instead of pointing to them
    Changelog[v10]:
      - Grab vfs root of container init, rather than current process
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 29ca904cf0c01960ae30e37ab181d3e6ae40bf46
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:37:43 2009 -0400

    c/r: x86_32 support for checkpoint/restart
    
    Add logic to save and restore architecture specific state, including
    thread-specific state, CPU registers and FPU state.
    
    In addition, architecture capabilities are saved in an architecure
    specific extension of the header (ckpt_hdr_head_arch); Currently this
    includes only FPU capabilities.
    
    Currently only x86-32 is supported.
    
    Changelog[v17]:
      - Fix compilation for architectures that don't support checkpoint
      - Validate cpu registers and TLS descriptors on restart
      - Validate debug registers on restart
      - Export asm/checkpoint_hdr.h to userspace
    Changelog[v16]:
      - All objects are preceded by ckpt_hdr (TLS and xstate_buf)
      - Add architecture identifier to main header
    Changelog[v14]:
      - Use new interface ckpt_hdr_get/put()
      - Embed struct ckpt_hdr in struct ckpt_hdr...
      - Remove preempt_disable/enable() around init_fpu() and fix leak
      - Revert change to pr_debug(), back to ckpt_debug()
      - Move code related to task_struct to checkpoint/process.c
    Changelog[v12]:
      - A couple of missed calls to ckpt_hbuf_put()
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v9]:
      - Add arch-specific header that details architecture capabilities;
        split FPU restore to send capabilities only once.
      - Test for zero TLS entries in ckpt_write_thread()
      - Fix asm/checkpoint_hdr.h so it can be included from user-space
    Changelog[v7]:
      - Fix save/restore state of FPU
    Changelog[v5]:
      - Remove preempt_disable() when restoring debug registers
    Changelog[v4]:
      - Fix header structure alignment
    Changelog[v2]:
      - Pad header structures to 64 bits to ensure compatibility
      - Follow Dave Hansen's refactoring of the original post
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit fd25315ce9d1cbe2957b66b60d4323e079d5e942
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:37:39 2009 -0400

    c/r: basic infrastructure for checkpoint/restart
    
    Add those interfaces, as well as helpers needed to easily manage the
    file format. The code is roughly broken out as follows:
    
    checkpoint/sys.c - user/kernel data transfer, as well as setup of the
      c/r context (a per-checkpoint data structure for housekeeping)
    
    checkpoint/checkpoint.c - output wrappers and basic checkpoint handling
    
    checkpoint/restart.c - input wrappers and basic restart handling
    
    checkpoint/process.c - c/r of task data
    
    For now, we can only checkpoint the 'current' task ("self" checkpoint),
    and the 'pid' argument to the syscall is ignored.
    
    Patches to add the per-architecture support as well as the actual
    work to do the memory checkpoint follow in subsequent patches.
    
    Changelog[v17]:
      - Fix compilation for architectures that don't support checkpoint
      - Save/restore t->{set,clear}_child_tid
      - Restart(2) isn't idempotent: must return -EINTR if interrupted
      - ckpt_debug does not depend on DYNAMIC_DEBUG, on by default
      - Export generic checkpoint headers to userespace
      - Fix comment for prototype of sys_restart
      - Have ckpt_debug() print global-pid and __LINE__
      - Only save and test kernel constants once (in header)
    Changelog[v16]:
      - Split ctx->flags to ->uflags (user flags) and ->kflags (kernel flags)
      - Introduce __ckpt_write_err() and ckpt_write_err() to report errors
      - Allow @ptr == NULL to write (or read) header only without payload
      - Introduce _ckpt_read_obj_type()
    Changelog[v15]:
      - Replace header buffer in ckpt_ctx (hbuf,hpos) with kmalloc/kfree()
    Changelog[v14]:
      - Cleanup interface to get/put hdr buffers
      - Merge checkpoint and restart code into a single file (per subsystem)
      - Take uts_sem around access to uts->{release,version,machine}
      - Embed ckpt_hdr in all ckpt_hdr_...., cleanup read/write helpers
      - Define sys_checkpoint(0,...) as asking for a self-checkpoint (Serge)
      - Revert use of 'pr_fmt' to avoid tainting whom includes us (Nathan Lynch)
      - Explicitly indicate length of UTS fields in header
      - Discard field 'h->parent' from ckpt_hdr
    Changelog[v12]:
      - ckpt_kwrite/ckpt_kread() again use vfs_read(), vfs_write() (safer)
      - Split ckpt_write/ckpt_read() to two parts: _ckpt_write/read() helper
      - Befriend with sparse : explicit conversion to 'void __user *'
      - Redfine 'pr_fmt' instead of using special ckpt_debug()
    Changelog[v10]:
      - add ckpt_write_buffer(), ckpt_read_buffer() and ckpt_read_buf_type()
      - force end-of-string in ckpt_read_string() (fix possible DoS)
    Changelog[v9]:
      - ckpt_kwrite/ckpt_kread() use file->f_op->write() directly
      - Drop ckpt_uwrite/ckpt_uread() since they aren't used anywhere
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
        (although it's not really needed)
    Changelog[v5]:
      - Rename headers files s/ckpt/checkpoint/
    Changelog[v2]:
      - Added utsname->{release,version,machine} to checkpoint header
      - Pad header structures to 64 bits to ensure compatibility
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 672fa8ad9ed86a9faea572b7de9f2c9cb4f4cadf
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:21:55 2009 -0400

    c/r: documentation
    
    Covers application checkpoint/restart, overall design, interfaces,
    usage, shared objects, and and checkpoint image format.
    
    Changelog[v16]:
      - Update documentation
      - Unify into readme.txt and usage.txt
    Changelog[v14]:
      - Discard the 'h.parent' field
      - New image format (shared objects appear before they are referenced
        unless they are compound)
    Changelog[v8]:
      - Split into multiple files in Documentation/checkpoint/...
      - Extend documentation, fix typos and comments from feedback
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit 0a5b0caac4574e0d1a399e6722a26e068c14bc17
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:21:55 2009 -0400

    c/r: create syscalls: sys_checkpoint, sys_restart
    
    Create trivial sys_checkpoint and sys_restore system calls. They will
    enable to checkpoint and restart an entire container, to and from a
    checkpoint image file descriptor.
    
    The syscalls take a pid, a file descriptor (for the image file) and
    flags as arguments. The pid identifies the top-most (root) task in the
    process tree, e.g. the container init: for sys_checkpoint the first
    argument identifies the pid of the target container/subtree; for
    sys_restart it will identify the pid of restarting root task.
    
    A checkpoint, much like a process coredump, dumps the state of multiple
    processes at once, including the state of the container. The checkpoint
    image is written to (and read from) the file descriptor directly from
    the kernel. This way the data is generated and then pushed out naturally
    as resources and tasks are scanned to save their state. This is the
    approach taken by, e.g., Zap and OpenVZ.
    
    By using a return value and not a file descriptor, we can distinguish
    between a return from checkpoint, a return from restart (in case of a
    checkpoint that includes self, i.e. a task checkpointing its own
    container, or itself), and an error condition, in a manner analogous
    to a fork() call.
    
    We don't use copy_from_user()/copy_to_user() because it requires
    holding the entire image in user space, and does not make sense for
    restart.  Also, we don't use a pipe, pseudo-fs file and the like,
    because they work by generating data on demand as the user pulls it
    (unless the entire image is buffered in the kernel) and would require
    more complex logic.  They also would significantly complicate
    checkpoint that includes self.
    
    Changelog[v17]:
      - Move checkpoint closer to namespaces (kconfig)
      - Kill "Enable" in c/r config option
    Changelog[v16]:
      - Change sys_restart() first argument to be 'pid_t pid'
    Changelog[v14]:
      - Change CONFIG_CHEKCPOINT_RESTART to CONFIG_CHECKPOINT (Ingo)
      - Remove line 'def_bool n' (default is already 'n')
      - Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)
    Changelog[v5]:
      - Config is 'def_bool n' by default
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit c2ceb7f7fe66b1285e7954c0acde5809239385d1
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:54 2009 -0400

    pids 7/7: Define clone_with_pids syscall
    
    Container restart requires that a task have the same pid it had when it was
    checkpointed. When containers are nested the tasks within the containers
    exist in multiple pid namespaces and hence have multiple pids to specify
    during restart.
    
    clone_with_pids(), intended for use during restart, is the same as clone(),
    except that it takes a 'target_pid_set' paramter. This parameter lets caller
    choose specific pid numbers for the child process, in the process's active
    and ancestor pid namespaces. (Descendant pid namespaces in general don't
    matter since processes don't have pids in them anyway, but see comments
    in copy_target_pids() regarding CLONE_NEWPID).
    
    Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for now, to
    prevent unprivileged processes from misusing this interface.
    
    Call clone_with_pids as follows:
    
    	pid_t pids[] = { 0, 77, 99 };
    	struct target_pid_set pid_set;
    
    	pid_set.num_pids = sizeof(pids) / sizeof(int);
    	pid_set.target_pids = &pids;
    
    	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);
    
    If a target-pid is 0, the kernel continues to assign a pid for the process in
    that namespace. In the above example, pids[0] is 0, meaning the kernel will
    assign next available pid to the process in init_pid_ns. But kernel will assign
    pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If either
    77 or 99 are taken, the system call fails with -EBUSY.
    
    If 'pid_set.num_pids' exceeds the current nesting level of pid namespaces,
    the system call fails with -EINVAL.
    
    Its mostly an exploratory patch seeking feedback on the interface.
    
    NOTE:
    	Compared to clone(), clone_with_pids() needs to pass in two more
    	pieces of information:
    
    		- number of pids in the set
    		- user buffer containing the list of pids.
    
    	But since clone() already takes 5 parameters, use a 'struct
    	target_pid_set'.
    
    TODO:
    	- Gently tested.
    	- May need additional sanity checks in do_fork_with_pids().
    
    Changelog[v3]:
    	- (Oren Laadan) Allow CLONE_NEWPID flag (by allocating an extra pid
    	  in the target_pids[] list and setting it 0. See copy_target_pids()).
    	- (Oren Laadan) Specified target pids should apply only to youngest
    	  pid-namespaces (see copy_target_pids())
    	- (Matt Helsley) Update patch description.
    
    Changelog[v2]:
    	- Remove unnecessary printk and add a note to callers of
    	  copy_target_pids() to free target_pids.
    	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
    	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
    	  'num_pids == 0' (fall back to normal clone()).
    	- Move arch-independent code (sanity checks and copy-in of target-pids)
    	  into kernel/fork.c and simplify sys_clone_with_pids()
    
    Changelog[v1]:
    	- Fixed some compile errors (had fixed these errors earlier in my
    	  git tree but had not refreshed patches before emailing them)
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit 17ea3ea9c73b1f85b1119563cdfd6a3bd1012ffa
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:54 2009 -0400

    pids 6/7: Define do_fork_with_pids()
    
    do_fork_with_pids() is same as do_fork(), except that it takes an
    additional, 'pid_set', parameter. This parameter, currently unused,
    specifies the set of target pids of the process in each of its pid
    namespaces.
    
    Changelog[v3]:
    	- Fix "long-line" warning from checkpatch.pl
    
    Changelog[v2]:
    	- To facilitate moving architecture-inpdendent code to kernel/fork.c
    	  pass in 'struct target_pid_set __user *' to do_fork_with_pids()
    	  rather than 'pid_t *' (next patch moves the arch-independent
    	  code to kernel/fork.c)
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 9259ece4e673844149d6d08803c66abdeefa8243
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:54 2009 -0400

    pids 5/7: Add target_pids parameter to copy_process()
    
    The new parameter will be used in a follow-on patch when clone_with_pids()
    is implemented.
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 7ffa84de27c8e51974dc65d50788f009910d440e
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:53 2009 -0400

    pids 4/7: Add target_pids parameter to alloc_pid()
    
    This parameter is currently NULL, but will be used in a follow-on patch.
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 01d990434c6b77be5ca6a38071167f0fa5217ed0
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:53 2009 -0400

    pids 3/7: Add target_pid parameter to alloc_pidmap()
    
    With support for setting a specific pid number for a process,
    alloc_pidmap() will need a paramter a 'target_pid' parameter.
    
    Changelog[v2]:
    	- (Serge Hallyn) Check for 'pid < 0' in set_pidmap().(Code
    	  actually checks for 'pid <= 0' for completeness).
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit db5d3b14baeb5122abb7b60db5fa6e6c3d7eccf9
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:53 2009 -0400

    pids 2/7: Have alloc_pidmap() return actual error code
    
    alloc_pidmap() can fail either because all pid numbers are in use or
    because memory allocation failed.  With support for setting a specific
    pid number, alloc_pidmap() would also fail if either the given pid
    number is invalid or in use.
    
    Rather than have callers assume -ENOMEM, have alloc_pidmap() return
    the actual error.
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a903c365952e582aee4da1fe827168afccf17eaf
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:52 2009 -0400

    pids 1/7: Factor out code to allocate pidmap page
    
    To implement support for clone_with_pids() system call we would
    need to allocate pidmap page in more than one place. Move this
    code to a new function alloc_pidmap_page().
    
    Changelog[v2]:
    	- (Matt Helsley, Dave Hansen) Have alloc_pidmap_page() return
    	  -ENOMEM on error instead of -1.
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 588dced6f5300597456015fe6a72b704e26428b9
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:21:51 2009 -0400

    c/r: make file_pos_read/write() public
    
    These two are used in the next patch when calling vfs_read/write()
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 76ae59a36e3bda55b8a833e52d566ed5fe1be44d
Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 14 16:21:50 2009 -0400

    Namespaces submenu
    
    Let's not steal too much space in the 'General Setup' menu.
    Take a cue from the cgroups code and create a submenu.
    
    This can go upstream now.
    
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit b1c27a8cf51088f0005c20b7e666ca614d2f59d2
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 14 16:21:46 2009 -0400

    cgroup freezer: interface to freeze a cgroup from within the kernel
    
    Add public interface to freeze a cgroup freezer given a task that
    belongs to that cgroup:  cgroup_freezer_make_frozen(task)
    
    Freezing the root cgroup is not permitted. Freezing the cgroup to
    which current process belong is also not permitted.
    
    This will be used for restart(2) to be able to leave the restarted
    processes in a frozen state, instead of resuming execution.
    
    This is useful for debugging, if the user would like to attach a
    debugger to the restarted task(s).
    
    It is also useful if the restart procedure would like to perform
    additional setup once the tasks are restored but before they are
    allowed to proceed execution.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    CC: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

commit b39db090fdac3e0cbebac6fee952ad0a3c1d079d
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 14 15:04:51 2009 -0400

    cgroup freezer: Add CHECKPOINTING state to safeguard container checkpoint
    
    The CHECKPOINTING state prevents userspace from unfreezing tasks until
    sys_checkpoint() is finished. When doing container checkpoint userspace
    will do:
    
    	echo FROZEN > /cgroups/my_container/freezer.state
    	...
    	rc = sys_checkpoint( <pid of container root> );
    
    To ensure a consistent checkpoint image userspace should not be allowed
    to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
    during checkpoint.
    
    "CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkpoint
    system call. Once in the "CHECKPOINTING" state, the cgroup may not leave until
    the checkpoint system call is finished and ready to return. Then the
    freezer state returns to "FROZEN". Writing any new state to freezer.state while
    checkpointing will return EBUSY. These semantics ensure that userspace cannot
    unfreeze the cgroup midway through the checkpoint system call.
    
    The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoint()
    make relatively few assumptions about the task that is passed in. However the
    way they are called in do_checkpoint() assumes that the root of the container
    is in the same freezer cgroup as all the other tasks that will be
    checkpointed.
    
    Notes:
            As a side-effect this prevents the multiple tasks from entering the
            CHECKPOINTING state simultaneously. All but one will get -EBUSY.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
