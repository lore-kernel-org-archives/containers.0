From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17,
	created. v2.6.27-rc5-46164-gcb4f8e4
Date: Wed, 22 Jul 2009 05:58:19 -0400
Message-ID: <200907220958.n6M9wJnK022052@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8541072686126819718=="
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

--===============8541072686126819718==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n6M9w7AQ001501

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v17 has been created
        at  cb4f8e444888f12d994fb914adb23d3742fd6cb1 (commit)

- Log -----------------------------------------------------------------
commit cb4f8e444888f12d994fb914adb23d3742fd6cb1
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jul 22 00:44:03 2009 -0400

    c/r: checkpoint and restore (shared) task's sighand_struct
   =20
    This patch adds the checkpointing and restart of signal handling
    state - 'struct sighand_struct'. Since the contents of this state
    only affect userspace, no input validation is required.
   =20
    Add _NSIG to kernel constants saved/tested with image header.
   =20
    Number of signals (_NSIG) is arch-dependent, but is within __KERNEL__
    and not visibile to userspace compile. Therefore, define per arch
    CKPT_ARCH_NSIG in <asm/checkpoint_hdr.h>.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 0a3495391ddfa5167441a02e462404dad155610f
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 22 00:43:54 2009 -0400

    c/r: restore file->f_cred
   =20
    Restore a file's f_cred.  This is set to the cred of the task doing
    the open, so often it will be the same as that of the restarted task.
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit d1c1d8bab0d23e1cc920eac0df1535b07b613a26
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 22 00:43:22 2009 -0400

    c/r: checkpoint and restore task credentials
   =20
    This patch adds the checkpointing and restart of credentials
    (uids, gids, and capabilities) to Oren's c/r patchset (on top
    of v14).  It goes to great pains to re-use (and define when
    needed) common helpers, in order to make sure that as security
    code is modified, the cr code will be updated.  Some of the
    helpers should still be moved (i.e. _creds() functions should
    be in kernel/cred.c).
   =20
    When building the credentials for the restarted process, I
    1. create a new struct cred as a copy of the running task's
    cred (using prepare_cred())
    2. always authorize any changes to the new struct cred
    based on the permissions of current_cred() (not the current
    transient state of the new cred).
   =20
    While this may mean that certain transient_cred1->transient_cred2
    states are allowed which otherwise wouldn't be allowed, the
    fact remains that current_cred() is allowed to transition to
    transient_cred2.
   =20
    The reconstructed creds are applied to the task at the very
    end of the sys_restart call.  This ensures that any objects which
    need to be re-created (file, socket, etc) are re-created using
    the creds of the task calling sys_restart - preventing an unpriv
    user from creating a privileged object, and ensuring that a
    root task can restart a process which had started out privileged,
    created some privileged objects, then dropped its privilege.
   =20
    With these patches, the root user can restart checkpoint images
    (created by either hallyn or root) of user hallyn's tasks,
    resulting in a program owned by hallyn.
   =20
    Changelog:
    	Jun 15: Fix user_ns handling when !CONFIG_USER_N
    	        Set creator_ref=3D0 for root_ns (discard @flags)
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
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: merge with ckpt-v16-dev]

commit 19d51ab85fc19b2428fa57ead74a33059e6bbebe
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 21:58:04 2009 -0400

    c/r: capabilities: define checkpoint and restore fns
   =20
    [ Andrew: I am punting on dealing with the subsystem cooperation
    issues in this version, in favor of trying to get LSM issues
    straightened out ]
   =20
    An application checkpoint image will store capability sets
    (and the bounding set) as __u64s.  Define checkpoint and
    restart functions to translate between those and kernel_cap_t's.
   =20
    Define a common function do_capset_tocred() which applies capability
    set changes to a passed-in struct cred.
   =20
    The restore function uses do_capset_tocred() to apply the restored
    capabilities to the struct cred being crafted, subject to the
    current task's (task executing sys_restart()) permissions.
   =20
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
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit e248742ebc0308bafd6a57a437cb4becd69531c5
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 21:58:03 2009 -0400

    c/r: clone_with_pids: define the s390 syscall
   =20
    Hook up the clone_with_pids system call for s390x.  clone_with_pids()
    takes an additional argument over clone(), which we pass in through
    register 7.  Stub code for using the syscall looks like:
   =20
    struct target_pid_set {
            int num_pids;
            pid_t *target_pids;
            unsigned long flags;
    };
   =20
        register unsigned long int __r2 asm ("2") =3D (unsigned long int)=
(stack);
        register unsigned long int __r3 asm ("3") =3D (unsigned long int)=
(flags);
        register unsigned long int __r4 asm ("4") =3D (unsigned long int)=
(NULL);
        register unsigned long int __r5 asm ("5") =3D (unsigned long int)=
(NULL);
        register unsigned long int __r6 asm ("6") =3D (unsigned long int)=
(NULL);
        register unsigned long int __r7 asm ("7") =3D (unsigned long int)=
(setp);
        register unsigned long int __result asm ("2");
        __asm__ __volatile__(
                " lghi %%r1,332\n"
                " svc 0\n"
                : "=3Dd" (__result)
                : "0" (__r2), "d" (__r3),
                  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7)
                : "1", "cc", "memory"
        );
                __result;
        })
   =20
        struct target_pid_set pid_set;
        int pids[1] =3D { 19799 };
        pid_set.num_pids =3D 1;
        pid_set.target_pids =3D &pids[0];
        pid_set.flags =3D 0;
   =20
        rc =3D do_clone_with_pids(topstack, clone_flags, setp);
        if (rc =3D=3D 0)
    	printf("Child\n");
        else if (rc > 0)
    	printf("Parent: child pid %d\n", rc);
        else
    	printf("Error %d\n", rc);
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 3c7bbff64db2840848d273365dcdeec2c2b17afe
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 21:58:03 2009 -0400

    c/r: define s390-specific checkpoint-restart code
   =20
    Implement the s390 arch-specific checkpoint/restart helpers.  This
    is on top of Oren Laadan's c/r code.
   =20
    With these, I am able to checkpoint and restart simple programs as pe=
r
    Oren's patch intro.  While on x86 I never had to freeze a single task
    to checkpoint it, on s390 I do need to.  That is a prereq for consist=
ent
    snapshots (esp with multiple processes) anyway so I don't see that as
    a problem.
   =20
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
                . Fixed up save and restore of PSW, with the non-address =
bits
                  properly masked out
        Feb 25:
                . Make checkpoint_hdr.h safe for inclusion in userspace
                . Replace comment about vsdo code
                . Add comment about restoring access registers
                . Write and read an empty ckpt_hdr_head_arch record to ap=
pease
                  code (mktree) that expects it to be there
                . Utilize NUM_CKPT_WORDS in checkpoint_hdr.h
        Feb 24:
                . Use CKPT_COPY() to unify the un/loading of cpu and mm s=
tate
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
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 30d9f0c70c6f5e4d62de857dc8e25ff074570146
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 21:58:03 2009 -0400

    c/r: add CKPT_COPY() macro
   =20
    As suggested by Dave[1], this provides us a way to make the copy-in a=
nd
    copy-out processes symmetric.  CKPT_COPY_ARRAY() provides us a way to=
 do
    the same thing but for arrays.  It's not critical, but it helps us un=
ify
    the checkpoint and restart paths for some things.
   =20
    Changelog:
        Mar 04:
                . Removed semicolons
                . Added build-time check for __must_be_array in CKPT_COPY=
_ARRAY
        Feb 27:
                . Changed CKPT_COPY() to use assignment, eliminating the =
need
                  for the CKPT_COPY_BIT() macro
                . Add CKPT_COPY_ARRAY() macro to help copying register ar=
rays,
                  etc
                . Move the macro definitions inside the CR #ifdef
        Feb 25:
                . Changed WARN_ON() to BUILD_BUG_ON()
   =20
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
   =20
    1: https://lists.linux-foundation.org/pipermail/containers/2009-Febru=
ary/015821.html (all the way at the bottom)

commit dff5f938429342dd29a042f09734979a2069a903
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 21:58:02 2009 -0400

    c/r: (s390): expose a constant for the number of words (CRs)
   =20
    We need to use this value in the checkpoint/restart code and would li=
ke to
    have a constant instead of a magic '3'.
   =20
    Changelog:
        Mar 30:
                . Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)
        Mar 03:
                . Picked up additional use of magic '3' in ptrace.h
   =20
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 15f0c9abb9d92578e5d1fa53f288943fef231c44
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 21:58:02 2009 -0400

    c/r: support semaphore sysv-ipc
   =20
    Checkpoint of sysvipc semaphores is performed by iterating through al=
l
    sem objects and dumping the contents of each one. The semaphore array
    of each sem is dumped with that object.
   =20
    The semaphore array (sem->sem_base) holds an array of 'struct sem',
    which is a {int, int}. Because this translates into the same format
    on 32- and 64-bit architectures, the checkpoint format is simply the
    dump of this array as is.
   =20
    TODO: this patch does not handle semaphore-undo -- this data should b=
e
    saved per-task while iterating through the tasks.
   =20
    Changelog[v17]:
      - Restore objects in the right namespace
      - Forward declare struct msg_msg (instead of include linux/msg.h)
      - Fix typo in comment
      - Don't unlock ipc before calling freeary in error path
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit f94775bf4f68db06fed951d5516ff8d7347dba5e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 21:57:58 2009 -0400

    c/r: support message-queues sysv-ipc
   =20
    Checkpoint of sysvipc message-queues is performed by iterating throug=
h
    all 'msq' objects and dumping the contents of each one. The message
    queued on each 'msq' are dumped with that object.
   =20
    Message of a specific queue get written one by one. The queue lock
    cannot be held while dumping them, but the loop must be protected fro=
m
    someone (who ?) writing or reading. To do that we grab the lock, then
    hijack the entire chain of messages from the queue, drop the lock,
    and then safely dump them in a loop. Finally, with the lock held, we
    re-attach the chain while verifying that there isn't other (new) data
    on that queue.
   =20
    Writing the message contents themselves is straight forward. The code
    is similar to that in ipc/msgutil.c, the main difference being that
    we deal with kernel memory and not user memory.
   =20
    Changelog[v17]:
      - Allocate security context for msg_msg
      - Restore objects in the right namespace
      - Don't unlock ipc before freeing
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 3b5d97581427cc8b57a6b32b591277d656fa765e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    c/r: support share-memory sysv-ipc
   =20
    Checkpoint of sysvipc shared memory is performed in two steps: first,
    the entire ipc namespace is dumped as a whole by iterating through al=
l
    shm objects and dumping the contents of each one. The shmem inode is
    registered in the objhash. Second, for each vma that refers to ipc
    shared memory we find the inode in the objhash, and save the objref.
   =20
    (If we find a new inode, that indicates that the ipc namespace is not
    entirely frozen and someone must have manipulated it since step 1).
   =20
    Handling of shm objects that have been deleted (via IPC_RMID) is left
    to a later patch in this series.
   =20
    Changelog[v17]:
      - Restore objects in the right namespace
      - Properly initialize ctx->deferqueue
      - Fix compilation with CONFIG_CHECKPOINT=3Dn
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a5df69850fb92e6fb542ac21850fe0d52d1bc3b5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    c/r: save and restore sysvipc namespace basics
   =20
    Add the helpers to checkpoint and restore the contents of 'struct
    kern_ipc_perm'. Add header structures for ipc state. Put place-holder=
s
    to save and restore ipc state.
   =20
    Save and restores the common state (parameters) of ipc namespace.
   =20
    Generic code to iterate through the objects of sysvipc shared memory,
    message queues and semaphores. The logic to save and restore the stat=
e
    of these objects will be added in the next few patches.
   =20
    Right now, we return -EPERM if the user calling sys_restart() isn't
    allowed to create an object with the checkpointed uid.  We may prefer
    to simply use the caller's uid in that case - but that could lead to
    subtle userspace bugs?  Unsure, so going for the stricter behavior.
   =20
    TODO: restore kern_ipc_perms->security.
   =20
    Changelog[v17]:
      - Fix include: use checkpoint.h not checkpoint_hdr.h
      - Collect nsproxy->ipc_ns
      - Restore objects in the right namespace
      - If !CONFIG_IPC_NS only restore objects, not global settings
      - Don't overwrite global ipc-ns if !CONFIG_IPC_NS
      - Reset the checkpointed uid and gid info on ipc objects
      - Fix compilation with CONFIG_SYSVIPC=3Dn
    Changelog [Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>]
      - Fix compilation with CONFIG_SYSVIPC=3Dn
      - Update to match UTS changes
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 5c90b930f89eae72bdc2772a7f704c07c6eda5e7
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    c/r (ipc): allow allocation of a desired ipc identifier
   =20
    During restart, we need to allocate ipc objects that with the same
    identifiers as recorded during checkpoint. Modify the allocation
    code allow an in-kernel caller to request a specific ipc identifier.
    The system call interface remains unchanged.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e1cee4c2f7044ebc411d511233b2becfab873313
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    deferqueue: generic queue to defer work
   =20
    Add a interface to postpone an action until the end of the entire
    checkpoint or restart operation. This is useful when during the
    scan of tasks an operation cannot be performed in place, to avoid
    the need for a second scan.
   =20
    One use case is when restoring an ipc shared memory region that has
    been deleted (but is still attached), during restart it needs to be
    create, attached and then deleted. However, creation and attachment
    are performed in distinct locations, so deletion can not be performed
    on the spot. Instead, this work (delete) is deferred until later.
    (This example is in one of the following patches).
   =20
    This interface allows chronic procrastination in the kernel:
   =20
    deferqueue_create(void):
        Allocates and returns a new deferqueue.
   =20
    deferqueue_run(deferqueue):
        Executes all the pending works in the queue. Returns the number
        of works executed, or an error upon the first error reported by
        a deferred work.
   =20
    deferqueue_add(deferqueue, data, size, func, dtor):
        Enqueue a deferred work. @function is the callback function to
        do the work, which will be called with @data as an argument.
        @size tells the size of data. @dtor is a destructor callback
        that is invoked for deferred works remaining in the queue when
        the queue is destroyed. NOTE: for a given deferred work, @dtor
        is _not_ called if @func was already called (regardless of the
        return value of the latter).
   =20
    deferqueue_destroy(deferqueue):
        Free the deferqueue and any queued items while invoking the
        @dtor callback for each queued item.
   =20
    Why aren't we using the existing kernel workqueue mechanism?  We need
    to defer to work until the end of the operation: not earlier, since w=
e
    need other things to be in place; not later, to not block waiting for
    it. However, the workqueue schedules the work for 'some time later'.
    Also, the kernel workqueue may run in any task context, but we requir=
e
    many times that an operation be run in the context of some specific
    restarting task (e.g., restoring IPC state of a certain ipc_ns).
   =20
    Instead, this mechanism is a simple way for the c/r operation as a
    whole, and later a task in particular, to defer some action until
    later (but not arbitrarily later) _in the restore_ operation.
   =20
    Changelog[v17]
      - Fix deferqueue_add() function
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 6ccf81990d9920eb504a53e47deda93e6906da69
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    c/r: support for UTS namespace
   =20
    This patch adds a "phase" of checkpoint that saves out information ab=
out any
    namespaces the task(s) may have.  Do this by tracking the namespace o=
bjects
    of the tasks and making sure that tasks with the same namespace that =
follow
    get properly referenced in the checkpoint stream.
   =20
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
      - Add a note to Documentation/checkpoint/internals.txt to indicate =
where
        in the save/restore process the UTS information is kept
      - Store (and track) the objref of the namespace itself instead of t=
he
        nsproxy (based on comments from Dave on IRC)
      - Remove explicit check for non-root nsproxy
      - Store the nodename and domainname lengths and use ckpt_write_stri=
ng()
        to store the actual name strings
      - Catch failure of ckpt_obj_add_ptr() in ckpt_write_namespaces()
      - Remove "types" bitfield and use the "is this new" flag to determi=
ne
        whether or not we should write out a new ns descriptor
      - Replace kernel restore path
      - Move the namespace information to be directly after the task
        information record
      - Update Documentation to reflect new location of namespace info
      - Support checkpoint and restart of nested UTS namespaces
   =20
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 3ca3313b33b9baf98d8cd82ed1e4064b61e856f6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    c/r: make ckpt_may_checkpoint_task() check each namespace individuall=
y
   =20
    For a given namespace type, say XXX, if a checkpoint was taken on a
    CONFIG_XXX_NS system, is restarted on a !CONFIG_XXX_NS, then ensure
    that:
   =20
    1) The global settings of the global (init) namespace do not get
    overwritten. Creating new objects in that namespace is ok, as long as
    the request identifier is available.
   =20
    2) All restarting tasks use a single namespace - because it is
    impossible to create additional namespaces to accommodate for what ha=
d
    been checkpointed.
   =20
    Original patch introducing nsproxy c/r by Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org=
>
   =20
    Chagnelog[v17]:
      - Only collect sub-objects of struct_nsproxy once.
      - Restore namespace pieces directly instead of using sys_unshare()
      - Proper handling of restart from namespace(s) without namespace(s)
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 7d6a8ed63d154ce205db684a4bab833c094b09b2
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    c/r: support for open pipes
   =20
    A pipe is a double-headed inode with a buffer attached to it. We
    checkpoint the pipe buffer only once, as soon as we hit one side of
    the pipe, regardless whether it is read- or write- end.
   =20
    To checkpoint a file descriptor that refers to a pipe (either end), w=
e
    first lookup the inode in the hash table: If not found, it is the
    first encounter of this pipe. Besides the file descriptor, we also (a=
)
    save the pipe data, and (b) register the pipe inode in the hash. If
    found, it is the second encounter of this pipe, namely, as we hit the
    other end of the same pipe. In both cases we write the pipe-objref of
    the inode.
   =20
    To restore, create a new pipe and thus have two file pointers (read-
    and write- ends). We only use one of them, depending on which side wa=
s
    checkpointed first. We register the file pointer of the other end in
    the hash table, with the pipe_objref given for this pipe from the
    checkpoint, to be used later when the other arrives. At this point we
    also restore the contents of the pipe buffers.
   =20
    To save the pipe buffer, given a source pipe, use do_tee() to clone
    its contents into a temporary 'struct pipe_inode_info', and then use
    do_splice_from() to transfer it directly to the checkpoint image file.
   =20
    To restore the pipe buffer, with a fresh newly allocated target pipe,
    use do_splice_to() to splice the data directly between the checkpoint
    image file and the pipe.
   =20
    Changelog[v17]:
      - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a85111be31c01e87da53cae1fb4dcecabaa83a0b
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:01 2009 -0400

    splice: export pipe/file-to-pipe/file functionality
   =20
    During pipes c/r pipes we need to save and restore pipe buffers. But
    do_splice() requires two file descriptors, therefore we can't use it,
    as we always have one file descriptor (checkpoint image) and one
    pipe_inode_info.
   =20
    This patch exports interfaces that work at the pipe_inode_info level,
    namely link_pipe(), do_splice_to() and do_splice_from(). They are use=
d
    in the following patch to to save and restore pipe buffers without
    unnecessary data copy.
   =20
    It slightly modifies both do_splice_to() and do_splice_from() to
    detect the case of pipe-to-pipe transfer, in which case they invoke
    splice_pipe_to_pipe() directly.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e9e4ed6e3c810f2bfd7da3fd5796f46ec68634c5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: restore anonymous- and file-mapped- shared memory
   =20
    The bulk of the work is in ckpt_read_vma(), which has been refactored=
:
    the part that create the suitable 'struct file *' for the mapping is
    now larger and moved to a separate function. What's left is to read
    the VMA description, get the file pointer, create the mapping, and
    proceed to read the contents in.
   =20
    Both anonymous shared VMAs that have been read earlier (as indicated
    by a look up to objhash) and file-mapped shared VMAs are skipped.
    Anonymous shared VMAs seen for the first time have their contents
    read in directly to the backing inode, as indexed by the page numbers
    (as opposed to virtual addresses).
   =20
    Changelog[v14]:
      - Introduce patch
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit f71c3f60dee52b311165e4945a5a7aeec29b7d34
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: dump anonymous- and file-mapped- shared memory
   =20
    We now handle anonymous and file-mapped shared memory. Support for IP=
C
    shared memory requires support for IPC first. We extend ckpt_write_vm=
a()
    to detect shared memory VMAs and handle it separately than private
    memory.
   =20
    There is not much to do for file-mapped shared memory, except to forc=
e
    msync() on the region to ensure that the file system is consistent
    with the checkpoint image. Use our internal type CKPT_VMA_SHM_FILE.
   =20
    Anonymous shared memory is always backed by inode in shmem filesystem.
    We use that inode to look up the VMA in the objhash and register it i=
f
    not found (on first encounter). In this case, the type of the VMA is
    CKPT_VMA_SHM_ANON, and we dump the contents. On the other hand, if it=
 is
    found there, we must have already saved it before, so we change the
    type to CKPT_VMA_SHM_ANON_SKIP and skip it.
   =20
    To dump the contents of a shmem VMA, we loop through the pages of the
    inode in the shmem filesystem, and dump the contents of each dirty
    (allocated) page - unallocated pages must be clean.
   =20
    Note that we save the original size of a shmem VMA because it may hav=
e
    been re-mapped partially. The format itself remains like with private
    VMAs, except that instead of addresses we record _indices_ (page nr)
    into the backing inode.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit b28384550f38921778b19390398b96405d69239d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: export shmem_getpage() to support shared memory
   =20
    Export functionality to retrieve specific pages from shared memory
    given an inode in shmem-fs; this will be used in the next two patches
    to provide support for c/r of shared memory.
   =20
    mm/shmem.c:
    - shmem_getpage() and 'enum sgp_type' moved to linux/mm.h
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit f12254c74fcf1e7aadb4541e953fd3fdbd276e62
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: restore memory address space (private memory)
   =20
    Restoring the memory address space begins with nuking the existing on=
e
    of the current process, and then reading the vma state and contents.
    Call do_mmap_pgoffset() for each vma and then read in the data.
   =20
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
      - Test for no vma's in exit_mmap() before calling unmap_vma() (or i=
t
        may crash if restart fails after having removed all vma's)
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v9]:
      - Introduce ckpt_ctx_checkpoint() for checkpoint-specific ctx setup
    Changelog[v7]:
      - Fix argument given to kunmap_atomic() in memory dump/restore
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put(=
)
        (even though it's not really needed)
    Changelog[v5]:
      - Improve memory restore code (following Dave Hansen's comments)
      - Change dump format (and code) to allow chunks of <vaddrs, pages>
        instead of one long list of each
      - Memory restore now maps user pages explicitly to copy data into t=
hem,
        instead of reading directly to user space; got rid of mprotect_fi=
xup()
    Changelog[v4]:
      - Use standard list_... for ckpt_pgarr
   =20
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit d88bc1173a159df716b774738b761e121ef31f09
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: dump memory address space (private memory)
   =20
    For each vma, there is a 'struct ckpt_vma'; Then comes the actual
    contents, in one or more chunk: each chunk begins with a header that
    specifies how many pages it holds, then the virtual addresses of all
    the dumped pages in that chunk, followed by the actual contents of al=
l
    dumped pages. A header with zero number of pages marks the end of the
    contents.  Then comes the next vma and so on.
   =20
    To checkpoint a vma, call the ops->checkpoint() method of that vma.
    Normally the per-vma function will invoke generic_vma_checkpoint()
    which first writes the vma description, followed by the specific
    logic to dump the contents of the pages.
   =20
    Currently for private mapped memory we save the pathname of the file
    that is mapped (restart will use it to re-open it and then map it).
    Later we change that to reference a file object.
   =20
    Changelog[v17]:
      - Only collect sub-objects of mm_struct once
      - Save mm->{flags,def_flags,saved_auxv}
    Changelog[v16]:
      - Precede vaddrs/pages with a buffer header
      - Checkpoint mm->exe_file
      - Handle shared task->mm
    Changelog[v14]:
      - Modify the ops->checkpoint method to be much more powerful
      - Improve support for VDSO (with special_mapping checkpoint callbac=
k)
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
        namespace boundary). for now ckpt_fill_fname() fails the checkpoi=
nt.
    Changelog[v7]:
      - Fix argument given to kunmap_atomic() in memory dump/restore
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put(=
)
        (even though it's not really needed)
    Changelog[v5]:
      - Improve memory dump code (following Dave Hansen's comments)
      - Change dump format (and code) to allow chunks of <vaddrs, pages>
        instead of one long list of each
      - Fix use of follow_page() to avoid faulting in non-present pages
    Changelog[v4]:
      - Use standard list_... for ckpt_pgarr
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c3cd79a8d0e1666a6049216b519ad6f3394c11bd
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: introduce method '->checkpoint()' in struct vm_operations_struct
   =20
    Changelog[v17]
      - Forward-declare 'ckpt_ctx et-al, don't use checkpoint_types.h
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit d12e97a75dc6eb4338df9807bb0db99f0fd870f6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: add generic '->checkpoint()' f_op to simple devices
   =20
    * /dev/null
    * /dev/zero
    * /dev/random
    * /dev/urandom
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 64ec541b7ffe78d55c5edc567081158aa664b0c4
Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: add generic '->checkpoint' f_op to ext fses
   =20
    This marks ext[234] as being checkpointable.  There will be many
    more to do this to, but this is a start.
   =20
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit c642a91f59de9b4dd022cfff6301317aca70fb57
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: restore open file descriptors
   =20
    For each fd read 'struct ckpt_hdr_file_desc' and lookup objref in the
    hash table; If not found in the hash table, (first occurence), read i=
n
    'struct ckpt_hdr_file', create a new file and register in the hash.
    Otherwise attach the file pointer from the hash as an FD.
   =20
    Changelog[v17]:
      - Validate f_mode after restore against saved f_mode
      - Fail if f_flags have O_CREAT|O_EXCL|O_NOCTTY|O_TRUN
      - Reorder patch (move earlier in series)
      - Handle shared files_struct objects
    Changelog[v14]:
      - Introduce a per file-type restore() callback
      - Revert change to pr_debug(), back to ckpt_debug()
      - Rename:  restore_files() =3D> restore_fd_table()
      - Rename:  ckpt_read_fd_data() =3D> restore_file()
      - Check whether calls to ckpt_hbuf_get() fail
      - Discard field 'hh->parent'
    Changelog[v12]:
      - Replace obsolete ckpt_debug() with pr_debug()
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put(=
)
        (even though it's not really needed)
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 0be12f2d171c8a8e51d36b25216615cb3afdf72e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: dump open file descriptors
   =20
    Dump the file table with 'struct ckpt_hdr_file_table, followed by all
    open file descriptors. Because the 'struct file' corresponding to an
    fd can be shared, they are assigned an objref and registered in the
    object hash. A reference to the 'file *' is kept for as long as it
    lives in the hash (the hash is only cleaned up at the end of the
    checkpoint).
   =20
    Also provide generic_checkpoint_file() and generic_restore_file()
    which is good for normal files and directories. It does not support
    yet unlinked files or directories.
   =20
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
      - Rename:  ckpt_write_files() =3D> checkpoint_fd_table()
      - Rename:  ckpt_write_fd_data() =3D> checkpoint_file()
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
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put(=
)
        (even though it's not really needed)
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit fcb322e721c2b9b665ba8594bb5c9c97d1dd5c95
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: introduce '->checkpoint()' method in 'struct file_operations'
   =20
    While we assume all normal files and directories can be checkpointed,
    there are, as usual in the VFS, specialized places that will always
    need an ability to override these defaults. Although we could do this
    completely in the checkpoint code, that would bitrot quickly.
   =20
    This adds a new 'file_operations' function for checkpointing a file.
    It is assumed that there should be a dirt-simple way to make somethin=
g
    (un)checkpointable that fits in with current code.
   =20
    As you can see in the ext[234] patches down the road, all that we hav=
e
    to do to make something simple be supported is add a single "generic"
    f_op entry.
   =20
    Also introduce vfs_fcntl() so that it can be called from restart (see
    patch adding restart of files).
   =20
    Changelog[v17]
      - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 910c3df126d8f44e0d1ca9526fb0dfa9dd887c14
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: detect resource leaks for whole-container checkpoint
   =20
    Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
    checkpoint, return an error code if the actual objects' counts are
    higher, indicating leaks (references to the objects from a task not
    being checkpointed).  Of course, by this time most of the checkpoint
    image has been written out to disk, so this is purely advisory.  But
    then, it's probably naive to argue that anything more than an advisor=
y
    'this went wrong' error code is useful.
   =20
    The comparison of the objhash user counts to object refcounts as a
    basis for checking for leaks comes from Alexey's OpenVZ-based c/r
    patchset.
   =20
    "Leak detection" occurs _before_ any real state is saved, as a
    pre-step. This prevents races due to sharing with outside world where
    the sharing ceases before the leak test takes place, thus protecting
    the checkpoint image from inconsistencies.
   =20
    Once leak testing concludes, checkpoint will proceed. Because objects
    are already in the objhash, checkpoint_obj() cannot distinguish
    between the first and subsequent encounters. This is solved with a
    flag (CKPT_OBJ_CHECKPOINTED) per object.
   =20
    Two additional checks take place during checkpoint: for objects that
    were created during, and objects destroyed, while the leak-detection
    pre-step took place.
   =20
    Changelog[v17]:
      - Leak detection is performed in two-steps
      - Detect reverse-leaks (objects disappearing unexpectedly)
      - Skip reverse-leak detection if ops->ref_users isn't defined
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 3e8f745f577ba85d6a5b82a36b7128d5879c70fd
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:17:00 2009 -0400

    c/r: infrastructure for shared objects
   =20
    The state of shared objects is saved once. On the first encounter, th=
e
    state is dumped and the object is assigned a unique identifier (objre=
f)
    and also stored in a hash table (indexed by its physical kernel addre=
ss).
    From then on the object will be found in the hash and only its identi=
fier
    is saved.
   =20
    On restart the identifier is looked up in the hash table; if not foun=
d
    then the state is read, the object is created, and added to the hash
    table (this time indexed by its identifier). Otherwise, the object in
    the hash table is used.
   =20
    The hash is "one-way": objects added to it are never deleted until th=
e
    hash it discarded. The hash is discarded at the end of checkpoint or
    restart, whether successful or not.
   =20
    The hash keeps a reference to every object that is added to it, match=
ing
    the object's type, and maintains this reference during its lifetime.
    Therefore, it is always safe to use an object that is stored in the h=
ash.
   =20
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
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 7891e26585dbc19d1824a0ab9b4ce0c4851bb663
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 13:16:44 2009 -0400

    c/r: Save and restore the [compat_]robust_list member of the task str=
uct
   =20
    These lists record which futexes the task holds. To keep the overhead=
 of
    robust futexes low the list is kept in userspace. When the task exits=
 the
    kernel carefully walks these lists to recover held futexes that
    other tasks may be attempting to acquire with FUTEX_WAIT.
   =20
    Because they point to userspace memory that is saved/restored by
    checkpoint/restart saving the list pointers themselves is safe.
   =20
    While saving the pointers is safe during checkpoint, restart is trick=
y
    because the robust futex ABI contains provisions for changes based on
    checking the size of the list head. So we need to save the length of
    the list head too in order to make sure that the kernel used during
    restart is capable of handling that ABI. Since there is only one ABI
    supported at the moment taking the list head's size is simple. Should
    the ABI change we will need to use the same size as specified during
    sys_set_robust_list() and hence some new means of determining the len=
gth
    of this userspace structure in sys_checkpoint would be required.
   =20
    Rather than rewrite the logic that checks and handles the ABI we reus=
e
    sys_set_robust_list() by factoring out the body of the function and
    calling it during restart.
   =20
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: move save/restore code to checkpoint/process.=
c]

commit 5c79b44ac7f2af8b006b9a38581bbe28cfbb84ee
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:15:11 2009 -0400

    c/r: support for zombie processes
   =20
    During checkpoint, a zombie processes need only save p->comm,
    p->state, p->exit_state, and p->exit_code.
   =20
    During restart, zombie processes are created like all other
    processes. They validate the saved exit_code restore p->comm
    and p->exit_code. Then they call do_exit() instead of waking
    up the next task in line.
   =20
    But before, they place the @ctx in p->checkpoint_ctx, so that
    only at exit time they will wake up the next task in line,
    and drop the reference to the @ctx.
   =20
    This provides the guarantee that when the coordinator's wait
    completes, all normal tasks completed their restart, and all
    zombie tasks are already zombified (as opposed to perhap only
    becoming a zombie).
   =20
    Changelog[v17]:
      - Validate t->exit_signal for both threads and leader
      - Skip zombies in most of may_checkpoint_task()
      - Save/restore t->pdeath_signal
      - Validate ->exit_signal and ->pdeath_signal
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 10b04de65897fbdc7339474b6e9ae8e88591f59a
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:15:11 2009 -0400

    c/r: introduce PF_RESTARTING, and skip notification on exit
   =20
    To restore zombie's we will create the a task, that, on its turn to
    run, calls do_exit(). Unlike normal tasks that exit, we need to
    prevent notification side effects that send signals to other
    processes, e.g. parent (SIGCHLD) or child tasks (per child's request).
   =20
    There are three main cases for such notifications:
   =20
    1) do_notify_parent(): parent of a process is notified about a change
     in status (e.g. become zombie, reparent, etc). If parent ignores,
     then mark child for immediate release (skip zombie).
   =20
    2) kill_orphan_pgrp(): a process group that becomes orphaned will
     signal stopped jobs (HUP then CONT).
   =20
    3) reparent_thread(): children of a process are signaled (per request=
)
     with p->pdeath_signal
   =20
    Remember that restoring signal state (for any restarting task) must
    complete _before_ it is allowed to resume execution, and not during
    the resume. Otherwise, a running task may send a signal to another
    task that hasn't restored yet, so the new signal will be lost
    soon-after.
   =20
    I considered two possible way to address this:
   =20
    1. Add another sync point to restart: all tasks will first restore
    their state without signals (all signals blocked), and zombies call
    do_exit(). A sync point then will ensure that all zombies are gone an=
d
    their effects done. Then all tasks restore their signal state (and
    mask), and sync (new point) again. Only then they may resume
    execution.
    The main disadvantage is the added complexity and inefficiency,
    for no good reason.
   =20
    2. Introduce PF_RESTARTING: mark all restarting tasks with a new flag=
,
    and teach the above three notifications to skip sending the signal if
    theis flag is set.
    The main advantage is simplicity and completeness. Also, such a flag
    may to be useful later on. This the method implemented.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c79d0d7717e639b4a6b6aed998007831efdf2abe
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:15:10 2009 -0400

    c/r: restart multiple processes
   =20
    Restarting of multiple processes expects all restarting tasks to call
    sys_restart(). Once inside the system call, each task will restart
    itself at the same order that they were saved. The internals of the
    syscall will take care of in-kernel synchronization bewteen tasks.
   =20
    This patch does _not_ create the task tree in the kernel. Instead it
    assumes that all tasks are created in some way and then invoke the
    restart syscall. You can use the userspace mktree.c program to do
    that.
   =20
    There is one special task - the coordinator - that is not part of the
    restarted hierarchy. The coordinator task allocates the restart
    context (ctx) and orchestrates the restart. Thus even if a restart
    fails after, or during the restore of the root task, the user
    perceives a clean exit and an error message.
   =20
    The coordinator task will:
     1) read header and tree, create @ctx (wake up restarting tasks)
     2) set the ->checkpoint_ctx field of itself and all descendants
     3) wait for all restarting tasks to reach sync point #1
     4) activate first restarting task (root task)
     5) wait for all other tasks to complete and reach sync point #3
     6) wake up everybody
   =20
    (Note that in step #2 the coordinator assumes that the entire task
    hierarchy exists by the time it enters sys_restart; this is arranged
    in user space by 'mktree')
   =20
    Task that are restarting has three sync points:
     1) wait for its ->checkpoint_ctx to be set (by the coordinator)
     2) wait for the task's turn to restore (be active)
     [...now the task restores its state...]
     3) wait for all other tasks to complete
   =20
    The third sync point ensures that a task may only resume execution
    after all tasks have successfully restored their state (or fail if an
    error has occured). This prevents tasks from returning to user space
    prematurely, before the entire restart completes.
   =20
    If a single task wishes to restart, it can set the "RESTART_TASKSELF"
    flag to restart(2) to skip the logic of the coordinator.
   =20
    The root-task is a child of the coordinator, identified by the @pid
    given to sys_restart() in the pid-ns of the coordinator. Restarting
    tasks that aren't the coordinator, should set the @pid argument of
    restart(2) syscall to zero.
   =20
    All tasks explicitly test for an error flag on the checkpoint context
    when they wakeup from sync points.  If an error occurs during the
    restart of some task, it will mark the @ctx with an error flag, and
    wakeup the other tasks.
   =20
    An array of pids (the one saved during the checkpoint) is used to
    synchronize the operation. The first task in the array is the init
    task (*). The restart context (@ctx) maintains a "current position" i=
n
    the array, which indicates which task is currently active. Once the
    currently active task completes its own restart, it increments that
    position and wakes up the next task.
   =20
    Restart assumes that userspace provides meaningful data, otherwise
    it's garbage-in-garbage-out. In this case, the syscall may block
    indefinitely, but in TASK_INTERRUPTIBLE, so the user can ctrl-c or
    otherwise kill the stray restarting tasks.
   =20
    In terms of security, restart runs as the user the invokes it, so it
    will not allow a user to do more than is otherwise permitted by the
    usual system semantics and policy.
   =20
    Currently we ignore threads and zombies, as well as session ids.
    Add support for multiple processes
   =20
    (*) For containers, restart should be called inside a fresh container
    by the init task of that container. However, it is also possible to
    restart applications not necessarily inside a container, and without
    restoring the original pids of the processes (that is, provided that
    the application can tolerate such behavior). This is useful to allow
    multi-process restart of tasks not isolated inside a container, and
    also for debugging.
   =20
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
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 3002f6c85bdcc830611aa54166750aaca4f933ee
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:15:10 2009 -0400

    c/r: checkpoint multiple processes
   =20
    Checkpointing of multiple processes works by recording the tasks tree
    structure below a given "root" task. The root task is expected to be =
a
    container init, and then an entire container is checkpointed. However=
,
    passing CHECKPOINT_SUBTREE to checkpoint(2) relaxes this requirement
    and allows to checkpoint a subtree of processes from the root task.
   =20
    For a given root task, do a DFS scan of the tasks tree and collect th=
em
    into an array (keeping a reference to each task). Using DFS simplifie=
s
    the recreation of tasks either in user space or kernel space. For eac=
h
    task collected, test if it can be checkpointed, and save its pid, tgi=
d,
    and ppid.
   =20
    The actual work is divided into two passes: a first scan counts the
    tasks, then memory is allocated and a second scan fills the array.
   =20
    Whether checkpoints and restarts require CAP_SYS_ADMIN is determined
    by sysctl 'ckpt_unpriv_allowed': if 1, then regular permission checks
    are intended to prevent privilege escalation, however if 0 it prevent=
s
    unprivileged users from exploiting any privilege escalation bugs.
   =20
    The logic is suitable for creation of processes during restart either
    in userspace or by the kernel.
   =20
    Currently we ignore threads and zombies.
   =20
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
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit af9d5a0ff64aab7f53b0b470595b94d9cc5b7330
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:03:20 2009 -0400

    c/r: restart-blocks
   =20
    (Paraphrasing what's said this message:
    http://lists.openwall.net/linux-kernel/2007/12/05/64)
   =20
    Restart blocks are callbacks used cause a system call to be restarted
    with the arguments specified in the system call restart block. It is
    useful for system call that are not idempotent, i.e. the argument(s)
    might be a relative timeout, where some adjustments are required when
    restarting the system call. It relies on the system call itself to se=
t
    up its restart point and the argument save area.  They are rare: an
    actual signal would turn that it an EINTR. The only case that should
    ever trigger this is some kernel action that interrupts the system
    call, but does not actually result in any user-visible state changes =
-
    like freeze and thaw.
   =20
    So restart blocks are about time remaining for the system call to
    sleep/wait. Generally in c/r, there are two possible time models that
    we can follow: absolute, relative. Here, I chose to save the relative
    timeout, measured from the beginning of the checkpoint. The time when
    the checkpoint (and restart) begin is also saved. This information is
    sufficient to restart in either model (absolute or negative).
   =20
    Which model to use should eventually be a per application choice (and
    possible configurable via cradvise() or some sort). For now, we adopt
    the relative model, namely, at restart the timeout is set relative to
    the beginning of the restart.
   =20
    To checkpoint, we check if a task has a valid restart block, and if s=
o
    we save the *remaining* time that is has to wait/sleep, and the type
    of the restart block.
   =20
    To restart, we fill in the data required at the proper place in the
    thread information. If the system call return an error (which is
    possibly an -ERESTARTSYS eg), we not only use that error as our own
    return value, but also arrange for the task to execute the signal
    handler (by faking a signal). The handler, in turn, already has the
    code to handle these restart request gracefully.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit cc8e6738f78b87f2752425746a99c168c03d981b
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:03:00 2009 -0400

    c/r: export functionality used in next patch for restart-blocks
   =20
    To support c/r of restart-blocks (system call that need to be
    restarted because they were interrupted but there was no userspace
    visible side-effect), export restart-block callbacks for poll()
    and futex() syscalls.
   =20
    More details on c/r of restart-blocks and how it works in the
    following patch.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 941b62b4d8d60514cc6dbb7cb5b3a586b36a5c5e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:02:59 2009 -0400

    c/r: external checkpoint of a task other than ourself
   =20
    Now we can do "external" checkpoint, i.e. act on another task.
   =20
    sys_checkpoint() now looks up the target pid (in our namespace) and
    checkpoints that corresponding task. That task should be the root of
    a container, unless CHECKPOINT_SUBTREE flag is given.
   =20
    Set state of freezer cgroup of checkpointed task hierarchy to
    "CHECKPOINTING" during a checkpoint, to ensure that task(s) cannot be
    thawed while at it.
   =20
    Ensure that all tasks belong to root task's freezer cgroup (the root
    task is also tested, to detect it if changes its freezer cgroups
    before it moves to "CHECKPOINTING").
   =20
    sys_restart() remains nearly the same, as the restart is always done
    in the context of the restarting task. However, the original task may
    have been frozen from user space, or interrupted from a syscall for
    the checkpoint. This is accounted for by restoring a suitable retval
    for the restarting task, according to how it was checkpointed.
   =20
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
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e59a6da27e4f1892e43caf98515e08263116a1e6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:02:59 2009 -0400

    c/r: x86_32 support for checkpoint/restart
   =20
    Add logic to save and restore architecture specific state, including
    thread-specific state, CPU registers and FPU state.
   =20
    In addition, architecture capabilities are saved in an architecure
    specific extension of the header (ckpt_hdr_head_arch); Currently this
    includes only FPU capabilities.
   =20
    Currently only x86-32 is supported.
   =20
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
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 5e199f6787436a16a89a51ac4692b66531d857a3
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:02:59 2009 -0400

    c/r: basic infrastructure for checkpoint/restart
   =20
    Add those interfaces, as well as helpers needed to easily manage the
    file format. The code is roughly broken out as follows:
   =20
    checkpoint/sys.c - user/kernel data transfer, as well as setup of the
      c/r context (a per-checkpoint data structure for housekeeping)
   =20
    checkpoint/checkpoint.c - output wrappers and basic checkpoint handli=
ng
   =20
    checkpoint/restart.c - input wrappers and basic restart handling
   =20
    checkpoint/process.c - c/r of task data
   =20
    For now, we can only checkpoint the 'current' task ("self" checkpoint=
),
    and the 'pid' argument to the syscall is ignored.
   =20
    Patches to add the per-architecture support as well as the actual
    work to do the memory checkpoint follow in subsequent patches.
   =20
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
      - Split ctx->flags to ->uflags (user flags) and ->kflags (kernel fl=
ags)
      - Introduce __ckpt_write_err() and ckpt_write_err() to report error=
s
      - Allow @ptr =3D=3D NULL to write (or read) header only without pay=
load
      - Introduce _ckpt_read_obj_type()
    Changelog[v15]:
      - Replace header buffer in ckpt_ctx (hbuf,hpos) with kmalloc/kfree(=
)
    Changelog[v14]:
      - Cleanup interface to get/put hdr buffers
      - Merge checkpoint and restart code into a single file (per subsyst=
em)
      - Take uts_sem around access to uts->{release,version,machine}
      - Embed ckpt_hdr in all ckpt_hdr_...., cleanup read/write helpers
      - Define sys_checkpoint(0,...) as asking for a self-checkpoint (Ser=
ge)
      - Revert use of 'pr_fmt' to avoid tainting whom includes us (Nathan=
 Lynch)
      - Explicitly indicate length of UTS fields in header
      - Discard field 'h->parent' from ckpt_hdr
    Changelog[v12]:
      - ckpt_kwrite/ckpt_kread() again use vfs_read(), vfs_write() (safer=
)
      - Split ckpt_write/ckpt_read() to two parts: _ckpt_write/read() hel=
per
      - Befriend with sparse : explicit conversion to 'void __user *'
      - Redfine 'pr_fmt' instead of using special ckpt_debug()
    Changelog[v10]:
      - add ckpt_write_buffer(), ckpt_read_buffer() and ckpt_read_buf_typ=
e()
      - force end-of-string in ckpt_read_string() (fix possible DoS)
    Changelog[v9]:
      - ckpt_kwrite/ckpt_kread() use file->f_op->write() directly
      - Drop ckpt_uwrite/ckpt_uread() since they aren't used anywhere
    Changelog[v6]:
      - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put(=
)
        (although it's not really needed)
    Changelog[v5]:
      - Rename headers files s/ckpt/checkpoint/
    Changelog[v2]:
      - Added utsname->{release,version,machine} to checkpoint header
      - Pad header structures to 64 bits to ensure compatibility
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 213e128413b08bf002e2f4e74322a79bd9c9c684
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:02:58 2009 -0400

    c/r: documentation
   =20
    Covers application checkpoint/restart, overall design, interfaces,
    usage, shared objects, and and checkpoint image format.
   =20
    Changelog[v16]:
      - Update documentation
      - Unify into readme.txt and usage.txt
    Changelog[v14]:
      - Discard the 'h.parent' field
      - New image format (shared objects appear before they are reference=
d
        unless they are compound)
    Changelog[v8]:
      - Split into multiple files in Documentation/checkpoint/...
      - Extend documentation, fix typos and comments from feedback
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit 7e3a42ccedfe39c53366eb67fcfe0619cce4fcea
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:02:58 2009 -0400

    c/r: create syscalls: sys_checkpoint, sys_restart
   =20
    Create trivial sys_checkpoint and sys_restore system calls. They will
    enable to checkpoint and restart an entire container, to and from a
    checkpoint image file descriptor.
   =20
    The syscalls take a pid, a file descriptor (for the image file) and
    flags as arguments. The pid identifies the top-most (root) task in th=
e
    process tree, e.g. the container init: for sys_checkpoint the first
    argument identifies the pid of the target container/subtree; for
    sys_restart it will identify the pid of restarting root task.
   =20
    A checkpoint, much like a process coredump, dumps the state of multip=
le
    processes at once, including the state of the container. The checkpoi=
nt
    image is written to (and read from) the file descriptor directly from
    the kernel. This way the data is generated and then pushed out natura=
lly
    as resources and tasks are scanned to save their state. This is the
    approach taken by, e.g., Zap and OpenVZ.
   =20
    By using a return value and not a file descriptor, we can distinguish
    between a return from checkpoint, a return from restart (in case of a
    checkpoint that includes self, i.e. a task checkpointing its own
    container, or itself), and an error condition, in a manner analogous
    to a fork() call.
   =20
    We don't use copy_from_user()/copy_to_user() because it requires
    holding the entire image in user space, and does not make sense for
    restart.  Also, we don't use a pipe, pseudo-fs file and the like,
    because they work by generating data on demand as the user pulls it
    (unless the entire image is buffered in the kernel) and would require
    more complex logic.  They also would significantly complicate
    checkpoint that includes self.
   =20
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
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit 85cd12a30e3492464bc5d55fac26d70ffeb195f8
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:58 2009 -0400

    pids 7/7: Define clone_with_pids syscall
   =20
    Container restart requires that a task have the same pid it had when =
it was
    checkpointed. When containers are nested the tasks within the contain=
ers
    exist in multiple pid namespaces and hence have multiple pids to spec=
ify
    during restart.
   =20
    clone_with_pids(), intended for use during restart, is the same as cl=
one(),
    except that it takes a 'target_pid_set' paramter. This parameter lets=
 caller
    choose specific pid numbers for the child process, in the process's a=
ctive
    and ancestor pid namespaces. (Descendant pid namespaces in general do=
n't
    matter since processes don't have pids in them anyway, but see commen=
ts
    in copy_target_pids() regarding CLONE_NEWPID).
   =20
    Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for n=
ow, to
    prevent unprivileged processes from misusing this interface.
   =20
    Call clone_with_pids as follows:
   =20
    	pid_t pids[] =3D { 0, 77, 99 };
    	struct target_pid_set pid_set;
   =20
    	pid_set.num_pids =3D sizeof(pids) / sizeof(int);
    	pid_set.target_pids =3D &pids;
   =20
    	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_s=
et);
   =20
    If a target-pid is 0, the kernel continues to assign a pid for the pr=
ocess in
    that namespace. In the above example, pids[0] is 0, meaning the kerne=
l will
    assign next available pid to the process in init_pid_ns. But kernel w=
ill assign
    pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If=
 either
    77 or 99 are taken, the system call fails with -EBUSY.
   =20
    If 'pid_set.num_pids' exceeds the current nesting level of pid namesp=
aces,
    the system call fails with -EINVAL.
   =20
    Its mostly an exploratory patch seeking feedback on the interface.
   =20
    NOTE:
    	Compared to clone(), clone_with_pids() needs to pass in two more
    	pieces of information:
   =20
    		- number of pids in the set
    		- user buffer containing the list of pids.
   =20
    	But since clone() already takes 5 parameters, use a 'struct
    	target_pid_set'.
   =20
    TODO:
    	- Gently tested.
    	- May need additional sanity checks in do_fork_with_pids().
   =20
    Changelog[v3]:
    	- (Oren Laadan) Allow CLONE_NEWPID flag (by allocating an extra pid
    	  in the target_pids[] list and setting it 0. See copy_target_pids()=
).
    	- (Oren Laadan) Specified target pids should apply only to youngest
    	  pid-namespaces (see copy_target_pids())
    	- (Matt Helsley) Update patch description.
   =20
    Changelog[v2]:
    	- Remove unnecessary printk and add a note to callers of
    	  copy_target_pids() to free target_pids.
    	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch descript=
ion.
    	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
    	  'num_pids =3D=3D 0' (fall back to normal clone()).
    	- Move arch-independent code (sanity checks and copy-in of target-pi=
ds)
    	  into kernel/fork.c and simplify sys_clone_with_pids()
   =20
    Changelog[v1]:
    	- Fixed some compile errors (had fixed these errors earlier in my
    	  git tree but had not refreshed patches before emailing them)
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit 5e6aa6046575f734b1a729ba7e9df8f84f726b54
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:57 2009 -0400

    pids 6/7: Define do_fork_with_pids()
   =20
    do_fork_with_pids() is same as do_fork(), except that it takes an
    additional, 'pid_set', parameter. This parameter, currently unused,
    specifies the set of target pids of the process in each of its pid
    namespaces.
   =20
    Changelog[v3]:
    	- Fix "long-line" warning from checkpatch.pl
   =20
    Changelog[v2]:
    	- To facilitate moving architecture-inpdendent code to kernel/fork.c
    	  pass in 'struct target_pid_set __user *' to do_fork_with_pids()
    	  rather than 'pid_t *' (next patch moves the arch-independent
    	  code to kernel/fork.c)
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c943055d0369dbd1b9750a4fee65efd8c35603fc
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:57 2009 -0400

    pids 5/7: Add target_pids parameter to copy_process()
   =20
    The new parameter will be used in a follow-on patch when clone_with_p=
ids()
    is implemented.
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 852706340524ee889b6b39f3d95851ccd7304bfb
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:57 2009 -0400

    pids 4/7: Add target_pids parameter to alloc_pid()
   =20
    This parameter is currently NULL, but will be used in a follow-on pat=
ch.
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit df3d617516c52ebfb61f7c8532818fc021f79950
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:56 2009 -0400

    pids 3/7: Add target_pid parameter to alloc_pidmap()
   =20
    With support for setting a specific pid number for a process,
    alloc_pidmap() will need a paramter a 'target_pid' parameter.
   =20
    Changelog[v2]:
    	- (Serge Hallyn) Check for 'pid < 0' in set_pidmap().(Code
    	  actually checks for 'pid <=3D 0' for completeness).
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 54a5bd453108b266524f3fb641bc40f5b0a43cb0
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:56 2009 -0400

    pids 2/7: Have alloc_pidmap() return actual error code
   =20
    alloc_pidmap() can fail either because all pid numbers are in use or
    because memory allocation failed.  With support for setting a specifi=
c
    pid number, alloc_pidmap() would also fail if either the given pid
    number is invalid or in use.
   =20
    Rather than have callers assume -ENOMEM, have alloc_pidmap() return
    the actual error.
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 0dd5c33d8568f34532c9300b4128553b5fcc3fe1
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:56 2009 -0400

    pids 1/7: Factor out code to allocate pidmap page
   =20
    To implement support for clone_with_pids() system call we would
    need to allocate pidmap page in more than one place. Move this
    code to a new function alloc_pidmap_page().
   =20
    Changelog[v2]:
    	- (Matt Helsley, Dave Hansen) Have alloc_pidmap_page() return
    	  -ENOMEM on error instead of -1.
   =20
    Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 8f1bfa90e4defe9467e051d0eedbd3e6e0e76e84
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 13:02:55 2009 -0400

    c/r: make file_pos_read/write() public
   =20
    These two are used in the next patch when calling vfs_read/write()
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit fb57fc0b669c69bb04822912a8627b8e677de60a
Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jul 21 13:02:55 2009 -0400

    Namespaces submenu
   =20
    Let's not steal too much space in the 'General Setup' menu.
    Take a cue from the cgroups code and create a submenu.
   =20
    This can go upstream now.
   =20
    Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 5552bd01b557c1895974c159b27a7417cc8f3fe6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jul 21 12:54:18 2009 -0400

    cgroup freezer: interface to freeze a cgroup from within the kernel
   =20
    Add public interface to freeze a cgroup freezer given a task that
    belongs to that cgroup:  cgroup_freezer_make_frozen(task)
   =20
    Freezing the root cgroup is not permitted. Freezing the cgroup to
    which current process belong is also not permitted.
   =20
    This will be used for restart(2) to be able to leave the restarted
    processes in a frozen state, instead of resuming execution.
   =20
    This is useful for debugging, if the user would like to attach a
    debugger to the restarted task(s).
   =20
    It is also useful if the restart procedure would like to perform
    additional setup once the tasks are restored but before they are
    allowed to proceed execution.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    CC: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

commit e311c00924252eb9f9b867d5fba2fff31bdd73d2
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 12:24:24 2009 -0400

    cgroup freezer: Add CHECKPOINTING state to safeguard container checkp=
oint
   =20
    The CHECKPOINTING state prevents userspace from unfreezing tasks unti=
l
    sys_checkpoint() is finished. When doing container checkpoint userspa=
ce
    will do:
   =20
    	echo FROZEN > /cgroups/my_container/freezer.state
    	...
    	rc =3D sys_checkpoint( <pid of container root> );
   =20
    To ensure a consistent checkpoint image userspace should not be allow=
ed
    to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state=
)
    during checkpoint.
   =20
    "CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkp=
oint
    system call. Once in the "CHECKPOINTING" state, the cgroup may not le=
ave until
    the checkpoint system call is finished and ready to return. Then the
    freezer state returns to "FROZEN". Writing any new state to freezer.s=
tate while
    checkpointing will return EBUSY. These semantics ensure that userspac=
e cannot
    unfreeze the cgroup midway through the checkpoint system call.
   =20
    The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoi=
nt()
    make relatively few assumptions about the task that is passed in. How=
ever the
    way they are called in do_checkpoint() assumes that the root of the c=
ontainer
    is in the same freezer cgroup as all the other tasks that will be
    checkpointed.
   =20
    Notes:
            As a side-effect this prevents the multiple tasks from enteri=
ng the
            CHECKPOINTING state simultaneously. All but one will get -EBU=
SY.
   =20
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

commit 211c6a21e3ba65402435c3e8f85e2bbd73d79c2d
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 12:24:10 2009 -0400

    cgroup freezer: Update stale locking comments
   =20
    Update stale comments regarding locking order and add a little more d=
etail
    so it's easier to follow the locking between the cgroup freezer and t=
he
    power management freezer code.
   =20
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
    Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

commit 41d05856910cc42764261fb0e45309a642ba2c3d
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 12:24:03 2009 -0400

    cgroup freezer: Fix buggy resume test for tasks frozen with cgroup fr=
eezer
   =20
    When the cgroup freezer is used to freeze tasks we do not want to tha=
w
    those tasks during resume. Currently we test the cgroup freezer
    state of the resuming tasks to see if the cgroup is FROZEN.  If so
    then we don't thaw the task. However, the FREEZING state also indicat=
es
    that the task should remain frozen.
   =20
    This also avoids a problem pointed out by Oren Ladaan: the freezer st=
ate
    transition from FREEZING to FROZEN is updated lazily when userspace r=
eads
    or writes the freezer.state file in the cgroup filesystem. This means=
 that
    resume will thaw tasks in cgroups which should be in the FROZEN state=
 if
    there is no read/write of the freezer.state file to trigger this
    transition before suspend.
   =20
    NOTE: Another "simple" solution would be to always update the cgroup
    freezer state during resume. However it's a bad choice for several re=
asons:
    Updating the cgroup freezer state is somewhat expensive because it re=
quires
    walking all the tasks in the cgroup and checking if they are each fro=
zen.
    Worse, this could easily make resume run in N^2 time where N is the n=
umber
    of tasks in the cgroup. Finally, updating the freezer state from this=
 code
    path requires trickier locking because of the way locks must be order=
ed.
   =20
    Instead of updating the freezer state we rely on the fact that lazy
    updates only manage the transition from FREEZING to FROZEN. We know t=
hat
    a cgroup with the FREEZING state may actually be FROZEN so test for t=
hat
    state too. This makes sense in the resume path even for partially-fro=
zen
    cgroups -- those that really are FREEZING but not FROZEN.
   =20
    Reported-by: Oren Ladaan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
    Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
    Cc: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
    Cc: linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
   =20
    Seems like a candidate for -stable.

commit 61ab533509f107678ae432925688b714388da3e5
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 12:22:23 2009 -0400

    c/r: split core function out of some set*{u,g}id functions
   =20
    When restarting tasks, we want to be able to change xuid and
    xgid in a struct cred, and do so with security checks.  Break
    the core functionality of set{fs,res}{u,g}id into cred_setX
    which performs the access checks based on current_cred(),
    but performs the requested change on a passed-in cred.
   =20
    This will allow us to securely construct struct creds based
    on a checkpoint image, constrained by the caller's permissions,
    and apply them to the caller at the end of sys_restart().
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 3f8c08d9d3d1c004be3b2632348ce44b10124cbc
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 21 12:22:23 2009 -0400

    c/r: break out new_user_ns()
   =20
    Break out the core function which checks privilege and (if
    allowed) creates a new user namespace, with the passed-in
    creating user_struct.  Note that a user_namespace, unlike
    other namespace pointers, is not stored in the nsproxy.
    Rather it is purely a property of user_structs.
   =20
    This will let us keep the task restore code simpler.
   =20
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit a17e34be2221b7df61e8c909973b44c0c5d8f121
Author: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Tue Jul 21 12:22:23 2009 -0400

    x86: ptrace debugreg checks rewrite
   =20
    This is a mess.
   =20
    Pre unified-x86 code did check for breakpoint addr
    to be "< TASK_SIZE - 3 (or 7)". This was fine from security POV,
    but banned valid breakpoint usage when address is close to TASK_SIZE.
    E. g. 1-byte breakpoint at TASK_SIZE - 1 should be allowed, but it wa=
sn't.
   =20
    Then came commit 84929801e14d968caeb84795bfbb88f04283fbd9
    ("[PATCH] x86_64: TASK_SIZE fixes for compatibility mode processes")
    which for some reason touched ptrace as well and made effective
    TASK_SIZE of 32-bit process depending on IA32_PAGE_OFFSET
    which is not a constant!:
   =20
    	#define IA32_PAGE_OFFSET ((current->personality & ADDR_LIMIT_3GB) ? =
0xc0000000 : 0xFFFFe000)
    				   ^^^^^^^
    Maximum addr for breakpoint became dependent on personality of ptrace=
r.
   =20
    Commit also relaxed danger zone for 32-bit processes from 8 bytes to =
4
    not taking into account that 8-byte wide breakpoints are possible eve=
n
    for 32-bit processes. This was fine, however, because 64-bit kernel
    addresses are too far from 32-bit ones.
   =20
    Then came utrace with commit 2047b08be67b70875d8765fc81d34ce28041bec3
    ("x86: x86 ptrace getreg/putreg merge") which copy-pasted and ifdeffe=
d 32-bit
    part of TASK_SIZE_OF() leaving 8-byte issue as-is.
   =20
    So, what patch fixes?
    1) Too strict logic near TASK_SIZE boundary -- as long as we don't cr=
oss
       TASK_SIZE_MAX, we're fine.
    2) Too smart logic of using breakpoints over non-existent kernel
       boundary -- we should only protect against setting up after
       TASK_SIZE_MAX, the rest is none of kernel business. This fixes
       IA32_PAGE_OFFSET beartrap as well.
   =20
    As a bonus, remove uberhack and big comment determining DR7 validness=
,
    rewrite with clear algorithm when it's obvious what's going on.
   =20
    Make DR validness checker suitable for C/R. On restart DR registers
    must be checked the same way they are checked on PTRACE_POKEUSR.
   =20
    Question 1: TIF_DEBUG can set even if none of breakpoints is turned o=
n,
    should this be optimized?
   =20
    Question 2: Breakpoints are allowed to be globally enabled, is this a
    security risk?
   =20
    Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

commit b09726314706d740283f72ca61c75ca54277495f
Author: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Tue Jul 21 12:22:12 2009 -0400

    c/r: extend arch_setup_additional_pages()
   =20
    Add "start" argument, to request to map vDSO to a specific place,
    and fail the operation if not.
   =20
    This is useful for restart(2) to ensure that memory layout is restore
    exactly as needed.
   =20
    Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 6847e154e3cd74fca6084124c097980a7634285a
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 13 18:18:52 2009 -0700

    Linux 2.6.31-rc3

commit 1cf29683f4414296dc772a87caa207cab16c310c
Merge: 4a390e07fc53ce9dd615d7b788e9ecc73f87ad94 96577c43827697ca1af5982fa=
256a34786d0c720
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 13 16:39:25 2009 -0700

    Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tytso/ext4
   =20
    * 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/=
ext4:
      jbd2: fix race between write_metadata_buffer and get_write_access
      ext4: Fix ext4_mb_initialize_context() to initialize all fields
      ext4: fix null handler of ioctls in no journal mode
      ext4: Fix buffer head reference leak in no-journal mode
      ext4: Move __ext4_journalled_writepage() to avoid forward declarati=
on
      ext4: Fix mmap/truncate race when blocksize < pagesize && !nodellao=
c
      ext4: Fix mmap/truncate race when blocksize < pagesize && delayed a=
llocation
      ext4: Don't look at buffer_heads outside i_size.
      ext4: Fix goal inum check in the inode allocator
      ext4: fix no journal corruption with locale-gen
      ext4: Calculate required journal credits for inserting an extent pr=
operly
      ext4: Fix truncation of symlinks after failed write
      jbd2: Fix a race between checkpointing code and journal_get_write_a=
ccess()
      ext4: Use rcu_barrier() on module unload.
      ext4: naturally align struct ext4_allocation_request
      ext4: mark several more functions in mballoc.c as noinline
      ext4: Fix potential reclaim deadlock when truncating partial block
      jbd2: Remove GFP_ATOMIC kmalloc from inside spinlock critical regio=
n
      ext4: Fix type warning on 64-bit platforms in tracing events header

commit 96577c43827697ca1af5982fa256a34786d0c720
Author: dingdinghua <dingdinghua85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jul 13 17:55:35 2009 -0400

    jbd2: fix race between write_metadata_buffer and get_write_access
   =20
    The function jbd2_journal_write_metadata_buffer() calls
    jbd_unlock_bh_state(bh_in) too early; this could potentially allow
    another thread to call get_write_access on the buffer head, modify th=
e
    data, and dirty it, and allowing the wrong data to be written into th=
e
    journal.  Fortunately, if we lose this race, the only time this will
    actually cause filesystem corruption is if there is a system crash or
    other unclean shutdown of the system before the next commit can take
    place.
   =20
    Signed-off-by: dingdinghua <dingdinghua85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 4a390e07fc53ce9dd615d7b788e9ecc73f87ad94
Merge: a4dc32374ed6dd56e09039ea8b7151c3a3e2307d f6387184f5196242edecbb538=
5bcc3481fae212a
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 13 10:24:43 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.=
6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6:
      Staging: stlc45xx: convert config_interface to bss_info_changed, fi=
xing a build error
      Staging: comedi: s626: use subvendor:subdevice ids for SAA7146 boar=
d
      Staging: prevent rtl8192su from crashing dev_ioctl in SIOCGIWNAME
      Staging: prevent rtl8187se from crashing dev_ioctl() in SIOCGIWNAME
      Staging: rtl8192su: convert to net_device_ops
      Staging: serqt_usb2: declare qt_open static in serqt_usb2
      Staging: serqt_usb2: fix qt_close parameters in serqt_usb2
      Staging: comedi: jr3_pci.c: add required includes
      Staging: meilhaus: add email address to TODO
      Staging: rspiusb: use NULL virtual address instead of a bogus one
      Staging: vt6655: compile fix
      Staging: rt2870: Add USB ID for Sitecom WL-608

commit a4dc32374ed6dd56e09039ea8b7151c3a3e2307d
Merge: 51feb98d2547a389be2f666514f5bcd658f79eab 38c7dc373029e4666b1785005=
4dd43c1c96bb264
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 13 10:24:08 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-cor=
e-2.6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core-2.=
6:
      wm97xx_batery: replace driver_data with dev_get_drvdata()
      omap: video: remove direct access of driver_data
      Sound: remove direct access of driver_data
      driver model: fix show/store prototypes in doc.
      Firmware: firmware_class, fix lock imbalance
      Driver Core: remove BUS_ID_SIZE
      sparc: remove driver-core BUS_ID_SIZE
      partitions: fix broken uevent_suppress conversion
      devres: WARN() and return, don't crash on device_del() of uninitial=
ized device

commit 51feb98d2547a389be2f666514f5bcd658f79eab
Merge: 8f8f013478133eb98e35e1d669c98c5e39d769c7 dc7520c17982ca4232233d278=
1e5cde29e58fbad
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 13 10:23:03 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6: (48 c=
ommits)
      USB: otg: fix module reinsert issue
      USB: handle zero-length usbfs submissions correctly
      USB: EHCI: report actual_length for iso transfers
      USB: option: remove unnecessary and erroneous code
      USB: cypress_m8: remove invalid Clear-Halt
      USB: musb_host: undo incorrect change in musb_advance_schedule()
      USB: fix LANGID=3D0 regression
      USB: serial: sierra driver id_table additions
      USB serial: Add ID for Turtelizer, an FT2232L-based JTAG/RS-232 ada=
pter.
      USB: fix race leading to a write after kfree in usbfs
      USB: Sierra: fix oops upon device close
      USB: option.c: add A-Link 3GU device id
      USB: Serial: Add support for Arkham Technology adapters
      USB: Fix option_ms regression in 2.6.31-rc2
      USB: gadget audio: select SND_PCM
      USB: ftdi: support NDI devices
      Revert USB: usbfs: deprecate and hide option for !embedded
      USB: usb.h: fix kernel-doc notation
      USB: RNDIS gadget, fix issues talking from PXA
      USB: serial: FTDI with product code FB80 and vendor id 0403
      ...

commit 8f8f013478133eb98e35e1d669c98c5e39d769c7
Author: Dave Kleikamp <shaggy-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Mon Jul 13 11:02:24 2009 -0500

    update JFS entry in MAINTAINERS
   =20
    JFS hasn't really been supported for a while.  It's still maintained,
    but saying it's supported is a stretch.  Updating my preferred email
    address as well.
   =20
    Signed-off-by: Dave Kleikamp <shaggy-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 5fddcdb70fd9e8fd52d42ed52a572fecb8eb7cde
Author: Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jul 13 15:09:25 2009 +0100

    mn10300: remove duplicated #include
   =20
    Remove duplicated #include('s) in
      arch/mn10300/kernel/sys_mn10300.c
   =20
    Signed-off-by: Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 1d03d2bd6e6421224d618b120348bd5ee328d96a
Author: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Date:   Mon Jul 13 12:39:05 2009 +0200

    Fix staging drivers after smp_lock.h redux
   =20
    Commit 405f55712dfe464b3240d7816cc4fe4174831be2 ("headers: smp_lock.h
    redux") broke the build of two staging drivers. Fix them.
   =20
    Signed-off-by: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
    Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 833576b362e15c38be3bfe43942cda693e56287c
Author: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date:   Mon Jul 13 09:45:52 2009 -0400

    ext4: Fix ext4_mb_initialize_context() to initialize all fields
   =20
    Pavel Roskin pointed out that kmemcheck indicated that
    ext4_mb_store_history() was accessing uninitialized values of
    ac->ac_tail and ac->ac_buddy leading to garbage in the mballoc
    history.  Fix this by initializing the entire structure to all zeros
    first.
   =20
    Also, two fields were getting doubly initialized by the caller of
    ext4_mb_initialize_context, so remove them for efficiency's sake.
   =20
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit ac046f1d6121ccdda6db66bd88acd52418f489b2
Author: Peng Tao <bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jul 13 09:30:17 2009 -0400

    ext4: fix null handler of ioctls in no journal mode
   =20
    The EXT4_IOC_GROUP_ADD and EXT4_IOC_GROUP_EXTEND ioctls should not
    flush the journal in no_journal mode.  Otherwise, running resize2fs o=
n
    a mounted no_journal partition triggers the following error messages:
   =20
    BUG: unable to handle kernel NULL pointer dereference at 00000014
    IP: [<c039d282>] _spin_lock+0x8/0x19
    *pde =3D 00000000
    Oops: 0002 [#1] SMP
   =20
    Signed-off-by: Peng Tao <bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit e6b5d30104db5f34110678ecab14988f1f1eff63
Author: Curt Wohlgemuth <curtw-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jul 13 09:07:20 2009 -0400

    ext4: Fix buffer head reference leak in no-journal mode
   =20
    We found a problem with buffer head reference leaks when using an ext=
4
    partition without a journal.  In particular, calls to ext4_forget() w=
ould
    not to a brelse() on the input buffer head, which will cause pages th=
ey
    belong to to not be reclaimable.
   =20
    Further investigation showed that all places where ext4_journal_forge=
t() and
    ext4_journal_revoke() are called are subject to the same problem.  Th=
e patch
    below changes __ext4_journal_forget/__ext4_journal_revoke to do an ex=
plicit
    release of the buffer head when the journal handle isn't valid.
   =20
    Signed-off-by: Curt Wohlgemuth <curtw-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit dc7520c17982ca4232233d2781e5cde29e58fbad
Author: Ajay Kumar Gupta <ajay.gupta-l0cyMroinI0@public.gmane.org>
Date:   Fri Jul 3 13:18:45 2009 +0530

    USB: otg: fix module reinsert issue
   =20
    Platform_device instance (pd) is not set to NULL in
    usb_nop_xceiv_unregister() causing usb_nop_xceiv_register()
    to fail during module reinsert.
   =20
    From: Ajay Kumar Gupta <ajay.gupta-l0cyMroinI0@public.gmane.org>
    Signed-off-by: Babu Ravi <ravibabu-l0cyMroinI0@public.gmane.org>
    Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

commit 9180135bc80ab11199d482b6111e23f74d65af4a
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Mon Jun 29 11:04:54 2009 -0400

    USB: handle zero-length usbfs submissions correctly
   =20
    This patch (as1262) fixes a bug in usbfs: It refuses to accept
    zero-length transfers, and it insists that the buffer pointer be vali=
d
    even if there is no data being transferred.
   =20
    The patch also consolidates a bunch of repetitive access_ok() checks
    into a single check, which incidentally fixes the lack of such a chec=
k
    for Isochronous URBs.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit ec6d67e39f5638c792eb7490bf32586ccb9d8005
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Mon Jun 29 14:34:59 2009 -0400

    USB: EHCI: report actual_length for iso transfers
   =20
    This patch (as1259b) makes ehci-hcd return the total number of bytes
    transferred in urb->actual_length for Isochronous transfers.
    Until now, the actual_length value was unaccountably left at 0.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit f092c240494f2d807401d93f95f683909b90af96
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Thu Jul 9 12:58:43 2009 -0400

    USB: option: remove unnecessary and erroneous code
   =20
    This patch (as1264) removes a bunch of unnecessary and erroneous stuf=
f
    from the option USB-serial driver.  Clearly there's no need to verify
    that the device pointer stored in the URBs is right or to store the
    same pointer over again.  After all, the pointer can't change once it
    has been set up.
   =20
    There's also no need to call usb_clear_halt for the IN endpoint
    multiple times -- in fact, doing so is an error since every time afte=
r
    the first there will be active URBs queued for that endpoint.  Since
    the Clear-Halts don't appear to be needed at all, the patch simply
    removes them.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 4d2fae8b3597bc787f1f1c06637ce5ab8187e5a7
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Thu Jul 9 12:59:57 2009 -0400

    USB: cypress_m8: remove invalid Clear-Halt
   =20
    This patch (as1265) removes an erroneous call to usb_clear_halt from
    the cypress_m8 driver.  The call isn't valid because it is made from
    interrupt context whereas usb_clear_halt is a blocking routine.
   =20
    Presumably the code has never been executed; if it did it would cause
    an oops.  So instead treat -EPIPE like any other sort of unexplained
    error.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 1fe975f9302e6c5a8f66401e305685396b2e4577
Author: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Date:   Fri Jul 10 20:02:44 2009 +0300

    USB: musb_host: undo incorrect change in musb_advance_schedule()
   =20
    Commit c9cd06b3d6ea825c62e277def929cc4315802b48 (musb_host: refactor
    URB giveback) included due to my overlook the change incorrect in the
    context of the current kernel -- undo it.
   =20
    Signed-off-by: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
    Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 0cce2eda19923e5e5ccc8b042dec5af87b3ffad0
Author: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Date:   Fri Jul 10 11:04:58 2009 +0200

    USB: fix LANGID=3D0 regression
   =20
    commit b7af0bb ("USB: allow malformed LANGID descriptors") broke supp=
ort
    for devices without string descriptor support.
   =20
    Reporting string descriptors is optional to USB devices, and a device
    lets us know it can't deal with strings by responding to the LANGID
    request with a STALL token.
   =20
    The kernel handled that correctly before b7af0bb came in, but failed
    hard if the LANGID was reported but broken. More than that, if a devi=
ce
    was not able to provide string descriptors, the LANGID was retrieved
    over and over again at each string read request.
   =20
    This patch changes the behaviour so that
   =20
     a) the LANGID is only queried once
     b) devices which can't handle string requests are not asked again
     c) devices with malformed LANGID values have a sane fallback to 0x04=
09
   =20
    Signed-off-by: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
    Acked-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit c5f3d87d61a116fdf2e4a2804d5e32cf8a4eeac7
Author: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Date:   Thu Jul 9 17:55:18 2009 -0700

    USB: serial: sierra driver id_table additions
   =20
    - Updated the id_table with all devices that Sierra Wireless currentl=
y
       support
     - Re-ordered the contents of the id_table for better readability
   =20
    Signed-off-by: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 145114125cf07afc91e5b132ec41c353284cdb2a
Author: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Date:   Fri Jul 10 01:06:23 2009 +0200

    USB serial: Add ID for Turtelizer, an FT2232L-based JTAG/RS-232 adapt=
er.
   =20
    Adds USB ID for Turtelizer, an FT2232L-based JTAG/RS-232 adapter.
   =20
    Signed-off-by: Krzysztof Ha=C2=B3asa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 516a1a07f0219d6672fb6b8e49fb9d5d533c2e89
Author: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 8 19:09:23 2009 +0200

    USB: fix race leading to a write after kfree in usbfs
   =20
    this fixes a race between async_completed() and proc_reapurbnonblock(=
).
   =20
    CPU A                   CPU B
   =20
    spin_lock(&ps->lock);
    list_move_tail(&as->asynclist, &ps->async_completed);
    spin_unlock(&ps->lock);
   =20
                                    if (!(as =3D async_getcompleted(ps)))
                                            return -EAGAIN;
                                    return processcompl(as, (void __user =
* __user *)arg);
   =20
    processcompl() calls free_async() which calls kfree(as)
   =20
    as->status =3D urb->status;
    if (as->signr) {
            sinfo.si_signo =3D as->signr;
            sinfo.si_errno =3D as->status;
            sinfo.si_code =3D SI_ASYNCIO;
            sinfo.si_addr =3D as->userurb;
            kill_pid_info_as_uid(as->signr, &sinfo, as->pid, as->uid,
                                  as->euid, as->secid);
    }
    snoop(&urb->dev->dev, "urb complete\n");
    snoop_urb(urb, as->userurb);
   =20
    write after kfree
   =20
    Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

commit 7bae0a070db4bc2761dd9515f450cdfa3f3f248c
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Tue Jul 7 09:50:14 2009 -0400

    USB: Sierra: fix oops upon device close
   =20
    This patch (as1263) fixes a mixup that occurred when conflicting
    patches for the sierra driver were merged incorrectly.  The former
    sierra_shutdown routine should have been become sierra_release, not
    sierra_disconnect.
   =20
    The symptom this fixes is an oops when the device file is closed afte=
r
    a Sierra device has been unplugged (Bugzilla #13675).
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Tested-by: Peter Naulls <peter-EMHrMXjtJHaTtA8H5PvdGFaTQe2KTcn/@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit c3325eb16d36a49f9a5ae09241c418cfd1d3f4f5
Author: Anssi Hannula <anssi.hannula-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jul 6 19:08:59 2009 +0300

    USB: option.c: add A-Link 3GU device id
   =20
    Add A-Link 3GU device id 1e0e:9200 into option driver. The device
    has 4 interfaces, of which 1 is handled by storage and the other 3
    by option driver.
   =20
    The device appears first as CD-only 1e0e:f000 device and must be
    switched to 1e0e:9200 mode either by using "eject CD" or
    usb_modeswitch.
   =20
    For the record, the device does not work with generic usbserial
    driver (usb disconnect when sending the ATDT command).
   =20
    Signed-off-by: Anssi Hannula <anssi.hannula-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 0601e116e30caf35520522cb621d05866663cab2
Author: Amit Kucheria <amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date:   Mon Jul 6 14:19:59 2009 +0300

    USB: Serial: Add support for Arkham Technology adapters
   =20
    As reported by David Potts from Arkham Technology, the current driver
    works with their hardware on addition of the device ids.
   =20
    Signed-off-by: Amit Kucheria <amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 2ab2178c3303583a0551f6b6bf4ba070afbf875f
Author: Jonathan McDowell <noodles-4QvXXjU8Dv4@public.gmane.org>
Date:   Sun Jul 5 12:29:51 2009 +0100

    USB: Fix option_ms regression in 2.6.31-rc2
   =20
    Commit 32ebbe7b6ad44ae9c276419710b56de6ba705303 which filters the
    SCSI REZERO command in option_ms based on a SCSI INQUIRY with a vendo=
r
    of Option breaks my Option Icon 225 (0af0:6971). This device returns =
a
    vendor of ZCOPTION for the ZeroCD device. The following trivial patch
    fixes things for me.
   =20
    Signed-Off-By: Jonathan McDowell <noodles-4QvXXjU8Dv4@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 04950737d6bed9d234483216ee36ed760d9404eb
Author: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jul 3 13:26:57 2009 -0700

    USB: gadget audio: select SND_PCM
   =20
    Fix USB gadget audio: select SND_PCM, like many other sound
    drivers do, to fix build errors:
   =20
    drivers/built-in.o: In function `f_audio_playback_work':
    audio.c:(.text+0x15a3e7): undefined reference to `snd_pcm_kernel_ioct=
l'
    audio.c:(.text+0x15a471): undefined reference to `snd_pcm_lib_write'
    drivers/built-in.o: In function `_snd_pcm_hw_param_set':
    audio.c:(.text+0x15aca7): undefined reference to `snd_interval_refine=
'
    drivers/built-in.o: In function `gaudio_setup':
    (.init.text+0x12adf): undefined reference to `_snd_pcm_hw_params_any'
    drivers/built-in.o: In function `gaudio_setup':
    (.init.text+0x12b43): undefined reference to `snd_pcm_kernel_ioctl'
   =20
    Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit b760dac290c3482e6883d5f79a2357c82239a3ff
Author: Martin Geleynse <mgeleyns-gAp4TUuleF9Wk0Htik3J/w@public.gmane.org>
Date:   Thu Jul 2 13:10:35 2009 -0400

    USB: ftdi: support NDI devices
   =20
    It enhances the driver for FTDI-based USB serial adapters to recogniz=
e and
    support Northern Digital Inc (NDI) measurement equipment. NDI has bee=
n
    providing this patch for various kernel flavors for several years and=
 we would
    like to see these changes built in to the driver so that our equipeme=
nt works
    without the need for customers to patch the kernel themselves.
   =20
    The patch makes small modifications to 2 files: ./drivers/usb/serial/=
ftdi_sio.c
    and ./drivers/usb/serial/ftdi_sio.h. It accomplishes 3 things:
   =20
    1. Define the VID and PIDs to allow the driver to recognize the NDI d=
evices.
    2. Map the 19200 baud rate setting to our higher baud rate of 1.2Mb
       We would have chosen to map 38400 to the higher rate, similar to w=
hat
       several other vendors have done, but some of our legacy customers =
actually
       use 38400, therefore we remap 19200 to the higher rate.
    3. We set the default transmit latency in the FTDI chip to 1ms for ou=
r devices.
       Our devices are typically polled at 60Hz and the default ftdi late=
ncy
       seriously affects turn-around time and results in missed data fram=
es. We
       have created a modprobe option that allows this setting to be incr=
eased.
       This has proven necessary particularly in some virtualized environ=
ments.
   =20
    Signed-off-by: Martin P. Geleynse <mgeleyns-gAp4TUuleF9Wk0Htik3J/w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit e12df02a171d1c10ee664e6571c0e4cb7e1b7c92
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Thu Jul 9 21:35:49 2009 -0700

    Revert USB: usbfs: deprecate and hide option for !embedded
   =20
    This reverts commit cc71329b3b89b4a5be849b617f2c4f151f0b9213, so that
    Red Hat machines can boot properly.  It seems that the Red Hat initrd
    code tries to watch the /proc/bus/usb/devices file to monitor usb
    devices showing up.  While this task is prone to lots of races and do=
es
    not show the true state of the system, they seem to like it.
   =20
    So for now, don't move this option under the EMBEDDED config option.
   =20
   =20
    Cc: Scott James Remnant <scott-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
    Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
    Cc: Dave Airlie <airlied-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Jones <pjones-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit e376bbbb6a82cf119c93bde66937f66c72cba27b
Author: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jun 18 10:39:11 2009 -0700

    USB: usb.h: fix kernel-doc notation
   =20
    Fix usb.h kernel-doc warnings:
   =20
    Warning(include/linux/usb.h:918): Excess struct/union/enum/typedef me=
mber 'nodename' description in 'usb_device_driver'
    Warning(include/linux/usb.h:939): No description found for parameter =
'nodename'
    Warning(include/linux/usb.h:1219): No description found for parameter=
 'sg'
    Warning(include/linux/usb.h:1219): No description found for parameter=
 'num_sgs'
   =20
    Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 4e19f220d4e84f5728cb7edde36352ab425cfba4
Author: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date:   Fri Jun 19 03:09:04 2009 -0700

    USB: RNDIS gadget, fix issues talking from PXA
   =20
    The reworked Ethernet gadget has an RNDIS interop problem when used
    with the CDC subset driver ... e.g. on PXA 2xx and 3xx hardware,
    which currently has a hard time talking to MS-Windows hosts.
   =20
    The issue is that Microsoft requires USB_CLASS_COMM.  Fix by tweaking
    the CDC subset driver to not switch to USB_CLASS_VENDOR_SPEC if RNDIS
    is used in some other device configuration.
   =20
    [ UPDATED:  some "statements" were comma-terminated; fix that. ]
   =20
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Cc: Aric Blumer <aric-9nEMHBxvMEgjHdulDSg1yw@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit b34efeeab84e0887b30fee101612a72786ddced2
Author: Folkert van Heusden <folkert-Beo89p9qyDM6GGFevw1D/A@public.gmane.org>
Date:   Fri Jun 19 22:14:42 2009 +0200

    USB: serial: FTDI with product code FB80 and vendor id 0403
   =20
    It seems an USB device with vendor id 0403 and product code FB80 has =
an
    FTDI serial io chip as well: http://ftdichip.com/Drivers/D2XX.htm
    This device in fact is a true random generantor by comsci:
    http://comscire.com/Products/R2000KU/
    So the following patch should add support for this device if I am
    correct. Not tested as I do not own this device (I would like support=
 in
    the kernel so that my entropybroker application (which distributes
    entrop data (random values) between servers and clients)).
   =20
   =20
    From: Folkert van Heusden <folkert-Beo89p9qyDM6GGFevw1D/A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 6e4061210150d1d6d388c5fba05f6b49a306a27e
Author: Jason Wessel <jason.wessel-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Date:   Mon Jun 22 11:32:20 2009 -0500

    USB: console: Fix regression in usb console on kernel boot
   =20
    The commit 335f8514f200e63d689113d29cb7253a5c282967 introduced a
    regression which stopped usb consoles from working correctly as a
    kernel boot console as well as interactive login device.
   =20
    The addition of the serial_close() which in turn calls
    tty_port_close_start() will change the reference count of port.count
    and warn about it.  The usb console code had previously incremented
    the port.count to indicate it was making use of the device as a
    console and the forced change causes a double open on the usb device
    which leads to a non obvious kernel oops later on when the tty is
    freed.
   =20
    To fix the problem instead make use of port->console to track if the
    port is in fact an active console port to avoid double initialization
    of the usb serial device.  The port.count is incremented and
    decremented only with in the scope of usb_console_setup() for the
    purpose of the low level driver initialization.
   =20
    Signed-off-by: Jason Wessel <jason.wessel-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
    Acked-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit bf7fbb022f0a3da27a2bcf8d7c973c813d942384
Author: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date:   Fri Jun 26 16:10:19 2009 +0200

    USB: add missing class descriptions used in usb/devices file
   =20
    Added descriptions (for WIRELESS_CONTROLLER and MISC) were taken from
    the usb-devices script now included in usbutils.
   =20
    Also sort the classes in the same order as in include/linux/usb/ch9.h
    for easier comparison for future updates.
   =20
    Signed-off-by: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit d794a02111cd3393da69bc7d6dd2b6074bd037cc
Author: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date:   Sun Jun 28 23:34:14 2009 +0200

    USB: fix memleak in usbfs
   =20
    This patch fixes a memory leak in devio.c::processcompl
   =20
    If writing to user space fails the packet must be discarded, as it
    already has been removed from the queue of completed packets.
   =20
    Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit ba516de332c0e574457e58fb5aa0293e628b7b10
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Mon Jun 29 17:36:14 2009 -0400

    USB: EHCI: check for STALL before other errors
   =20
    This patch (as1257) revises the way ehci-hcd detects STALLs.  The
    logic is a little peculiar because there's no hardware status bit
    specifically meant to indicate a STALL.  You just have to guess that =
a
    STALL was received if the BABBLE bit (which is fatal) isn't set and
    the transfer stopped before all its retries were used up.
   =20
    The existing code doesn't do this properly, because it tests for MMF
    (Missed MicroFrame) and DBE (Data Buffer Error) before testing the
    retry counter.  Thus, if a transaction gets either MMF or DBE the
    corresponding flag is set and the transaction is retried.  If the
    second attempt receives a STALL then -EPIPE is the correct return
    value.  But the existing code would see the MMF or DBE flag instead
    and return -EPROTO, -ENOSR, or -ECOMM.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 914b701280a76f96890ad63eb0fa99bf204b961c
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Mon Jun 29 10:47:30 2009 -0400

    USB: EHCI: use the new clear_tt_buffer interface
   =20
    This patch (as1256) changes ehci-hcd and all the other drivers in the
    EHCI family to make use of the new clear_tt_buffer callbacks.  When a
    Clear-TT-Buffer request is in progress for a QH, the QH is not allowe=
d
    to be linked into the async schedule until the request is finished.
    At that time, if there are any URBs queued for the QH, it is linked
    into the async schedule.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit cb88a1b887bb8908f6e00ce29e893ea52b074940
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Mon Jun 29 10:43:32 2009 -0400

    USB: fix the clear_tt_buffer interface
   =20
    This patch (as1255) updates the interface for calling
    usb_hub_clear_tt_buffer().  Even the name of the function is changed!
   =20
    When an async URB (i.e., Control or Bulk) going through a high-speed
    hub to a non-high-speed device is cancelled or fails, the hub's
    Transaction Translator buffer may be left busy still trying to
    complete the transaction.  The buffer has to be cleared; that's what
    usb_hub_clear_tt_buffer() does.
   =20
    It isn't safe to send any more URBs to the same endpoint until the TT
    buffer is fully clear.  Therefore the HCD needs to be told when the
    Clear-TT-Buffer request has finished.  This patch adds a callback
    method to struct hc_driver for that purpose, and makes the hub driver
    invoke the callback at the proper time.
   =20
    The patch also changes a couple of names; "hub_tt_kevent" and
    "tt.kevent" now look rather antiquated.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 87ea8c887905d8b13ae90b537117592ed027632a
Author: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date:   Tue Jun 30 09:44:24 2009 +0200

    USB: fix uninitialised variable in ti_do_download
   =20
    Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 71f9f6cc9eef47fddc05f34b3d32677ab2e0f1fa
Author: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jun 30 16:09:28 2009 -0400

    USB: option: add Novatel Ovation MC760
   =20
    Used by Virgin Mobile with the Broadband2Go service, for example.
   =20
    Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 5186ffee2320942c3dc9745f7930e0eb15329ca6
Author: Arseniy Lartsev <ars3n-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>
Date:   Wed Jul 1 16:27:26 2009 +0400

    USB: cdc-acm: work around some broken devices
   =20
    This patch introduces a work around for cdc-acm devices which are
    low speed contrary to the specification, which requires bulk endpoint=
s
    which are banned in low speed and converted by usbcore to virtual
    interrupt endpoints if they are used nevertheless.
   =20
    Signed-off-by: Arseniy Lartsev <ars3n-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>
    Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 89368d3d11a5b2eff83ad8e752be67f77a372bad
Author: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date:   Wed Jul 1 03:36:16 2009 -0700

    USB: musb: silence "suspend as a_wait_vrise is_active" msgs
   =20
    Get rid of some obnoxious and inappropriate messaging, mostly on
    DaVinci, when usbcore tries to autosuspend a root hub if just a
    mini/micro-A connector is connected.  Symptom: endless stream of
    messages reading like:
   =20
     musb_bus_suspend 2221: trying to suspend as a_wait_vrise is_active=3D=
1
   =20
    Improve that musb bus suspend primitive a bit.  Take advantage of
    this call to update the OTG state machine if appropriate, moving
    the device out of the A_WAIT_VRISE state.  There's basically no
    timer for that state transition just now, except with tusb6010;
    that can make trouble.
   =20
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 6d84599b3c3a7bccc04ec4133220d150b92fe0f8
Author: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date:   Wed Jul 1 03:43:58 2009 -0700

    USB: gadget: pxa25x compiler warning fix
   =20
    Fix config-dependent compiler warning:
   =20
      CC      drivers/usb/gadget/pxa25x_udc.o
    drivers/usb/gadget/pxa25x_udc.c: In function 'pxa25x_udc_irq':
    drivers/usb/gadget/pxa25x_udc.c:1806: warning: array subscript is abo=
ve array bounds
   =20
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 56a075dcd64b25c828af1752dff0ac1e6833e135
Author: Philipp Zabel <philipp.zabel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 03:42:45 2009 -0700

    USB: gadget: pxa25x uses gpio_is_valid
   =20
    Use gpio_is_valid instead of assuming that every GPIO
    number !=3D 0 is valid while 0 is not.
   =20
    Signed-off-by: Philipp Zabel <philipp.zabel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Acked-by: Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 30899ca7f20571c4bd64544dec261171f6ec255b
Author: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>
Date:   Wed Jul 1 03:33:46 2009 -0700

    USB: musb: davinci dm6446evm GPIO renumbering
   =20
    Numbering for GPIOs on the pcf857x chips on the dm644x EVM board
    changed when DaVinci chips with more GPIOs were supported.  Update
    the GPIO number used for nVBUS_DRV.
   =20
    Longer term, we need a better abstraction of board-specific setup in
    this code so we're not hard-coding board specific GPIOs into the
    driver, but for now this at least gets it back to working with
    mainline davinci core code.
   =20
    Signed-off-by: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit d163ef248385fc434e44b04a5151ae5d6a6c2d16
Author: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date:   Wed Jul 1 03:32:43 2009 -0700

    USB: musb: davinci dm355 updates (remainder)
   =20
    Finish merging updates for DM355 chips into musb/davinci.c now
    that its support is in mainline:  kick in new DRVVBUS controls.
   =20
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 6bc2146e2b01654534a1cae127ef96bf4b5f3d53
Author: Qiuping Chen <cqiuping-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 03:49:29 2009 -0700

    USB: gadget: rndis conformance tweak
   =20
    Support OID_802_3_MAC_OPTIONS in gen_ndis_query_resp() of rndis.c to
    make RNDIS gadget pass 1c_SetMulticast subtest in Microsoft NDISTest6=
:
   =20
      http://www.microsoft.com/whdc/DevTools/tools/NDIStest.mspx
   =20
    The other tests in NDISTest6 are passed.
   =20
    [ dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org: remove OID_802_3_MAXIMUM_LIST_SIZE
    setting ... it was bogus, this code only handles one entry, not 32.
    And we don't know what would break if we lied about that... ]
   =20
    Signed-off-by: Helen Chen <helen.chen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit ca157c4a51fa6209f28c316f4a63d594adb79518
Author: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date:   Thu Jul 2 16:41:39 2009 +0200

    USB: fix memory leak in usbtmc
   =20
    If an error is returned kfree must also be called.
   =20
   =20
    Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 45e83889eb291714d3a4727e98e2488074affbf8
Author: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date:   Fri Jun 19 05:35:34 2009 -0700

    USB: buildfix ppc randconfig
   =20
    We could just make the USB_OHCI_HCD_PPC_OF option implicit
    and selected only if at least one of USB_OHCI_HCD_PPC_OF_BE
    and USB_OHCI_HCD_PPC_OF_LE are set.
   =20
    [ dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org: fix patch manglation and dependenc=
ies ]
   =20
    Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    Tested-by: Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 3c43f27bf57b0502df2478253699559ee1d43f6d
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Fri Jun 26 08:05:20 2009 -0700

    USB: ti_usb_3410_5052: fix duplicate device ids.
   =20
    commit 1a1fab513734b3a4fca1bee8229e5ff7e1cb873c accidentally added th=
e
    device id to both tables in the driver, which causes problems as this=
 is
    only a single port device, not a multiple port device.
   =20
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 05cbc2d58224d01925bfb93a0c3f0ab1f11b1eea
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Tue Jun 23 16:01:06 2009 -0700

    USB: gadget: audio: provide correct device id
   =20
    The audio gadget driver should use a "Linux" device id, instead
    of relying on NetChip's vendor id.  So provide one out of our reserve=
d
    namespace.
   =20
    Cc: Bryan Wu <cooloney-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
    Cc: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 1a74826fa1cd6c2e382f927403b4440675f0f55a
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Tue Jun 23 15:58:48 2009 -0700

    Revert "USB: Add Intel Langwell USB OTG Transceiver Drive"
   =20
    This reverts commit 453f77558810ffa669ed5a510a7173ec49def396.
   =20
    The driver should not have been accepted as the MSRT code is not
    in the main kernel yet, which this depends on.
   =20
    Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
    Cc: Hao Wu <hao.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit e3a3174519bae99fe3a3d3b9dfda68d820527b44
Author: Brad Lu <Brad.Lu-3WR8VGTduzwAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 16 18:04:00 2009 +0800

    USB: option.c to support Qisda H21/H20 usb modem
   =20
    This patch added Qisda(VID) & H21/H20(PID) into to supporting list.
    Please help to check this patch,
   =20
    From: Brad Lu <Brad.Lu-3WR8VGTduzwAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 83dfdaa362fd9f1ed8bfa0bba50fff08c063380b
Author: Kai Engert <kaie-u67sJGAGMvU@public.gmane.org>
Date:   Fri Jun 12 08:51:37 2009 +0200

    USB: option.c: add Qualcomm/Option iCON 210 modem
   =20
    Add modem portion of USB device labeled:
    Model iCON 210, Qualcomm 3G HSDPA, designed in EU by Option
   =20
    Device starts in usb-storage mode (1e0e:f000) and requires the use of=
 a tool
    like usb_modeswitch to switch it to modem mode (1e0e:9000).
   =20
    Signed-off-by: Kai Engert <kaie-u67sJGAGMvU@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 4198e4f7e0b756d8a847e408b0017495833538b3
Author: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date:   Thu Jun 11 21:59:00 2009 -0400

    USB: isp1760: use __devexit_p() for remove function
   =20
    The isp1760_plat_remove function is declared with __devexit, so the
    .remove assignment needs to be wrapped with __devexit_p().
   =20
    Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit a455212d19d312f6a99b3a4a86fb79fb91dd76c7
Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date:   Thu Jun 11 14:56:22 2009 -0400

    USB: EHCI: update toggle state for linked QHs
   =20
    This is an update to the "usb-ehci-update-toggle-state-for-linked-qhs=
"
    patch.  Since an HCD's endpoint_reset method can be called in
    interrupt context, it mustn't assume that interrupts are enabled or
    that it can sleep.
   =20
    So we revert to the original way of refreshing QHs' toggle bits.  Now
    the endpoint_reset method merely clears the toggle flag in the device
    structure (as was done before) and starts an async QH unlink.  When t=
he
    QH is linked again, after the unlink finishes and an URB is queued,
    the qh_refresh() routine will update the QH's toggle bit.
   =20
    Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
    Tested-by: David <david-Os2QIKb4eqJd3aXB8m+yKQ@public.gmane.org>
    CC: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 9525dcb30f5f412748f58a0537002ea47cfe55de
Author: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jun 10 12:57:35 2009 -0700

    USB: fhci: mutually exclusive port_status
   =20
    FHCI_PORT_DISABLED, -LOW and -FULL are mutually exclusive as status.
   =20
    Signed-off-by: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Anton Vorontsov <avorontsov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 9d37ff64567f852a222c78e7d13037bb02395dc7
Author: Jan Capek <jan-PhPSB1nt40FBDgjK7y7TUQ@public.gmane.org>
Date:   Wed Jun 10 18:58:52 2009 +0200

    USB: ftdi_sio - product ID's for CCS PIC programmers
   =20
    The product ID's for the following devices have been added:
    - LOAD-n-GO
    - ICD-U64
    - PRIME-8
   =20
    Signed-off-by: Jan Capek <jan-PhPSB1nt40FBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit c03e7d4bc1c39ae74a5e9f7bd7e9fd12898e42b8
Author: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Date:   Tue Jun 9 11:11:16 2009 +0300

    USB: gadget: fix imx_udc entry in Kconfig
   =20
    Move USB_GADGET_IMX to the right section of Kconfig as this
    controller is available only as integrated on i.MX CPU.
   =20
    Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 8540d66615c39010168ab97eaafb476ec2851298
Author: Gianpaolo Cugola <gianpaoloc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jun 5 22:57:52 2009 +0200

    USB: pl2303: New vendor and product id for the prolific driver
   =20
    I recently bought a PC interface for the Cressi Edy dive computer
    (www.cressi.it) and discovered that it uses the pl2303 chip, albeit
    with ad-hoc vendor and product ids (04b8, 0521 respectively). Being i=
n
    the process of writing a linux software for such device (cressi only
    provides a windows software), I patched the pl2303 linux driver to
    have the interface recognized. I am submitting you the patch (very
    basic) for inclusion in next kernel version.
   =20
    From: Gianpaolo Cugola <gianpaoloc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit f6387184f5196242edecbb5385bcc3481fae212a
Author: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sat Jun 20 20:58:33 2009 +0400

    Staging: stlc45xx: convert config_interface to bss_info_changed, fixi=
ng a build error
   =20
    See commit 2d0ddec5b2b (mac80211: unify config_interface and
    bss_info_changed)
   =20
    This fixes a build error.
   =20
    Signed-off-by: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 8231eb5672e7a020174eb7ce0436766eea57cae8
Author: Herton Ronaldo Krzesinski <herton-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org>
Date:   Thu Jun 18 14:43:56 2009 -0300

    Staging: comedi: s626: use subvendor:subdevice ids for SAA7146 board
   =20
    The current s626 comedi driver in staging conflicts with philips SAA7=
146
    media/dvb based cards, because it claims the same vendor:device pci i=
d
    for all subdevice/subvendor ids. What happens is that for people that=
 have a
    philips SAA7146 media/dvb based card, s626 if available gets loaded b=
y udev
    and makes system freeze (https://qa.mandriva.com/show_bug.cgi?id=3D51=
445).
   =20
    The s626 driver shouldn't claim all 1131:7146 devices. Fix this by
    specifying specific known subvendor:subdevice ids in its pci id table
    list.
   =20
    Also s626_attach is modified to use now pci_get_subsys instead of
    pci_get_device as reported by Ian Abbott, and now we loop over pci id
    table entries in case more ids are added in the future.
   =20
    Reference: http://lkml.org/lkml/2009/6/16/552
   =20
    Signed-off-by: Herton Ronaldo Krzesinski <herton-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org>
    Signed-off-by: Ian Abbott <abbotti-GUHe90Wt2aFaa/9Udqfwiw@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 91fca6da389b897483b4c1edea29885172989fda
Author: Dan Aloni <dan-d+gUaqY2BZ/YtjvyW6yDsg@public.gmane.org>
Date:   Wed Jun 24 22:34:39 2009 +0300

    Staging: prevent rtl8192su from crashing dev_ioctl in SIOCGIWNAME
   =20
    (adapted from the rtl8187se patch)
   =20
    ieee80211_wx_get_name() ignores sizeof(wrqu->name) which is IFNAMSIZ =
(16), and
    on certain conditions, the concatenated string will be larger than IF=
NAMSIZ
    including the terminating zero.
   =20
        length ("802.11" ++ "b" ++ "/g" ++ " linked" ++ "\x00") =3D=3D 17
   =20
    This fix uses strl{cpy,cat} in addition to the reduction of the total
    possible length of the output string by a char.
   =20
    It can be applied to 2.6.30-stable as well.
   =20
    Signed-off-by: Dan Aloni <dan-d+gUaqY2BZ/YtjvyW6yDsg@public.gmane.org>
    Cc: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 02c8baecf5d8850dba40b47cdf003ed2e04e66dd
Author: Dan Aloni <dan-d+gUaqY2BZ/YtjvyW6yDsg@public.gmane.org>
Date:   Sat Jun 20 16:32:22 2009 +0300

    Staging: prevent rtl8187se from crashing dev_ioctl() in SIOCGIWNAME
   =20
    I repeatedly get __stack_chk_fail panic()s with this driver before
    applying the attached fix.
   =20
    ieee80211_wx_get_name() ignores sizeof(wrqu->name) which is IFNAMSIZ =
(16), and
    on certain conditions, the concatenated string will be larger than IF=
NAMSIZ
    including the terminating zero.
   =20
        length ("802.11" ++ "b" ++ "/g" ++ " linked" ++ "\x00") =3D=3D 17
   =20
    This fix uses strl{cpy,cat} in addition to the reduction of the total
    possible length of the output string by a char.
   =20
    It can be applied to 2.6.30-stable as well.
   =20
    Signed-off-by: Dan Aloni <dan-d+gUaqY2BZ/YtjvyW6yDsg@public.gmane.org>
    Cc: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 77b9288197b6034c44abe2619aff62cba056a713
Author: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jun 11 20:49:07 2009 +0200

    Staging: rtl8192su: convert to net_device_ops
   =20
    commit e3804cbebb67887879102925961d41b503f7fbe3 removed
    COMPAT_NET_DEV_OPS so this change is needed to make rtl8192su
    buildable again.
   =20
    Loosely based on Alexander's patch for rtl8187se, untested.
   =20
    Cc: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
    Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 35e2bed559ab80641f1764aae570d92711ddc2fa
Author: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Date:   Fri Jun 19 12:32:57 2009 -0400

    Staging: serqt_usb2: declare qt_open static in serqt_usb2
   =20
    Signed-off-by: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit d9dea3c1c0814a87cc579b425e9776b8ed46b31f
Author: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Date:   Fri Jun 19 12:32:56 2009 -0400

    Staging: serqt_usb2: fix qt_close parameters in serqt_usb2
   =20
    The parameter list for qt_close() was from the old non usb-serial
    driver.
   =20
    Signed-off-by: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 9b5de0a0a79111445d99ff7e4c6c1125523f84df
Author: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sat Jun 20 03:52:47 2009 +0400

    Staging: comedi: jr3_pci.c: add required includes
   =20
    Fix this build errors:
    jr3_pci.c:739: error: 'jiffies' undeclared
    jr3_pci.c:748: error: implicit declaration of function 'msecs_to_jiff=
ies'
    jr3_pci.c:763: error: implicit declaration of function 'add_timer'
    jr3_pci.c:790: error: implicit declaration of function 'init_timer'
    jr3_pci.c:951: error: implicit declaration of function 'del_timer_syn=
c'
   =20
    Signed-off-by: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit e5a85d2179d0150688c1c4343c3c1b4a71bf6588
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Thu Jul 2 12:55:39 2009 -0700

    Staging: meilhaus: add email address to TODO
   =20
    Meilhaus Support also wants to be notified of changes to these driver=
s.
   =20
    Cc: David Kiliani <mail-ND2lqcohme/+pdyxiE32tQ@public.gmane.org>
    Cc: Meilhaus Support <support-iADwEBOWYzgb1SvskN2V4Q@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit aea0d43bdec32cc4a7ba53d6c82616de3964357a
Author: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jun 10 14:44:14 2009 -0600

    Staging: rspiusb: use NULL virtual address instead of a bogus one
   =20
    The main problem here is that I just cannot see how this could ever
    be correct:
   =20
    	usb_fill_bulk_urb(pdx->PixelUrb[frameInfo][i], pdx->udev, epAddr,
    		(dma_addr_t *) sg_dma_address(&pdx->sgl[frameInfo][i]),
     		sg_dma_len(&pdx->sgl[frameInfo][i]),
   =20
    You cannot take a DMA address, cast it to a _pointer to_ a DMA addres=
s,
    and then regard it as a virtual address of the transfer buffer.
    However, finding the right virtual address was too hard for me,
    so I just stubbed it with NULL. At least usbmon won't oops then
    (it will not show any data but it's better than crashing).
   =20
    Also, too big a buffer was allocated elsewhere.
   =20
    And since we're at it, drop clearly unnecessary usb_buffer_alloc too,
    leaving it where it may be useful.
   =20
    Signed-off-by: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit f408adeb517e1b17102acd889251d5ab60c1fb88
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Wed Jun 10 17:30:49 2009 +0100

    Staging: vt6655: compile fix
   =20
    At least make it compile
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 8dfb00571819ce491ce1760523d50e85bcd2185f
Author: Jorrit Schippers <jorrit-iT/DFEmSbIo@public.gmane.org>
Date:   Wed Jun 10 15:34:26 2009 +0200

    Staging: rt2870: Add USB ID for Sitecom WL-608
   =20
    Add the USB id 0x0DF6,0x003F to the rt2870.h file such that the
    Sitecom WL-608 device will be recognized by this driver.
   =20
    Signed-off-by: Jorrit Schippers <jorrit-iT/DFEmSbIo@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 38c7dc373029e4666b17850054dd43c1c96bb264
Author: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 23 17:50:06 2009 +0400

    wm97xx_batery: replace driver_data with dev_get_drvdata()
   =20
    direct access of driver_data is going away.
   =20
    Signed-off-by: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 5e9a8bd65761bf0c1ee26d8514ef3e9ff22ee465
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Tue Jun 23 08:31:46 2009 -0700

    omap: video: remove direct access of driver_data
   =20
    dev_set/get_drvdata() should be used instead, as driver_data is going
    away.
   =20
   =20
    Cc: Imre Deak <imre.deak-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Cc: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Acked-by: Trilok Soni <soni.trilok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
    Cc: Felipe Contreras <felipe.contreras-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 864e1e8db436dfd784340d0aef18ea303d157bcb
Author: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Date:   Mon Jun 22 15:46:03 2009 -0700

    Sound: remove direct access of driver_data
   =20
    This is the last in-kernel direct usage of driver_data, replace it wi=
th
    the proper dev_get/set_drvdata() calls.
   =20
    Cc: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
    Cc: Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>
    Acked-by: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
    Cc: Liam Girdwood <lrg-kDsPt+C1G03kYMGBc/C6ZA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 909662e1e7290945fa3bca038bc3b7bb5d19499f
Author: vibi sreenivasan <vibi_sreenivasan-1oWR3GQwFxs@public.gmane.org>
Date:   Wed Jul 8 15:37:03 2009 -0700

    driver model: fix show/store prototypes in doc.
   =20
    FIX prototypes for show & store method in struct driver_attribute
   =20
    Signed-off-by: vibi sreenivasan <vibi_sreenivasan-1oWR3GQwFxs@public.gmane.org>
    Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 308975fa7ab2a8e0b91186158128668c823790ce
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 21 23:57:31 2009 +0200

    Firmware: firmware_class, fix lock imbalance
   =20
    Add omitted unlock in firmware_data_read.
   =20
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 4ead0a2b6b3aa0b527871ec978c3ef12aafb6bfb
Author: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Date:   Thu Jul 2 23:25:44 2009 +0200

    Driver Core: remove BUS_ID_SIZE
   =20
    The name size limit is gone from the driver-core, this is
    the removal of the last left-over.
   =20
    Signed-off-by: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 08f42877aff6b966a386c47e0aeb98e7645db2a9
Author: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Date:   Thu Jul 2 23:27:22 2009 +0200

    sparc: remove driver-core BUS_ID_SIZE
   =20
    The name size limit is gone from the driver-core, the BUS_ID_SIZE
    value will be removed.
   =20
    Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
    Signed-off-by: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit f8c73c790c588fd70fda1632c8927a87b3d31dcd
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jun 11 15:14:40 2009 +0200

    partitions: fix broken uevent_suppress conversion
   =20
    git commit f67f129e "Driver core: implement uevent suppress in kobjec=
t"
    contains this chunk for fs/partitions/check.c:
   =20
     	/* suppress uevent if the disk supresses it */
    -	if (!ddev->uevent_suppress)
    +	if (!dev_get_uevent_suppress(pdev))
     		kobject_uevent(&pdev->kobj, KOBJ_ADD);
   =20
    However that should have been
   =20
    -	if (!ddev->uevent_suppress)
    +	if (!dev_get_uevent_suppress(ddev))
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Acked-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit eb8d3c604fe7496323efb9a858bef84c489ca584
Author: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date:   Wed Jun 10 12:43:02 2009 -0700

    devres: WARN() and return, don't crash on device_del() of uninitializ=
ed device
   =20
    I just debugged an obscure crash caused by a device_del() of a all NU=
LL'd
    out struct device (in usb-serial) and found that a patch like this on=
e would
    have saved me time (in addition to improved chances of a bug report f=
rom
    users hitting similar driver bugs).
   =20
    [akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org: cleanup]
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
    Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
    Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

commit 7638d5322bd89d49e013a03fe2afaeb6d214fabd
Merge: dd0d9a46f573b086a67522f819566427dba9c4c7 264ef8a904943ed7d0b04fa95=
8894d7a5c2b2c61
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Sun Jul 12 12:24:35 2009 -0700

    Merge branch 'kmemleak' of git://linux-arm.org/linux-2.6
   =20
    * 'kmemleak' of git://linux-arm.org/linux-2.6:
      kmemleak: Remove alloc_bootmem annotations introduced in the past
      kmemleak: Add callbacks to the bootmem allocator
      kmemleak: Allow partial freeing of memory blocks
      kmemleak: Trace the kmalloc_large* functions in slub
      kmemleak: Scan objects allocated during a scanning episode
      kmemleak: Do not acquire scan_mutex in kmemleak_open()
      kmemleak: Remove the reported leaks number limitation
      kmemleak: Add more cond_resched() calls in the scanning thread
      kmemleak: Renice the scanning thread to +10

commit dd0d9a46f573b086a67522f819566427dba9c4c7
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 9 10:44:30 2009 +0100

    AFS: Fix compilation warning
   =20
    Fix the following warning:
   =20
      fs/afs/dir.c: In function 'afs_d_revalidate':
      fs/afs/dir.c:567: warning: 'fid.vnode' may be used uninitialized in=
 this function
      fs/afs/dir.c:567: warning: 'fid.unique' may be used uninitialized i=
n this function
   =20
    by marking the 'fid' variable as an uninitialized_var.  The problem i=
s
    that gcc doesn't always manage to work out that fid is always set on =
the
    path through the function that uses it.
   =20
    Cc: linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
    Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 405f55712dfe464b3240d7816cc4fe4174831be2
Author: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 11 22:08:37 2009 +0400

    headers: smp_lock.h redux
   =20
    * Remove smp_lock.h from files which don't need it (including some he=
aders!)
    * Add smp_lock.h to files which do need it
    * Make smp_lock.h include conditional in hardirq.h
      It's needed only for one kernel_locked() usage which is under CONFI=
G_PREEMPT
   =20
      This will make hardirq.h inclusion cheaper for every PREEMPT=3Dn co=
nfig
      (which includes allmodconfig/allyesconfig, BTW)
   =20
    Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit f9fabcb58a6d26d6efde842d1703ac7cfa9427b6
Author: Julien Tinnes <jt-v4mm1dehULI@public.gmane.org>
Date:   Fri Jun 26 20:27:40 2009 +0200

    personality: fix PER_CLEAR_ON_SETID
   =20
    We have found that the current PER_CLEAR_ON_SETID mask on Linux doesn=
't
    include neither ADDR_COMPAT_LAYOUT, nor MMAP_PAGE_ZERO.
   =20
    The current mask is READ_IMPLIES_EXEC|ADDR_NO_RANDOMIZE.
   =20
    We believe it is important to add MMAP_PAGE_ZERO, because by using th=
is
    personality it is possible to have the first page mapped inside a
    process running as setuid root.  This could be used in those scenario=
s:
   =20
     - Exploiting a NULL pointer dereference issue in a setuid root binar=
y
     - Bypassing the mmap_min_addr restrictions of the Linux kernel: by
       running a setuid binary that would drop privileges before giving u=
s
       control back (for instance by loading a user-supplied library), we
       could get the first page mapped in a process we control.  By furth=
er
       using mremap and mprotect on this mapping, we can then completely
       bypass the mmap_min_addr restrictions.
   =20
    Less importantly, we believe ADDR_COMPAT_LAYOUT should also be added
    since on x86 32bits it will in practice disable most of the address
    space layout randomization (only the stack will remain randomized).
   =20
    Signed-off-by: Julien Tinnes <jt-v4mm1dehULI@public.gmane.org>
    Signed-off-by: Tavis Ormandy <taviso-VThn6mlTRQFChFL4AGkBsw@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
    Acked-by: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Acked-by: Kees Cook <kees-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
    Acked-by: Eugene Teo <eugene-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    [ Shortened lines and fixed whitespace as per Christophs' suggestion =
]
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit a137802ee839ace40079bebde24cfb416f73208a
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Sun Jul 12 11:25:04 2009 -0700

    Don't use '-fwrapv' compiler option: it's buggy in gcc-4.1.x
   =20
    This causes kernel images that don't run init to completion with cert=
ain
    broken gcc versions.
   =20
    This fixes kernel bugzilla entry:
    	http://bugzilla.kernel.org/show_bug.cgi?id=3D13012
   =20
    I suspect the gcc problem is this:
    	http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D28230
   =20
    Fix the problem by using the -fno-strict-overflow flag instead, which
    not only does not exist in the known-to-be-broken versions of gcc (it
    was introduced later than fwrapv), but seems to be much less disturbi=
ng
    to gcc too: the difference in the generated code by -fno-strict-overf=
low
    are smaller (compared to using neither flag) than when using -fwrapv.
   =20
    Reported-by: Barry K. Nathan <barryn-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
    Pushed-by: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 8b9f2caa02e96bb92327e3b4557adbb3f1203dc7
Merge: 81e4e1ba7ed4a1fdcf0e2ee944f1575010471464 ec05a8d75d0777cd221f61a88=
437a31e4cfb83d8
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Sat Jul 11 11:32:28 2009 -0700

    Merge branch 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linux/=
kernel/git/jdelvare/staging
   =20
    * 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/=
jdelvare/staging:
      hwmon: (abituguru3) DMI probing for AB9, AB9 QuadQT and IX38 QuadGT
      hwmon: (sht15) Remove unnecessary semicolon
      hwmon: (max6650) Fix lock imbalance

commit 81e4e1ba7ed4a1fdcf0e2ee944f1575010471464
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Sat Jul 11 11:22:34 2009 -0700

    Revert "fuse: Fix build error" as unnecessary
   =20
    This reverts commit 097041e576ee3a50d92dd643ee8ca65bf6a62e21.
   =20
    Trond had a better fix, which is the parent of this one ("Fix compile
    error due to congestion_wait() changes")
   =20
    Requested-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
    Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 373c0a7ed3ea3b34efedb7c83ffb521adff7c894
Author: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Date:   Sat Jul 11 10:06:54 2009 -0400

    Fix compile error due to congestion_wait() changes
   =20
    Move the definition of BLK_RW_ASYNC/BLK_RW_SYNC into linux/backing-de=
v.h
    so that it is available to all callers of set/clear_bdi_congested().
   =20
    This replaces commit 097041e576ee3a50d92dd643ee8ca65bf6a62e21 ("fuse:
    Fix build error"), which will be reverted.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
    Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit ec05a8d75d0777cd221f61a88437a31e4cfb83d8
Author: Alistair John Strachan <alistair-T7eSMZptz7IqdlJmJB21zg@public.gmane.org>
Date:   Sat Jul 11 13:42:38 2009 +0200

    hwmon: (abituguru3) DMI probing for AB9, AB9 QuadQT and IX38 QuadGT
   =20
    Switch the AB9, AB9 QuadQT and IX38 QuadGT over from port
    probing to the preferred DMI probe method.
   =20
    Signed-off-by: Alistair John Strachan <alistair-T7eSMZptz7IqdlJmJB21zg@public.gmane.org>
    Tested-by: dan <dan-LV1Rhteroc0AvxtiuMwx3w@public.gmane.org>
    Tested-by: Nygel Lyndley <nygel.lyndley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Tested-by: Dmitriy Fedchenko <dmitriy-fedc-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>
    Acked-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>

commit 24205e0850dd8a79c597e366daafdd5f31a24656
Author: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date:   Sat Jul 11 13:42:37 2009 +0200

    hwmon: (sht15) Remove unnecessary semicolon
   =20
    Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>

commit 025dc740d01f99ccba945df1f9ef9e06b1c15d96
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 11 13:42:37 2009 +0200

    hwmon: (max6650) Fix lock imbalance
   =20
    Add omitted update_lock to one switch/case in set_div.
   =20
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Acked-by: Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
    Signed-off-by: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>

commit f00caa76297a534e30c3ec85382fbc3fd0dcbc69
Merge: 8711c67bee675b4f7a378c71ad5a59c981ec3df0 3ae30796663cc8e144e5b5861=
98b10bc97f1ec38
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 19:19:09 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tiwai/sound-2.6
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/=
sound-2.6:
      ALSA: hda - targa and targa-2ch fix
      ALSA: hda - fix beep tone calculation for IDT/STAC codecs
      ALSA: hda - Missing volume controls for Intel HDA (ALC269/EeePC)
      ALSA: hda - Disable AMD SB600 64bit address support only
      ALSA: hda - Check widget types while parsing capture source in patc=
h_via.c
      ALSA: hda - Fix capture source selection in patch_via.c
      ALSA: hda - Add missing EAPD initialization for VIA codecs
      ALSA: hda - Clean up VT170x dig-in initialization code
      ALSA: hda - Fix error path in the sanity check in azx_pcm_open()
      ALSA: hda - move 8086:fb30 quirk (stac9205) to the proper section
      ASoC: Fix wm8753 register cache size and initialization
      ASoC: add locking to mpc5200-psc-ac97 driver
      ASoC: Fix mpc5200-psc-ac97 to ensure the data ready bit is cleared
      ASoC: Fix register cache initialisation for WM8753

commit 8711c67bee675b4f7a378c71ad5a59c981ec3df0
Author: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 10 12:34:27 2009 +0200

    isofs: fix Joliet regression
   =20
    commit 5404ac8e4418ab3d254950ee4f9bcafc1da20b4a ("isofs: cleanup moun=
t
    option processing") missed conversion of joliet option flag resulting
    in non-working Joliet support.
   =20
    CC: walt <w41ter-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit d4fc4a7bfc2dee626f4fec1e209e58eaa4312de6
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Thu Jul 9 13:36:58 2009 +0100

    tty: Fix the PL2303 private methods for sysrq
   =20
    PL2303 has private data shovelling methods that also have no fast pat=
h. Fix
    them to work the same way as the default handler.
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 24a15a62dcb1968bf4ffdae55c88fa934d971180
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Thu Jul 9 13:36:22 2009 +0100

    tty: Fix USB kref leak
   =20
    The sysrq code acquired a kref leak. Fix it by passing the tty separa=
tely
    from the caller (thus effectively using the callers kref which all th=
e
    callers hold anyway)
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 4cd1de0afaaa45309f34d7282ea4c07d9b56a3ff
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Thu Jul 9 13:35:52 2009 +0100

    tty: Sort out the USB sysrq changes that wrecked performance
   =20
    We can't go around calling all sorts of magic per character functions=
 at
    full rate 3G data speed.
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit d6be791cbd4d6a96f0ec1c8c44166038c76d1330
Merge: 44c695b13bee558c73a89bc79f6253a4ba637386 83c2099f5e1f0a4621ed4f20f=
c539069c636a24b
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 19:15:34 2009 -0700

    Merge branch 'linux-next' of git://git.infradead.org/ubi-2.6
   =20
    * 'linux-next' of git://git.infradead.org/ubi-2.6:
      UBI: fix compilation warnings
      UBI: fix NOR flash recovery
      UBI: nicify image sequence number handling
      UBI: add image sequence number to EC header
      UBI: remove bogus debugging checks
      UBI: add empty eraseblocks verification

commit 44c695b13bee558c73a89bc79f6253a4ba637386
Merge: eee33abe592da1763550e6e55b1cfb7fdc6a9b4c 061125476039a9a998878468a=
6abe235b1cee347
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 19:14:48 2009 -0700

    Merge branch 'linux-next' of git://git.infradead.org/ubifs-2.6
   =20
    * 'linux-next' of git://git.infradead.org/ubifs-2.6:
      UBIFS: fix corruption dump
      UBIFS: clean up free space checking
      UBIFS: small amendments in the LEB scanning code
      UBIFS: dump a little more in case of corruptions
      MAINTAINERS: update ahunter's e-mail address
      UBIFS: allow more than one volume to be mounted
      UBIFS: fix assertion warning
      UBIFS: minor spelling and grammar fixes
      UBIFS: fix 64-bit divisions in debug print
      UBIFS: few spelling fixes
      UBIFS: set write-buffer timout to 3-5 seconds
      UBIFS: slightly optimize write-buffer timer usage
      UBIFS: improve debugging messaged
      UBIFS: fix integer overflow warning

commit eee33abe592da1763550e6e55b1cfb7fdc6a9b4c
Merge: 04eef90c2e2fb860db71bff5f60d5ff0ec4c6dea 07606309ff5a9136e340b9ca8=
7c831650c1ec47a
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 19:12:51 2009 -0700

    Merge branch 'for-linus' of git://git390.marist.edu/pub/scm/linux-2.6
   =20
    * 'for-linus' of git://git390.marist.edu/pub/scm/linux-2.6:
      [S390] define KTIME_SCALAR for 32-bit s390
      [S390] add generic atomic64 support for 31 bit
      [S390] improve suspend/resume error messages
      [S390] set SCHED_OMIT_FRAME_POINTER for s390
      [S390] add __ucmpdi2() helper function
      [S390] perf_counter build fix
      [S390] shutdown actions: save/return rc from init function
      [S390] dasd: correct debugfeature sense dump
      [S390] udelay: disable lockdep to avoid false positives
      [S390] monreader: fix dev_set_drvdata conversion
      [S390] sclp: fix compile error for !SCLP_CONSOLE

commit 04eef90c2e2fb860db71bff5f60d5ff0ec4c6dea
Merge: bb8ad2815a1210bfa56b8f8ebf0e40fbdf9198ff bc47df0fa705887242c26c7b0=
40e7cf0170ab1f1
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 19:12:24 2009 -0700

    Merge branch 'for-linus' of git://git.open-osd.org/linux-open-osd
   =20
    * 'for-linus' of git://git.open-osd.org/linux-open-osd:
      osdblk: Adjust queue limits to lower device's limits
      osdblk: a Linux block device for OSD objects
      MAINTAINERS: Add osd maintained files (F:)
      exofs: Avoid using file_fsync()
      exofs: Remove IBM copyrights
      exofs: Fix bio leak in error handling path (sync read)

commit bb8ad2815a1210bfa56b8f8ebf0e40fbdf9198ff
Merge: c368b4921bc6e309aba2fbee0efcbbc965008d9f 5019914ca3b7517b2d82db2e9=
2e3f683ac48e535
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 19:10:59 2009 -0700

    Merge branch 'drm-intel-next' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/anholt/drm-intel
   =20
    * 'drm-intel-next' of git://git.kernel.org/pub/scm/linux/kernel/git/a=
nholt/drm-intel: (22 commits)
      drm/i915: Fix for LVDS VBT change on IGDNG
      drm/i915: Zap the GTT mapping when transitioning from untiled to ti=
led.
      drm/i915: Refactor calls to unmap_mapping_range
      drm/i915: Avoid saving/restore the modesetting registers twice in K=
MS mode
      drm: Disable the unused connectors explicitly when resuming with KM=
S.
      drm/i915: Restore the KMS modeset for every activated CRTC
      drm/i915: Fix harmless warning from patch merged after i2c rework.
      drm/i915: Disable GEM when a broken video BIOS takes up the whole a=
perture.
      drm/i915: Check the LID device to decide whether the LVDS should be=
 initialized
      drm/i915: Move lock to more reasonable location
      drm/i915: Add gtt_offset to gem object list debugfs output
      drm/i915: Remove gtt_bound from drm_i915_gem_object
      drm/i915: Disable VGA output when doing DRM_MODE_DPMS_OFF.
      drm/i915: crt fetch EDID by DVI-I converter on G4x platform
      drm/i915: Don't update display FIFO watermark on IGDNG
      drm/i915: Adjust DisplayPort clocks to use 96MHz reference
      drm/i915: Make driver less chatty
      drm/i915: fix up a raw 64bit divide
      drm/i915: enable sdvo lvds scaling function.
      drm/i915: Set SSC frequency for 8xx chips correctly
      ...

commit c368b4921bc6e309aba2fbee0efcbbc965008d9f
Author: Amerigo Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jul 10 15:02:44 2009 -0700

    Doc: move Documentation/exception.txt into x86 subdir
   =20
    exception.txt only explains the code on x86, so it's better to
    move it into Documentation/x86 directory.
   =20
    And also rename it to exception-tables.txt which looks much
    more reasonable.
   =20
    This patch is on top of the previous one.
   =20
    Signed-off-by: WANG Cong <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 3697cd9aa80125f7717c3c7e7253cfa49a39a388
Author: Amerigo Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jul 10 15:02:41 2009 -0700

    Doc: update Documentation/exception.txt
   =20
    Update Documentation/exception.txt.
    Remove trailing whitespaces in it.
   =20
    Signed-off-by: WANG Cong <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 097041e576ee3a50d92dd643ee8ca65bf6a62e21
Author: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date:   Fri Jul 10 20:06:42 2009 -0500

    fuse: Fix build error
   =20
    When building v2.6.31-rc2-344-g69ca06c, the following build errors ar=
e
    found due to missing includes:
   =20
     CC [M]  fs/fuse/dev.o
    fs/fuse/dev.c: In function =E2=80=98request_end=E2=80=99:
    fs/fuse/dev.c:289: error: =E2=80=98BLK_RW_SYNC=E2=80=99 undeclared (f=
irst use in this function)
    ...
    fs/nfs/write.c: In function =E2=80=98nfs_set_page_writeback=E2=80=99:
    fs/nfs/write.c:207: error: =E2=80=98BLK_RW_ASYNC=E2=80=99 undeclared =
(first use in this function)
   =20
    Signed-off-by: Larry Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 69ca06c9454169c4a9303e8834adae9080f94859
Merge: 9f2d8be4266f8861af806d964ae5db2949b670f3 32f2e807a3938b24d0831211e=
6094f9e44b2fc83
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 14:29:58 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
   =20
    * 'for-linus' of git://git.kernel.dk/linux-2.6-block:
      cfq-iosched: reset oom_cfqq in cfq_set_request()
      block: fix sg SG_DXFER_TO_FROM_DEV regression
      block: call blk_scsi_ioctl_init()
      Fix congestion_wait() sync/async vs read/write confusion

commit 9f2d8be4266f8861af806d964ae5db2949b670f3
Merge: ac3f482236793c75caae2c2ebb3f3e5f8b7393e1 d9a0a345ab7a58a30ec38e5bb=
7401a28714914d2
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 14:27:21 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ryusuke/nilfs2
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ryusuk=
e/nilfs2:
      nilfs2: fix disorder in cp count on error during deleting checkpoin=
ts
      nilfs2: fix lockdep warning between regular file and inode file
      nilfs2: fix incorrect KERN_CRIT messages in case of write failures
      nilfs2: fix hang problem of log writer which occurs after write fai=
lures
      nilfs2: remove unlikely directive causing mis-conversion of error c=
ode

commit ac3f482236793c75caae2c2ebb3f3e5f8b7393e1
Merge: 85be928c4101670f99cdd7c927798aa4dcbb3168 f39d1b9792881ce4eb982ec8c=
c65258bf95674b5
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 14:25:59 2009 -0700

    Merge branch 'core-fixes-for-linus-2' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
   =20
    * 'core-fixes-for-linus-2' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tip/linux-2.6-tip:
      dma-debug: Fix the overlap() function to be correct and readable
      oprofile: reset bt_lost_no_mapping with other stats
      x86/oprofile: rename kernel parameter for architectural perfmon to =
arch_perfmon
      signals: declare sys_rt_tgsigqueueinfo in syscalls.h
      rcu: Mark Hierarchical RCU no longer experimental
      dma-debug: Put all hash-chain locks into the same lock class
      dma-debug: fix off-by-one error in overlap function

commit 85be928c4101670f99cdd7c927798aa4dcbb3168
Merge: d86ee4809d0329d4aa0d0f2c76c2295a16862799 805d127d62472f17c7d79baa0=
01a7651afe2fa47
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 14:25:03 2009 -0700

    Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org/p=
ub/scm/linux/kernel/git/tip/linux-2.6-tip
   =20
    * 'perfcounters-fixes-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/tip/linux-2.6-tip: (50 commits)
      perf report: Add "Fractal" mode output - support callchains with re=
lative overhead rate
      perf_counter tools: callchains: Manage the cumul hits on the fly
      perf report: Change default callchain parameters
      perf report: Use a modifiable string for default callchain options
      perf report: Warn on callchain output request from non-callchain fi=
le
      x86: atomic64: Inline atomic64_read() again
      x86: atomic64: Clean up atomic64_sub_and_test() and atomic64_add_ne=
gative()
      x86: atomic64: Improve atomic64_xchg()
      x86: atomic64: Export APIs to modules
      x86: atomic64: Improve atomic64_read()
      x86: atomic64: Code atomic(64)_read and atomic(64)_set in C not CPP
      x86: atomic64: Fix unclean type use in atomic64_xchg()
      x86: atomic64: Make atomic_read() type-safe
      x86: atomic64: Reduce size of functions
      x86: atomic64: Improve atomic64_add_return()
      x86: atomic64: Improve cmpxchg8b()
      x86: atomic64: Improve atomic64_read()
      x86: atomic64: Move the 32-bit atomic64_t implementation to a .c fi=
le
      x86: atomic64: The atomic64_t data type should be 8 bytes aligned o=
n 32-bit too
      perf report: Annotate variable initialization
      ...

commit d86ee4809d0329d4aa0d0f2c76c2295a16862799
Author: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Date:   Fri Jul 10 14:57:57 2009 +0200

    sched: optimize cond_resched()
   =20
    Optimize cond_resched() by removing one conditional.
   =20
    Currently cond_resched() checks system_state =3D=3D
    SYSTEM_RUNNING in order to avoid scheduling before the
    scheduler is running.
   =20
    We can however, as per suggestion of Matt, use
    PREEMPT_ACTIVE to accomplish that very same.
   =20
    Suggested-by: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Acked-by: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit c99e6efe1ba04561e7d93a81f0be07e37427e835
Author: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Date:   Fri Jul 10 14:57:56 2009 +0200

    sched: INIT_PREEMPT_COUNT
   =20
    Pull the initial preempt_count value into a single
    definition site.
   =20
    Maintainers for: alpha, ia64 and m68k, please have a look,
    your arch code is funny.
   =20
    The header magic is a bit odd, but similar to the KERNEL_DS
    one, CPP waits with expanding these macros until the
    INIT_THREAD_INFO macro itself is expanded, which is in
    arch/*/kernel/init_task.c where we've already included
    sched.h so we're good.
   =20
    Cc: tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
    Cc: rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org
    Cc: geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org
    Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Acked-by: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 5019914ca3b7517b2d82db2e92e3f683ac48e535
Author: Zhenyu Wang <zhenyu.z.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 10 14:39:59 2009 +0800

    drm/i915: Fix for LVDS VBT change on IGDNG
   =20
    IGDNG mobile chip's LVDS data block removes panel fitting
    register definition. So this fixes offset for LVDS timing
    block parsing. Thanks for Michael Fu to catch this.
   =20
    Signed-off-by: Zhenyu Wang <zhenyu.z.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit d05ca301997c94c2ef3c112b15319d13fa8cddab
Author: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Date:   Fri Jul 10 13:02:26 2009 -0700

    drm/i915: Zap the GTT mapping when transitioning from untiled to tile=
d.
   =20
    As of 52dc7d32b88156248167864f77a9026abe27b432, we could leave an old
    linear GTT mapping in place, so that apps trying to GTT-mapped write =
in
    tiled data wouldn't get the fence added, and garbage would get displa=
yed.
   =20
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 901782b21ecb2af4dde1598b3142bf0e80b20853
Author: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Date:   Fri Jul 10 08:18:50 2009 +0100

    drm/i915: Refactor calls to unmap_mapping_range
   =20
    As we call unmap_mapping_range() twice in identical fashion, refactor
    and attempt to explain why we need to call unmap_mapping_range().
   =20
    Signed-off-by: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit f39d1b9792881ce4eb982ec8cc65258bf95674b5
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 10 21:38:02 2009 +0200

    dma-debug: Fix the overlap() function to be correct and readable
   =20
    Linus noticed how unclean and buggy the overlap() function is:
   =20
     - It uses convoluted (and bug-causing) positive checks for
       range overlap - instead of using a more natural negative
       check.
   =20
     - Even the positive checks are buggy: a positive intersection
       check has four natural cases while we checked only for three,
       missing the (addr < start && addr2 =3D=3D end) case for example.
   =20
     - The variables are mis-named, making it non-obvious how the
       check was done.
   =20
     - It needlessly uses u64 instead of unsigned long. Since these
       are kernel memory pointers and we explicitly exclude highmem
       ranges anyway we cannot ever overflow 32 bits, even if we
       could. (and on 64-bit it doesnt matter anyway)
   =20
    All in one, this function needs a total revamp. I used Linus's
    suggestions minus the paranoid checks (we cannot overflow really
    because if we get totally bad DMA ranges passed far more things
    break in the systems than just DMA debugging). I also fixed a
    few other small details i noticed.
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit fccdaba4317604602e5802c3afc4021f2fb8132e
Author: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 14:13:14 2009 +0800

    drm/i915: Avoid saving/restore the modesetting registers twice in KMS=
 mode
   =20
    In KMS mode we now use the normal mode-setting paths to set the modes
    back to the current configuration, so we don't need to also run the m=
ore
    limited non-KMS implementation of modesetting for resume.
   =20
    Signed-off-by: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Acked-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit af4fcb574efa90373b02ae0bb8b54d710c32eeb4
Author: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 14:13:13 2009 +0800

    drm: Disable the unused connectors explicitly when resuming with KMS.
   =20
    Signed-off-by: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Acked-by:  Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    Acked-by:  Dave Airlie <airlied-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 354ff96772540d2e836194bf14dd9c05c274055c
Author: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 14:13:12 2009 +0800

    drm/i915: Restore the KMS modeset for every activated CRTC
   =20
    Restore the modeset for every activated CRTC in course of resume.
    This is realized by calling the function of drm_helper_resume_force_m=
ode.
    Note: it is meaningful only for the KMS mode.
   =20
    https://bugs.freedesktop.org/show_bug.cgi?id=3D21719
    https://bugs.freedesktop.org/show_bug.cgi?id=3D21708
    https://bugs.freedesktop.org/show_bug.cgi?id=3D22285
    https://bugs.freedesktop.org/show_bug.cgi?id=3D22263
   =20
    Signed-off-by: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 883e860daf5c75a0035c33cb6f8881ee62d6efaf
Author: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Date:   Fri Jul 10 12:28:30 2009 -0700

    drm/i915: Fix harmless warning from patch merged after i2c rework.
   =20
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 2a34f5e6b61c7e8f3b6f25847bcda88511b0ead4
Author: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Date:   Thu Jul 2 09:30:50 2009 -0700

    drm/i915: Disable GEM when a broken video BIOS takes up the whole ape=
rture.
   =20
    This is seen on some G41 systems, where the BIOS will consume all but
    a few KB of the aperture.  This should be bad for all operating syste=
ms, as
    it means that the OS can't dynamically manage memory between graphics=
 and
    the rest of the system, and OSes that did static memory management
    statically add memory in addition to the BIOS allocation anyway.  So,=
 instead
    of working around it, just fail out verbosely.
   =20
    fd.o bug #21574
   =20
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
    Reviewed-by: Ian Romanick <ian.d.romanick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 2a6f86bc5ed4af2ff04bc927eb77789c70e53a1e
Merge: b690a3770e99497982d48a93e30cb7de549aead8 e1af3aec3e2e7d21d4b305432=
3779d478c19d907
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Fri Jul 10 11:41:41 2009 -0700

    Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
   =20
    * 'tracing-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/tip/linux-2.6-tip:
      tracing: Fix trace_print_seq()
      kprobes: No need to unlock kprobe_insn_mutex
      tracing/fastboot: Document the need of initcall_debug
      trace_export: Repair missed fields
      tracing: Fix stack tracer sysctl handling

commit 32f2e807a3938b24d0831211e6094f9e44b2fc83
Author: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 22:13:16 2009 +0200

    cfq-iosched: reset oom_cfqq in cfq_set_request()
   =20
    In case memory is scarce, we now default to oom_cfqq. Once memory is
    available again, we should allocate a new cfqq and stop using oom_cfq=
q for
    a particular io context.
   =20
    Once a new request comes in, check if we are using oom_cfqq, and if y=
es,
    try to allocate a new cfqq.
   =20
    Tested the patch by forcing the use of oom_cfqq and upon next request=
 thread
    realized that it was using oom_cfqq and it allocated a new cfqq.
   =20
    Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

commit ecb554a846f8e9d2a58f6d6c118168a63ac065aa
Author: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date:   Thu Jul 9 14:46:53 2009 +0200

    block: fix sg SG_DXFER_TO_FROM_DEV regression
   =20
    I overlooked SG_DXFER_TO_FROM_DEV support when I converted sg to use
    the block layer mapping API (2.6.28).
   =20
    Douglas Gilbert explained SG_DXFER_TO_FROM_DEV:
   =20
    http://www.spinics.net/lists/linux-scsi/msg37135.html
   =20
    =3D
    The semantics of SG_DXFER_TO_FROM_DEV were:
       - copy user space buffer to kernel (LLD) buffer
       - do SCSI command which is assumed to be of the DATA_IN
         (data from device) variety. This would overwrite
         some or all of the kernel buffer
       - copy kernel (LLD) buffer back to the user space.
   =20
    The idea was to detect short reads by filling the original
    user space buffer with some marker bytes ("0xec" it would
    seem in this report). The "resid" value is a better way
    of detecting short reads but that was only added this century
    and requires co-operation from the LLD.
    =3D
   =20
    This patch changes the block layer mapping API to support this
    semantics. This simply adds another field to struct rq_map_data and
    enables __bio_copy_iov() to copy data from user space even with READ
    requests.
   =20
    It's better to add the flags field and kills null_mapped and the new
    from_user fields in struct rq_map_data but that approach makes it
    difficult to send this patch to stable trees because st and osst
    drivers use struct rq_map_data (they were converted to use the block
    layer in 2.6.29 and 2.6.30). Well, I should clean up the block layer
    mapping API.
   =20
    zhou sf reported this regiression and tested this patch:
   =20
    http://www.spinics.net/lists/linux-scsi/msg37128.html
    http://www.spinics.net/lists/linux-scsi/msg37168.html
   =20
    Reported-by: zhou sf <sxzzsf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Tested-by: zhou sf <sxzzsf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
    Signed-off-by: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
    Signed-off-by: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

commit 76da03467a1a78811777561bbb1fa56175ee4778
Author: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date:   Thu Jul 9 09:48:28 2009 +0200

    block: call blk_scsi_ioctl_init()
   =20
    Currently, blk_scsi_ioctl_init() is not called since it lacks
    an initcall marking. This causes the command table to be
    unitialized, hence somce commands are block when they should
    not have been.
   =20
    This fixes a regression introduced by commit
    018e0446890661504783f92388ecce7138c1566d
   =20
    Signed-off-by: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
    Signed-off-by: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

commit 8aa7e847d834ed937a9ad37a0f2ad5b8584c1ab0
Author: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 14:52:32 2009 +0200

    Fix congestion_wait() sync/async vs read/write confusion
   =20
    Commit 1faa16d22877f4839bd433547d770c676d1d964c accidentally broke
    the bdi congestion wait queue logic, causing us to wait on congestion
    for WRITE (=3D=3D 1) when we really wanted BLK_RW_ASYNC (=3D=3D 0) in=
stead.
   =20
    Signed-off-by: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

commit 2b8777ca0c944bf6498c45ed9c5c246bd63a719e
Author: Maynard Johnson <maynardj-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed May 27 10:15:08 2009 -0500

    oprofile: reset bt_lost_no_mapping with other stats
   =20
    The bt_lost_no_mapping is not getting reset at the start of a
    profiling run, thus the oprofiled.log shows erroneous values for this
    statistic. The attached patch fixes this problem.
   =20
    Signed-off-by: Maynard Johnson <maynardj-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Robert Richter <robert.richter-5C7GfCeVMHo@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 3ae30796663cc8e144e5b586198b10bc97f1ec38
Merge: f371f12f3e9840771026aa6a9312b554c5bfd6ec 005b10769c05fb16db70f7689=
ffb5ba17e3fc324
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Fri Jul 10 11:17:12 2009 +0200

    Merge branch 'fix/hda' into for-linus
   =20
    * fix/hda:
      ALSA: hda - targa and targa-2ch fix
      ALSA: hda - fix beep tone calculation for IDT/STAC codecs
      ALSA: hda - Missing volume controls for Intel HDA (ALC269/EeePC)
      ALSA: hda - Disable AMD SB600 64bit address support only
      ALSA: hda - Check widget types while parsing capture source in patc=
h_via.c
      ALSA: hda - Fix capture source selection in patch_via.c
      ALSA: hda - Add missing EAPD initialization for VIA codecs
      ALSA: hda - Clean up VT170x dig-in initialization code
      ALSA: hda - Fix error path in the sanity check in azx_pcm_open()
      ALSA: hda - move 8086:fb30 quirk (stac9205) to the proper section

commit f371f12f3e9840771026aa6a9312b554c5bfd6ec
Merge: 7ce1695c40e765e99cd790f55fc68037bc05d080 637a935aaba2f05e2178c9d1b=
714d7a2c36c8b44
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Fri Jul 10 11:17:11 2009 +0200

    Merge branch 'fix/asoc' into for-linus
   =20
    * fix/asoc:
      ASoC: Fix wm8753 register cache size and initialization
      ASoC: add locking to mpc5200-psc-ac97 driver
      ASoC: Fix mpc5200-psc-ac97 to ensure the data ready bit is cleared
      ASoC: Fix register cache initialisation for WM8753

commit b690a3770e99497982d48a93e30cb7de549aead8
Merge: 016d3569bf7b21375451d91be6ee2ad4ffff5211 cf1eaab2525e8ae1d53eaf923=
981c96cb31e57c8
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Thu Jul 9 20:45:01 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-wat=
chdog
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-watchdo=
g:
      [WATCHDOG] w83627hf_wdt.c: add support for the W83627EHF support
      [WATCHDOG] SA1100 watchdog maximum timeout
      [WATCHDOG] w83697ug, fix lock imbalance
      [WATCHDOG] drivers/watchdog/bcm47xx_wdt.c: Remove unnecessary semic=
olons

commit 016d3569bf7b21375451d91be6ee2ad4ffff5211
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Thu Jul 9 20:14:10 2009 +0200

    mx3fb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove call to the mx3fb_set_par() and the mx3fb_blank() before the
    register_framebuffer().
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit afecb0d02ad5554cb59c2a30c262da200beaa002
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Thu Jul 9 20:15:44 2009 +0200

    sm501fb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove call to the fb_set_par() before the register_framebuffer().
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit c2cc49a2f8a479dde96a599646d30b6cc9dbed78
Merge: e864561c12bc743789eab76242b8314d394daa52 d0c280d26de9422c9c943f8f4=
86b9830cd9bea70
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Thu Jul 9 20:40:58 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6:
      cifs: when ATTR_READONLY is set, only clear write bits on non-direc=
tories
      cifs: remove cifsInodeInfo->inUse counter
      cifs: convert cifs_get_inode_info and non-posix readdir to use cifs=
_iget
      [CIFS] update cifs version number
      cifs: add and use CIFSSMBUnixSetFileInfo for setattr calls
      cifs: make a separate function for filling out FILE_UNIX_BASIC_INFO
      cifs: rename CIFSSMBUnixSetInfo to CIFSSMBUnixSetPathInfo
      cifs: add pid of initiating process to spnego upcall info
      cifs: fix regression with O_EXCL creates and optimize away lookup
      cifs: add new cifs_iget function and convert unix codepath to use i=
t

commit e864561c12bc743789eab76242b8314d394daa52
Merge: 42359da44112565e12a5209befb36dc6b6d6cd9c e594e96e8a14101a6decabf67=
46bd5186287debc
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Thu Jul 9 20:33:18 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6: (29 co=
mmits)
      cxgb3: Fix crash caused by stashing wrong netdev_queue
      ixgbe: Fix coexistence of FCoE and Flow Director in 82599
      memory barrier: adding smp_mb__after_lock
      net: adding memory barrier to the poll and receive callbacks
      netpoll: Fix carrier detection for drivers that are using phylib
      includecheck fix: include/linux, rfkill.h
      p54: tx refused but queue active
      Atheros Kconfig needs to be dependent on WLAN_80211
      mac80211: fix docbook
      mac80211_hwsim: avoid NULL access
      ssb: Add support for 4318E
      b43: Add support for 4318E
      zd1211rw: adding SONY IFU-WLM2 (054c:0257) as a zd1211b device
      zd1211rw: 07b8:6001 is a ZD1211B
      r6040: bump driver version to 0.24 and date to 08 July 2009
      r6040: restore MIER register correctly when IRQ line is shared
      ipv4: Fix fib_trie rebalancing, part 4 (root thresholds)
      davinci_emac: fix kernel oops when changing MAC address while inter=
face is down
      igb: set lan id prior to configuring phy
      mac80211: minstrel: avoid accessing negative indices in rix_to_ndx(=
)
      ...

commit 42359da44112565e12a5209befb36dc6b6d6cd9c
Author: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 21:54:39 2009 -0400

    Fix compile error in bmac.c
   =20
    Looks like the change in ad361c9884e809340f6daca80d56a9e9c871690a
    wasn't compile tested.
   =20
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 8d7ff4f2a0b22b7d6d7bc3982257d1dadea22824
Author: Robert Richter <robert.richter-5C7GfCeVMHo@public.gmane.org>
Date:   Tue Jun 23 11:48:14 2009 +0200

    x86/oprofile: rename kernel parameter for architectural perfmon to ar=
ch_perfmon
   =20
    The short name of the achitecture is 'arch_perfmon'. This patch
    changes the kernel parameter to use this name.
   =20
    Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
    Signed-off-by: Robert Richter <robert.richter-5C7GfCeVMHo@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit e594e96e8a14101a6decabf6746bd5186287debc
Author: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 9 09:30:25 2009 +0000

    cxgb3: Fix crash caused by stashing wrong netdev_queue
   =20
    Commit c3a8c5b6 ("cxgb3: move away from LLTX") exposed a bug in how
    cxgb3 looks up the netdev_queue it stashes away in a qset during
    initialization.  For multiport devices, the TX queue index it uses is
    offset by the first_qset index of each port.  This leads to a crash
    once LLTX is removed, since hard_start_xmit is called with one TX
    queue lock held, while the TX reclaim timer task grabs a different
    (wrong) TX queue lock when it frees skbs.
   =20
    Fix this by removing the first_qset offset used to look up the TX
    queue passed into t3_sge_alloc_qset() from setup_sge_qsets().
   =20
    Signed-off-by: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
    Acked-by: Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 8faa2a786a5337683109d77ccf880339fdcdb332
Author: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 9 02:29:50 2009 +0000

    ixgbe: Fix coexistence of FCoE and Flow Director in 82599
   =20
    Fix coexistence of Fiber Channel over Ethernet (FCoE) and Flow Direct=
or (FDIR)
    in 82599 and remove the disabling of FDIR when FCoE is enabled.
   =20
    Currently, FDIR is turned off when FCoE is enabled under the assumpti=
on that
    FCoE is always enabled with DCB being turned on. However, FDIR does n=
ot have
    to be turned off all the time when FCoE is enabled since FCoE can be =
enabled
    without DCB being turned on, e.g., use link pause only. This patch ma=
kes sure
    that when DCB is turned on or off, FDIR is turned on or off correspon=
dingly;
    and when FCoE is enabled, it does not disable FDIR, rather, it will h=
ave FDIR
    set up properly so FCoE and FDIR can coexist regardless of DCB being =
on or off.
   =20
    Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit ad46276952f1af34cd91d46d49ba13d347d56367
Author: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 8 12:10:31 2009 +0000

    memory barrier: adding smp_mb__after_lock
   =20
    Adding smp_mb__after_lock define to be used as a smp_mb call after
    a lock.
   =20
    Making it nop for x86, since {read|write|spin}_lock() on x86 are
    full memory barriers.
   =20
    Signed-off-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit a57de0b4336e48db2811a2030bb68dba8dd09d88
Author: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 8 12:09:13 2009 +0000

    net: adding memory barrier to the poll and receive callbacks
   =20
    Adding memory barrier after the poll_wait function, paired with
    receive callbacks. Adding fuctions sock_poll_wait and sk_has_sleeper
    to wrap the memory barrier.
   =20
    Without the memory barrier, following race can happen.
    The race fires, when following code paths meet, and the tp->rcv_nxt
    and __add_wait_queue updates stay in CPU caches.
   =20
    CPU1                         CPU2
   =20
    sys_select                   receive packet
      ...                        ...
      __add_wait_queue           update tp->rcv_nxt
      ...                        ...
      tp->rcv_nxt check          sock_def_readable
      ...                        {
      schedule                      ...
                                    if (sk->sk_sleep && waitqueue_active(=
sk->sk_sleep))
                                            wake_up_interruptible(sk->sk_=
sleep)
                                    ...
                                 }
   =20
    If there was no cache the code would work ok, since the wait_queue an=
d
    rcv_nxt are opposit to each other.
   =20
    Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either alr=
eady
    passed the tp->rcv_nxt check and sleeps, or will get the new value fo=
r
    tp->rcv_nxt and will return with new data mask.
    In both cases the process (CPU1) is being added to the wait queue, so=
 the
    waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
   =20
    The bad case is when the __add_wait_queue changes done by CPU1 stay i=
n its
    cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 wil=
l then
    endup calling schedule and sleep forever if there are no more data on=
 the
    socket.
   =20
    Calls to poll_wait in following modules were ommited:
    	net/bluetooth/af_bluetooth.c
    	net/irda/af_irda.c
    	net/irda/irnet/irnet_ppp.c
    	net/mac80211/rc80211_pid_debugfs.c
    	net/phonet/socket.c
    	net/rds/af_rds.c
    	net/rfkill/core.c
    	net/sunrpc/cache.c
    	net/sunrpc/rpc_pipe.c
    	net/tipc/socket.c
   =20
    Signed-off-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit d0c280d26de9422c9c943f8f486b9830cd9bea70
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 01:46:44 2009 -0400

    cifs: when ATTR_READONLY is set, only clear write bits on non-directo=
ries
   =20
    cifs: when ATTR_READONLY is set, only clear write bits on non-directo=
ries
   =20
    On windows servers, ATTR_READONLY apparently either has no meaning or
    serves as some sort of queue to certain applications for unrelated
    behavior. This MS kbase article has details:
   =20
    http://support.microsoft.com/kb/326549/
   =20
    Don't clear the write bits directory mode when ATTR_READONLY is set.
   =20
    Reported-by: pouchat-dE4U1dcV8S3R7s880joybQ@public.gmane.org
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit aeaaf253c4dee7ff9af2f3f0595f3bb66964e944
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 01:46:39 2009 -0400

    cifs: remove cifsInodeInfo->inUse counter
   =20
    cifs: remove cifsInodeInfo->inUse counter
   =20
    It was purported to be a refcounter of some sort, but was never
    used that way. It never served any purpose that wasn't served equally=
 well
    by the I_NEW flag.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 0b8f18e358384a52c1ed7fa7129c08e7eaf86bb6
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 01:46:37 2009 -0400

    cifs: convert cifs_get_inode_info and non-posix readdir to use cifs_i=
get
   =20
    cifs: convert cifs_get_inode_info and non-posix readdir to use cifs_i=
get
   =20
    Rather than allocating an inode and filling it out, have
    cifs_get_inode_info fill out a cifs_fattr and call cifs_iget. This me=
ans
    a pretty hefty reorganization of cifs_get_inode_info.
   =20
    For the readdir codepath, add a couple of new functions for filling o=
ut
    cifs_fattr's from different FindFile response infolevels.
   =20
    Finally, remove cifs_new_inode since there are no more callers.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit e99da35f060f9a3407f7def474a1df31f3b8643a
Author: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jun 26 09:46:18 2009 +0800

    drm/i915: Check the LID device to decide whether the LVDS should be i=
nitialized
   =20
    On some boxes the mobile chipset is used and there is no LVDS device.=
 In such
    case we had better not initialize the LVDS output device so that one =
pipe can
    be used for other output device. For example: E-TOP.
   =20
    But unfortunately the LVDS device is still initialized on the boxes b=
ased on
    mobile chipset in KMS mode. It brings that this pipe occupied by LVDS=
 can't be
    used for other output device.
   =20
    After checking the acpidump we find that there is no LID device on su=
ch boxes.
    In such case we can use the LID device to decide whether the LVDS dev=
ice should
    be initialized.
   =20
    If there is no LID device, we can think that there is no LVDS device.=
 It is
    unnecessary to initialize the LVDS output device.
    If there exists the LID device, it will continue the current flowchar=
t.
   =20
    Maybe on some boxes there is no LVDS device but the LID device is fou=
nd. In
    such case it should be added to the quirk list.
   =20
    http://bugs.freedesktop.org/show_bug.cgi?id=3D21496
    http://bugs.freedesktop.org/show_bug.cgi?id=3D21856
    http://bugs.freedesktop.org/show_bug.cgi?id=3D21127
   =20
    Signed-off-by: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    [anholt: squashed in style fixups]
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit b77863bfa153e886f9f8faf1a791ba57a36efed0
Author: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 22:51:38 2009 +0000

    [CIFS] update cifs version number
   =20
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 3bbeeb3c93a961bd01b969dd4395ecac0c09db8d
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 20:02:50 2009 -0400

    cifs: add and use CIFSSMBUnixSetFileInfo for setattr calls
   =20
    cifs: add and use CIFSSMBUnixSetFileInfo for setattr calls
   =20
    When there's an open filehandle, SET_FILE_INFO is apparently preferre=
d
    over SET_PATH_INFO. Add a new variant that sets a FILE_UNIX_INFO_BASI=
C
    infolevel via SET_FILE_INFO and switch cifs_setattr_unix to use the
    new call when there's an open filehandle available.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 654cf14ac0a71c56c1f0032140c3403382ca076b
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 20:02:49 2009 -0400

    cifs: make a separate function for filling out FILE_UNIX_BASIC_INFO
   =20
    cifs: make a separate function for filling out FILE_UNIX_BASIC_INFO
   =20
    The SET_FILE_INFO variant will need to do the same thing here. Break
    this code out into a separate function that both variants can call.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 01ea95e3b6b16573a491ef98ad63f7a1bdcb504f
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 20:02:49 2009 -0400

    cifs: rename CIFSSMBUnixSetInfo to CIFSSMBUnixSetPathInfo
   =20
    cifs: rename CIFSSMBUnixSetInfo to CIFSSMBUnixSetPathInfo
   =20
    ...in preparation of adding a SET_FILE_INFO variant.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit c4c1bff64dfff4e6dd0936a0340f56b9284512c8
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 9 20:02:48 2009 -0400

    cifs: add pid of initiating process to spnego upcall info
   =20
    cifs: add pid of initiating process to spnego upcall info
   =20
    This will allow the upcall to poke in /proc/<pid>/environ and get
    the value of the $KRB5CCNAME env var for the process.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit cf1eaab2525e8ae1d53eaf923981c96cb31e57c8
Author: Slobodan Tomi=C4=87 <stomic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 21:20:36 2009 +0200

    [WATCHDOG] w83627hf_wdt.c: add support for the W83627EHF support
   =20
    Add support for the W83627EHF/EF and W83627EHG/EG chipsets.
   =20
    Signed-off-by: Slobodan Tomi=C4=87 <stomic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>

commit a6f052e39c3832b5842c4f44d9b3a4295dacfc4a
Author: Raphael Assenat <raph-04oEwi3R4qQ@public.gmane.org>
Date:   Mon Jun 29 13:56:52 2009 -0400

    [WATCHDOG] SA1100 watchdog maximum timeout
   =20
    This patch replaces the hardcoded 255 seconds limit for a real limit =
based on
    oscr_freq.
   =20
    Also, the 'firmware_version' field is changed to '1' to allow the use=
r
    space application to easily detect that this driver supports a higher
    maximum timeout.
   =20
    Signed-off-by: Raphael Assenat <raph-1DTJXTWyDbQ@public.gmane.org>
    Signed-off-by: Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>

commit db5d2d8a5dfe0ae3e83ac618fd953ecc621adcdf
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 18:00:39 2009 +0200

    [WATCHDOG] w83697ug, fix lock imbalance
   =20
    Don't forget to unlock io_lock when w83697ug_select_wd_register fails=
 in
    wdt_ctrl.
   =20
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>

commit b86a6c6c7b0bfc26b3e8d4f48e16ee0b13716385
Author: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date:   Sun Jun 28 09:26:57 2009 -0700

    [WATCHDOG] drivers/watchdog/bcm47xx_wdt.c: Remove unnecessary semicol=
ons
   =20
    Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>

commit 005b10769c05fb16db70f7689ffb5ba17e3fc324
Author: David Heidelberger <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 9 18:45:46 2009 +0200

    ALSA: hda - targa and targa-2ch fix
   =20
    Simplify ALC882_TARGA and return gpio3 to ALC883_TARGA_DIG and
    ALC883_TARGA_2ch_DIG, which I accidentally removed in commit id
    64a8be74357477558183b43156c5536b642de134
   =20
    Signed-off-by: David Heidelberger <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit 264ef8a904943ed7d0b04fa958894d7a5c2b2c61
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:33:01 2009 +0100

    kmemleak: Remove alloc_bootmem annotations introduced in the past
   =20
    kmemleak_alloc() calls were added in some places where alloc_bootmem =
was
    called. Since now kmemleak tracks bootmem allocations, these explicit
    calls should be run.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Acked-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>

commit 369693dc93533097c0ca7243affb4f3244c336e8
Author: Paul Vojta <vojta-ffIAWvALzlkb0cFwG/AQJIdd74u8MsAO@public.gmane.org>
Date:   Wed Jul 8 23:57:46 2009 -0700

    ALSA: hda - fix beep tone calculation for IDT/STAC codecs
   =20
    In the beep tone calculation for IDT/STAC codecs, lower numbers corre=
spond
    to higher frequencies and vice versa.  The current code has this back=
wards,
    resulting in beep frequencies which are way too high (and sound bad o=
n
    tinny laptop speakers, resulting in complaints).
   =20
    [Also added hz <=3D 0 check by tiwai]
   =20
    Signed-off-by: Paul Vojta <vojta-ffIAWvALzlkb0cFwG/AQJIdd74u8MsAO@public.gmane.org>
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit 061125476039a9a998878468a6abe235b1cee347
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 19:27:14 2009 +0300

    UBIFS: fix corruption dump
   =20
    In the 'ubifs_recover_leb()' function, when we find corrupted
    empty space, we dump 8K starting from the offset where the last
    node ends. This is OK if the corrupted empty space is somewhere
    near that offset. But if the corruption is far at the end of the
    LEB, we will dump all 0xFF bytes and complitely ignore the
    interesting data. This is observed on a PPC ("kilauea") with
    NOR flash.
   =20
    This patch changes the behavior and teaches UBIFS to print only
    interesting data. I.e., now we find where corruption starts and
    start dumping from that offset.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Adrian Hunter <Adrian.Hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 431102fed3effe4e4e19678830ddab7f05c34bf9
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 18:58:34 2009 +0300

    UBIFS: clean up free space checking
   =20
    recovery.c has 'is_empty()' helper and it is better to use
    this helper instead of re-implementing it in several places.
    This patch does this and removes some amount of unneeded code.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Adrian Hunter <Adrian.Hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit ed43f2f06cc1cec7ec2dc235c908530bc8c796eb
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 17:59:23 2009 +0300

    UBIFS: small amendments in the LEB scanning code
   =20
    This patch fixes few minor things I've spotted while going through
    code:
   =20
    1. Better document return codes
    2. If 'ubifs_scan_a_node()' returns some thing we do not expect,
       treat this as an error.
    3. Try to do recovery only when 'ubifs_scan()' returns %-EUCLEAN,
       not on any error.
    4. If empty space starts at a non-aligned address, print a message.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Adrian Hunter <Adrian.Hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 086b3640c10ab448a6993c4bae1508f496f530c4
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 16:25:33 2009 +0300

    UBIFS: dump a little more in case of corruptions
   =20
    In case of corruptions, dump 8192 bytes instead of 4096. The
    largest node is 4096+ bytes, so it is better to see a node
    boundary, which is not always possible when only 4096 bytes
    are printed.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Adrian Hunter <Adrian.Hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 34f25476ace556263784ea2f8173e22b25557a13
Merge: 2e3167308048ca6c810733384d8289082f7e4ec1 5e1596f75395e7a402e1059c5=
18e633d2732dcf8
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 20:59:13 2009 -0700

    Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git=
/davej/cpufreq
   =20
    * 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpuf=
req:
      [CPUFREQ] Fix compile failure in cpufreq.c

commit 1b614fb9a00e97b1eab54d4e442d405229c059dd
Author: Anton Vorontsov <avorontsov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Date:   Wed Jul 8 20:09:44 2009 -0700

    netpoll: Fix carrier detection for drivers that are using phylib
   =20
    Using early netconsole and gianfar driver this error pops up:
   =20
      netconsole: timeout waiting for carrier
   =20
    It appears that net/core/netpoll.c:netpoll_setup() is using
    cond_resched() in a loop waiting for a carrier.
   =20
    The thing is that cond_resched() is a no-op when system_state !=3D
    SYSTEM_RUNNING, and so drivers/net/phy/phy.c's state_queue is never
    scheduled, therefore link detection doesn't work.
   =20
    I belive that the main problem is in cond_resched()[1], but despite
    how the cond_resched() story ends, it might be a good idea to call
    msleep(1) instead of cond_resched(), as suggested by Andrew Morton.
   =20
    [1] http://lkml.org/lkml/2009/7/7/463
   =20
    Signed-off-by: Anton Vorontsov <avorontsov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit d2daeabf62a5fb205d413c35cf604021db17536b
Merge: c3b85423072c0739d76b7c54080d3f3ccc5dad4d 1ce822fa04fd6878f079461a4=
b8affe4bb5ec27b
Author: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date:   Wed Jul 8 18:13:13 2009 -0700

    Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/linville/wireless-2.6

commit 2e3167308048ca6c810733384d8289082f7e4ec1
Author: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 17:05:32 2009 -0700

    fealnx: Fix build breakage -- PR_CONT should be KERN_CONT
   =20
    Commit ad361c98 ("Remove multiple KERN_ prefixes from printk formats"=
)
    broke the build for fealnx because it added some "printk(PR_CONT ..."
    calls, when PR_CONT doesn't exist; it should be "printk(KERN_CONT ...=
"
   =20
    Signed-off-by: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
    Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 5e1596f75395e7a402e1059c518e633d2732dcf8
Author: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 8 16:14:23 2009 -0400

    [CPUFREQ] Fix compile failure in cpufreq.c
   =20
    managed_policy is out of scope for the non-smp case.
    Declare it locally where used (twice)
   =20
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 5ddf1e0ff00fd808c048d0b920784828276cc516
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Sun Jul 5 11:01:02 2009 -0400

    cifs: fix regression with O_EXCL creates and optimize away lookup
   =20
    cifs: fix regression with O_EXCL creates and optimize away lookup
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Tested-by: Shirish Pargaonkar <shirishp-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    CC: Stable Kernel <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 1d01e83557105e7b3bf1623ad2b814d55e1c2990
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Wed Jul 8 22:26:16 2009 +0200

    atmel_lcdfb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove not needed locking of the fb_info->mm_lock mutex before a
    frambuffer is registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit b5daa70a4a55a807e893fe7f94289c61c50a6e5f
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Wed Jul 8 21:59:17 2009 +0200

    fsl-diu-fb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove call to the fsl_diu_set_par before the register_framebuffer().
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Tested-by: "Kai Jiang" <b18973-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 1ce822fa04fd6878f079461a4b8affe4bb5ec27b
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 8 21:25:54 2009 +0530

    includecheck fix: include/linux, rfkill.h
   =20
    fix the following 'make includecheck' warning:
   =20
      include/linux/rfkill.h: linux/types.h is included more than once.
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 47ab3840a389ff1b9959734995123e5bc94c3443
Author: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date:   Wed Jul 8 08:33:02 2009 -0500

    p54: tx refused but queue active
   =20
    In the mainline kernel, p54usb will fail because the TX queue length =
can
    become < 0. This problem has been reported as Bugzilla #13725. The fa=
ilure
    is expressed by the following message in the logs:
   =20
    WARNING: at net/mac80211/tx.c:1325 ieee80211_tx+0x23c/0x298 [mac80211=
]()
    Hardware name: HP Pavilion dv2700 Notebook PC
    tx refused but queue active
   =20
    This problem has been recently observed in the wireless-testing tree,=
 where
    a full solution is being tested. That fix is too invasive for 2.6.31-=
rcX,
    but the simple change supplied here will prevent the failure.
   =20
    Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 804ef71ee183121de5e9bca1d70d114c97300e17
Author: Jay Sternberg <jay.e.sternberg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jul 7 11:18:46 2009 -0700

    Atheros Kconfig needs to be dependent on WLAN_80211
   =20
    Atheros top level menu needs a "depends WLAN_80211" to properly inden=
t
    within menuconfig and xconfig interfaces.
   =20
    This is purely a visual issue but it effects all subsequent drivers.
    The issue is the top level menu does not include a dependency on
    WLAN_80211 so within the tree structure, Atheros is at the same level=
 as
    WLAN_80211 but when WLAN_80211 collapsed, the menu disappears along w=
ith
    all subsequent drives, so it is really a subordinate.
   =20
    Signed-off-by: Jay Sternberg <jay.e.sternberg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit b9744d19e35d74f965fb94bd55f9313d3a7d9e54
Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date:   Tue Jul 7 11:10:12 2009 +0200

    mac80211: fix docbook
   =20
    These two functions no longer exist in mac80211,
    so trying to insert them generates warnings in
    the document.
   =20
    Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 4ff176674e75bdee9022dded415fb805f15700ad
Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date:   Tue Jul 7 03:43:02 2009 +0200

    mac80211_hwsim: avoid NULL access
   =20
    There's a race condition -- started can be set to true
    before channel is set due to the way mac80211 callbacks
    currently work (->start should probably pass the channel
    we would like to have initially). For now simply add a
    check to hwsim to avoid dereferencing the NULL channel
    pointer.
   =20
    Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 2fbddeb5c409c90be4706ea2beb7f1fc02100c72
Author: Clyde McPherson <ccmcphe-H+0wwilmMs3R7s880joybQ@public.gmane.org>
Date:   Tue Jun 30 22:39:43 2009 -0500

    ssb: Add support for 4318E
   =20
    Added support for the Broadcom 4318E chipset on PCMCIA/CF cards. The
    4318E can do 802.11A/B/G, only B and G mode are supported in b43.
   =20
    Signed-off-by: Clyde McPherson <ccmcphe-H+0wwilmMs3R7s880joybQ@public.gmane.org>
    Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit cff782cd94df7adea84af6aa9516c8088f7ea950
Author: Clyde McPherson <ccmcphe-H+0wwilmMs3R7s880joybQ@public.gmane.org>
Date:   Tue Jun 30 22:39:28 2009 -0500

    b43: Add support for 4318E
   =20
    Added support for the Broadcom 4318E chipset on PCMCIA/CF cards. The
    4318E can do 802.11A/B/G, only B and G mode are supported in b43.
   =20
    Signed-off-by: Clyde McPherson <ccmcphe-H+0wwilmMs3R7s880joybQ@public.gmane.org>
    Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 8b339d05805fb91cc0b5179af5b4d05d9f8b949c
Author: Hin-Tak Leung <hintak.leung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jun 26 05:28:15 2009 +0100

    zd1211rw: adding SONY IFU-WLM2 (054c:0257) as a zd1211b device
   =20
    Yevgen Kotikov reported success on the sourceforge zd1211-devs list
    with the following details:
   =20
    Brand/retail: SONY IFU-WLM2
    USB-IDs: Vendor: 0x054C Device: 0x0257
    chip ID: zd1211b chip 054c:0257 v4802 high 00-0b-6b AL2230_RF pa0 ---=
--
    FCC ID: unknown
   =20
    Signed-off-by: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Tested-by: Yevgen Kotikov <yevgen.kotikov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit b4b223cdd5981f776491134faa7bc4ac342b44d4
Author: Pascal Terjan <pterjan-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>
Date:   Thu Jun 18 17:54:03 2009 +0200

    zd1211rw: 07b8:6001 is a ZD1211B
   =20
    On a shuttle machine here we got 07b8:6001 device, handled by zd1211r=
w, which does not work.
    Scanning is OK but association does not work, we get "direct probe to=
 AP xxx timed out"
   =20
    It appears that this simple patch makes the device work perfectly.
   =20
    This id was already there in initial import of the driver so I don't =
know if it has ever been
    working as ZD1211 (which would mean they changed it and kept the id :=
( ).
   =20
    Signed-off-by: Pascal Terjan <pterjan-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit c3b85423072c0739d76b7c54080d3f3ccc5dad4d
Author: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Date:   Wed Jul 8 03:05:48 2009 +0000

    r6040: bump driver version to 0.24 and date to 08 July 2009
   =20
    Signed-off-by: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 35976d4d557c5017c2180a083e8bd970cf73f3d5
Author: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Date:   Wed Jul 8 03:05:14 2009 +0000

    r6040: restore MIER register correctly when IRQ line is shared
   =20
    When the r6040 device IRQ line is shared we will enter the driver
    interrupt service routine, mask off the device interrupt enable
    register (MIER) and return with IRQ_NONE, we would then leave the
    device with interrupts disabled, this patch fixes that issue.
   =20
    Reported-by: Steve Holland <sdh4-KgB/ygH5PX6Vc3sceRu5cw@public.gmane.org>
    Signed-off-by: Joe Chou <joe.chou-ZjwCAu8Ajol9nmWX13WWKA@public.gmane.org>
    Signed-off-by: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 345aa031207d02d7438c1aa96ed9315911ecd745
Author: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Tue Jul 7 19:39:16 2009 -0700

    ipv4: Fix fib_trie rebalancing, part 4 (root thresholds)
   =20
    Pawel Staszewski wrote:
    <blockquote>
    Some time ago i report this:
    http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
   =20
    and now with 2.6.29 / 2.6.29.1 / 2.6.29.3 and 2.6.30 it back
    dmesg output:
    oprofile: using NMI interrupt.
    Fix inflate_threshold_root. Now=3D15 size=3D11 bits
    ...
    Fix inflate_threshold_root. Now=3D15 size=3D11 bits
   =20
    cat /proc/net/fib_triestat
    Basic info: size of leaf: 40 bytes, size of tnode: 56 bytes.
    Main:
            Aver depth:     2.28
            Max depth:      6
            Leaves:         276539
            Prefixes:       289922
            Internal nodes: 66762
              1: 35046  2: 13824  3: 9508  4: 4897  5: 2331  6: 1149  7: =
5
    9: 1  18: 1
            Pointers: 691228
    Null ptrs: 347928
    Total size: 35709  kB
    </blockquote>
   =20
    It seems, the current threshold for root resizing is too aggressive,
    and it causes misleading warnings during big updates, but it might be
    also responsible for memory problems, especially with non-preempt
    configs, when RCU freeing is delayed long after call_rcu.
   =20
    It should be also mentioned that because of non-atomic changes during
    resizing/rebalancing the current lookup algorithm can miss valid leav=
es
    so it's additional argument to shorten these activities even at a cos=
t
    of a minimally longer searching.
   =20
    This patch restores values before the patch "[IPV4]: fib_trie root
    node settings", commit: 965ffea43d4ebe8cd7b9fee78d651268dd7d23c5 from
    v2.6.22.
   =20
    Pawel's report:
    <blockquote>
    I dont see any big change of (cpu load or faster/slower
    routing/propagating routes from bgpd or something else) - in avg ther=
e
    is from 2% to 3% more of CPU load i dont know why but it is - i chang=
e
    from "preempt" to "no preempt" 3 times and check this my "mpstat -P A=
LL
    1 30"
    always avg cpu load was from 2 to 3% more compared to "no preempt"
    [...]
    cat /proc/net/fib_triestat
    Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
    Main:
            Aver depth:     2.44
            Max depth:      6
            Leaves:         277814
            Prefixes:       291306
            Internal nodes: 66420
              1: 32737  2: 14850  3: 10332  4: 4871  5: 2313  6: 942  7: =
371  8: 3  17: 1
            Pointers: 599098
    Null ptrs: 254865
    Total size: 18067  kB
    </blockquote>
   =20
    According to this and other similar reports average depth is slightly
    increased (~0.2), and root nodes are shorter (log 17 vs. 18), but
    there is no visible performance decrease. So, until memory handling i=
s
    improved or added parameters for changing this individually, this
    patch resets to safer defaults.
   =20
    Reported-by: Pawel Staszewski <pstaszewski-n+9KzH4GKXhmR6Xm/wNWPw@public.gmane.org>
    Reported-by: Jorge Boncompte [DTI2] <jorge-hjL/uWR+mxo@public.gmane.org>
    Signed-off-by: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Tested-by: Pawel Staszewski <pstaszewski-n+9KzH4GKXhmR6Xm/wNWPw@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 64c8165b44a91c09b19afb4110610ed242286639
Author: Pablo Bitton <pablo.bitton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Tue Jul 7 19:11:10 2009 -0700

    davinci_emac: fix kernel oops when changing MAC address while interfa=
ce is down
   =20
    Check that network interface is running before changing its MAC addre=
ss.
    Otherwise, rxch is accessed when it's NULL - causing a kernel oops.
    Moreover, check that the new MAC address is valid.
   =20
    Signed-off-by: Pablo Bitton <pablo.bitton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Chaithrika U S <chaithrika-l0cyMroinI0@public.gmane.org>
    Tested-by: Chaithrika U S <chaithrika-l0cyMroinI0@public.gmane.org>
    [tested on DM6467 EVM]
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 19e588e7d156cc4415585edd8c27c3075f62eaf8
Author: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jul 7 13:01:55 2009 +0000

    igb: set lan id prior to configuring phy
   =20
    The igb driver was defaulting to using the lock for pci-e function 0 =
for
    all of the phys due to the fact that the lan id was not being set pri=
or to
    initialization.  This change makes it so that the function id is set =
prior
    to checking for the phy id.
   =20
    Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 44b572809581d5a10dbe35aa6bf689f32b9c5ad6
Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 8 09:50:19 2009 -0700

    x86: don't clear nodes_states[N_NORMAL_MEMORY] when numa is not compi=
led in
   =20
    Alex found that specjbb2005 still can not run with hugepages on an
    x86-64 machine.  This only happens when numa is not compiled in.
   =20
    The root cause: node_set_state will not set it back for us in that ca=
se,
    so don't clear that when numa is not select in config
   =20
    [ v2: use node_clear_state instead ]
    Reported-and-Tested-by: Alex Shi <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Reviewed-by: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit ad361c9884e809340f6daca80d56a9e9c871690a
Author: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date:   Mon Jul 6 13:05:40 2009 -0700

    Remove multiple KERN_ prefixes from printk formats
   =20
    Commit 5fd29d6ccbc98884569d6f3105aeca70858b3e0f ("printk: clean up
    handling of log-levels and newlines") changed printk semantics.  prin=
tk
    lines with multiple KERN_<level> prefixes are no longer emitted as
    before the patch.
   =20
    <level> is now included in the output on each additional use.
   =20
    Remove all uses of multiple KERN_<level>s in formats.
   =20
    Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit e3288775ff63900fbb7db505f2b9a1bee98f07df
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Tue Jul 7 16:39:54 2009 +0100

    tty: maintainers data was edited wrongly by someone
   =20
    Move tty entries to tty not trivial. Noted by David Brownell.
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit d945cb9cce20ac7143c2de8d88b187f62db99bdc
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Tue Jul 7 16:39:41 2009 +0100

    pty: Rework the pty layer to use the normal buffering logic
   =20
    This fixes the ppp problems and various other issues with call lockin=
g
    caused by one side of a pty called in one locking context trying to m=
atch
    another with differing rules on the other side. We also get a big sla=
ck
    space to work with that means we can bury the flow control deadlock c=
ase
    for any conceivable real world situation.
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit b4b21cac88caa4078f5755b0bd3770af5fe9c146
Merge: 728b690fd5c185c639a5db0819bd6e0385b14188 a2e1b4c31257c07f148a89eb7=
eea7ca959fd0642
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:36:46 2009 -0700

    Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git=
/davej/cpufreq
   =20
    * 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpuf=
req:
      [CPUFREQ] Powernow-k8: support family 0xf with 2 low p-states
      [CPUFREQ] fix (utter) cpufreq_add_dev mess
      [CPUFREQ] Cleanup locking in conservative governor
      [CPUFREQ] Cleanup locking in ondemand governor
      [CPUFREQ] Mark policy_rwsem as going static in cpufreq.c wont be ex=
ported
      [CPUFREQ] Eliminate the recent lockdep warnings in cpufreq

commit 728b690fd5c185c639a5db0819bd6e0385b14188
Merge: ed7ba2ef09254b2fd9698708b407f4652d26e36a d01730d74d2b0155da50d4455=
5001706294014f7
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:35:50 2009 -0700

    Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/jack/linux-quota-2.6
   =20
    * 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/l=
inux-quota-2.6:
      quota: Fix possible deadlock during parallel quotaon and quotaoff

commit ed7ba2ef09254b2fd9698708b407f4652d26e36a
Merge: 4b99d3527041bec1abe9903263a3a1b7d2ba0c4a 886a7a3371da8ee46a13f8e59=
8a536bd8765b837
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:35:22 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/rafael/suspend-2.6
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael=
/suspend-2.6:
      PM: Clear -EAGAIN in dpm_prepare
      x86: Fix resume from suspend when CONFIG_CC_STACKPROTECTOR

commit 4b99d3527041bec1abe9903263a3a1b7d2ba0c4a
Author: Sheng Yang <sheng-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Wed Jul 8 11:52:52 2009 +0100

    intel-iommu: Fix intel_iommu_unmap_range() with size 0
   =20
    After some API change, intel_iommu_unmap_range() introduced a assumpt=
ion that
    parameter size !=3D 0, otherwise the dma_pte_clean_range() would have=
 a
    overflowed argument. But the user like KVM don't have this assumption=
 before,
    then some BUG() triggered.
   =20
    Fix it by ignoring size =3D 0.
   =20
    Signed-off-by: Sheng Yang <sheng-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 0f2f2221b4ad816567394a52643963428fd353cd
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Wed Jul 8 11:17:40 2009 +0100

    Free struct device in fw_dev_release()
   =20
    The f_dev in _request_firmware() is allocated via the fw_setup_device=
()
    and fw_register_device() calls and its class set to firmware_class (t=
he
    class release function is fw_dev_release).
   =20
    Commit 6acf70f078ca replaced the kfree(dev) in fw_dev_release() with =
a
    put_device() call but my understanding is that the release function i=
s
    called via put_device -> kobject_put -> kref_put -> koject_release et=
c.
    and it should call kfree since it's the last to see this device
    structure alive.
   =20
    Because of that, the _request_firmware() function on its -ENOENT erro=
r
    path only calls device_unregister(f_dev) which would eventually call
    fw_dev_release() but there is no kfree (the subsequent put_device cal=
l
    would just make the kref negative).
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Acked-by: Cornelia Huck <cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Acked-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit d5ce5b40bc66880d1732461d4b47d7fc3331ed30
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Wed Jul 8 11:17:34 2009 +0100

    Free the memory allocated by memdup_user() in fs/sysfs/bin.c
   =20
    Commit 1c8542c7bb replaced kmalloc() with memdup_user() in the write(=
)
    function but also dropped the kfree(temp). The memdup_user() function
    allocates memory which is never freed.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Cc: Parag Warudkar <parag.warudkar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 5e75c5f5d723074b1ceefe916c3005888e431d12
Merge: d6d4655172f9c5b9402bb453ed9145a7ab5c46d0 eeafa5ef6de5acf678624a21f=
7dba7d43ba73845
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:32:41 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/dtor/input
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/i=
nput:
      Input: gpio_mouse - use standard driver registration method
      Input: mark serio and i8042 as suspended when hibernating too
      Input: add support for generic GPIO-based matrix keypad
      Input: arrange keyboards alphabetically
      Input: gpio-keys - avoid possibility of sleeping in timer function
      Input: gpio-keys - revert 'change timer to workqueue'
      Input: dm355evm_keys - fix kconfig symbol names
      Input: wacom - add DTF720a support and fix rotation on Intuos3
      Input: i8042 - more reset quirks for MSI Wind-clone netbooks

commit d6d4655172f9c5b9402bb453ed9145a7ab5c46d0
Merge: b43f3cbd21ffbd719fd4fa6642bfe6af255ded34 ea96025a26ab8949adab1a8e8=
1419202f92f3f7f
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:32:20 2009 -0700

    Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git=
/benh/powerpc
   =20
    * 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git/benh/power=
pc:
      powerpc: Don't use alloc_bootmem() in init_IRQ() path
      powerpc: Fix spin_event_timeout() to be robust over context switche=
s
      powerpc: Use pr_devel() in do_dcache_icache_coherency()
      powerpc/cell: Use pr_devel() in axon_msi.c
      powerpc: Use pr_devel() in arch/powerpc/mm/gup.c
      powerpc: Cleanup & use pr_devel() in arch/powerpc/mm/slb.c
      powerpc/perf_counter: Remove duplicated #include
      powerpc: Use pr_devel() in arch/powerpc/mm/mmu_context_nohash.c
      powerpc/pseries: Use pr_devel() in xics.c
      powerpc: Remove unnecessary semicolons
      powerpc/pseries: Use pr_devel() in pseries LPAR HPTE routines
      powerpc/44x: Fix build error with -Werror for Warp platform
      powerpc/4xx: Have Warp take advantage of GPIO LEDs default-state =3D=
 keep
      powerpc/44x: Update Warp defconfig

commit b43f3cbd21ffbd719fd4fa6642bfe6af255ded34
Author: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 01:54:37 2009 +0400

    headers: mnt_namespace.h redux
   =20
    Fix various silly problems wrt mnt_namespace.h:
   =20
     - exit_mnt_ns() isn't used, remove it
     - done that, sched.h and nsproxy.h inclusions aren't needed
     - mount.h inclusion was need for vfsmount_lock, but no longer
     - remove mnt_namespace.h inclusion from files which don't use anythi=
ng
       from mnt_namespace.h
   =20
    Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 622f8061a68d3f7a576c20a47b7f3bae7c8cfbef
Merge: 6c96895e999f5c44a95a5cad6a6e32e7bd6e28b6 dd4da3a55f99efbfd46674ebe=
fdcc2878a57ef2a
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:24:01 2009 -0700

    Merge branch 'sh/for-2.6.31' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/lethal/sh-2.6
   =20
    * 'sh/for-2.6.31' of git://git.kernel.org/pub/scm/linux/kernel/git/le=
thal/sh-2.6:
      serial: sh-sci: fix sci interrupt handler
      video: hitfb: Move over to dev_pm_ops.
      video: hitfb: Convert to framebuffer_alloc().
      video: sh_mobile_lcdcfb: Convert to framebuffer_alloc().
      sh: add r8a66597 usb0 host to the se7724 board
      usb: allow sh7724 to enable on-chip r8a66597
      sh-sci: update receive error handling for muxed irqs
      sh: define PERF_COUNTER_INDEX_OFFSET.

commit 6c96895e999f5c44a95a5cad6a6e32e7bd6e28b6
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Wed Jul 8 09:20:11 2009 -0700

    Revert "fb: Initialize fb_info mutexes in framebuffer_alloc()"
   =20
    This reverts commit 4148df9b0f38bdd362dd91d52076926c11cbe5a9.
   =20
    Let's hope that the mm_lock initialization is now correct with all
    drivers, following Krzysztof's patches.
   =20
    Requested-by: Krzysztof Helt <krzysztof.h1-IjDXvh/HVVUAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 99f5d48b98fb52db6da379c1b1fd6c87438ee45a
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Tue Jul 7 22:34:13 2009 +0200

    matroxfb: fix regression with uninitalized fb_info->mm_lock mutex (se=
cond head)
   =20
    Remove redundant locking by the mm_lock mutex before a second head of
    matrox framebuffer is registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit d7272e5bd9ead4389849db9749b8c4dabd459dd1
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Tue Jul 7 22:06:48 2009 +0200

    matroxfb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove redundant call to the matroxfb_update_fix() before matrox
    frambuffer is registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit f1b9c339bf30c90114b7c8f285d25e67c7080f90
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Tue Jul 7 19:24:54 2009 +0200

    w100fb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove redundant call to the w100fb_set_par() before w100 frambuffer =
is
    registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit feaa61e49b126c2206051a234b8f14ccc75b9f61
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Tue Jul 7 19:15:16 2009 +0200

    atafb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove redundant locking of the fb_info->mm_lock mutex before the
    frambuffer is registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 0c8ddf7f8bf770cf49086af85078c4660d387c55
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Tue Jul 7 19:07:57 2009 +0200

    i810fb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove redundant call to the encode_fix() before i810 frambuffer is
    registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit e9bf0cc7cbfbf3952cdf8028aa0d348d09ecdba1
Author: Parag Warudkar <parag.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 11:46:02 2009 -0400

    elfcore.h : Fix UML build breakage
   =20
    Commit a65e7bfcd74e4c0939f235d2bf9f48ddb3a57991 broke the UML build w=
ith
    the following error -
   =20
      In file included from fs/proc/kcore.c:17:
      include/linux/elfcore.h: In function 'elf_core_copy_task_regs':
      include/linux/elfcore.h:129: error: implicit declaration of functio=
n 'task_pt_regs'
   =20
    Fix this by restoring the previous behavior of returning 0 for all ar=
ches
    like UML that don't define task_pt_regs.
   =20
    Signed-off-by: Parag Warudkar <parag.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Acked-by: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 508f711090e06477081fd94cb9298b1b14dda9ff
Author: Darren Salt <linux-Ym6Ivm/Ks7B65+NM0QMiFAbYiX8G1TQY9dF7HbQ/qKg@public.gmane.org>
Date:   Wed Jul 8 15:29:49 2009 +0100

    ALSA: hda - Missing volume controls for Intel HDA (ALC269/EeePC)
   =20
    There is a regression, introduced in aa202455eec51699e44f658530728162=
cefa1307
    (in alsa-kernel) which I noticed when trying to use the headphone soc=
ket on
    my EeeCPC 901: the output was *very* quiet, practically silent.
   =20
    This patch corrects the control types to that which was obviously int=
ended in
    the referenced commit.
   =20
    Signed-off-by: Darren Salt <linux-Ym6Ivm/Ks7B65+NM0QMiFAbYiX8G1TQY9dF7HbQ/qKg@public.gmane.org>
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit ec3a354bd46cbdaa7933ba57a142ee2d2dbde0e5
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:33:01 2009 +0100

    kmemleak: Add callbacks to the bootmem allocator
   =20
    This patch adds kmemleak_alloc/free callbacks to the bootmem allocato=
r.
    This would allow scanning of such blocks and help avoiding a whole cl=
ass
    of false positives and more kmemleak annotations.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Acked-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
    Reviewed-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>

commit 53238a60dd4a679f6fe5613a7ed46899587205cf
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:33:00 2009 +0100

    kmemleak: Allow partial freeing of memory blocks
   =20
    Functions like free_bootmem() are allowed to free only part of a memo=
ry
    block. This patch adds support for this via the kmemleak_free_part()
    callback which removes the original object and creates one or two
    additional objects as a result of the memory block split.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Acked-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>

commit e4f7c0b44a8ac8935f223195af9ea637d0c08091
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:32:59 2009 +0100

    kmemleak: Trace the kmalloc_large* functions in slub
   =20
    The kmalloc_large() and kmalloc_large_node() functions were missed wh=
en
    adding the kmemleak hooks to the slub allocator. However, they should=
 be
    traced to avoid false positives.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Acked-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>

commit 2587362eaf5c9df4e08de11e6340e3c4a88ed4c8
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:32:58 2009 +0100

    kmemleak: Scan objects allocated during a scanning episode
   =20
    Many of the false positives in kmemleak happen on busy systems where
    objects are allocated during a kmemleak scanning episode. These objec=
ts
    aren't scanned by default until the next memory scan. When such objec=
t
    is added, for example, at the head of a list, it is possible that all
    the other objects in the list become unreferenced until the next scan.
   =20
    This patch adds checking for newly allocated objects at the end of th=
e
    scan and repeats the scanning on these objects. If Linux allocates
    new objects at a higher rate than their scanning, it stops after a
    predefined number of passes.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>

commit b87324d082d9d898e3c06b2a07a2b94b2430b8ba
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:32:58 2009 +0100

    kmemleak: Do not acquire scan_mutex in kmemleak_open()
   =20
    Initially, the scan_mutex was acquired in kmemleak_open() and release=
d
    in kmemleak_release() (corresponding to /sys/kernel/debug/kmemleak
    operations). This was causing some lockdep reports when the file was
    closed from a different task than the one opening it. This patch move=
s
    the scan_mutex acquiring in kmemleak_write() or kmemleak_seq_start()
    with releasing in kmemleak_seq_stop().
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>

commit 288c857d66a400ca4846dd700eb1c4820d738bb9
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:32:57 2009 +0100

    kmemleak: Remove the reported leaks number limitation
   =20
    Since the leaks are no longer printed to the syslog, there is no poin=
t
    in keeping this limitation. All the suspected leaks are shown on
    /sys/kernel/debug/kmemleak file.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>

commit 886a7a3371da8ee46a13f8e598a536bd8765b837
Author: Sebastian Ott <sebott-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Wed Jul 8 13:26:05 2009 +0200

    PM: Clear -EAGAIN in dpm_prepare
   =20
    When the last device in the dpm list is unregistered directly after i=
ts
    prepare() callback returned with -EAGAIN, the return code is passed t=
o
    the calling function, resulting in a suspend failure. Prevent this by
    clearing the return code after -EAGAIN.
   =20
    Signed-off-by: Sebastian Ott <sebott-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>

commit 00024be9689963c55cf2ab10ce3fb4502016c09a
Author: Peter Chubb <peter.chubb-3w/jM7ZMsnj0CCvOHzKKcA@public.gmane.org>
Date:   Wed Jul 8 13:20:13 2009 +0200

    x86: Fix resume from suspend when CONFIG_CC_STACKPROTECTOR
   =20
    Patch 08687aec71bc9134fe336e561f6did877bacf74fc0a (x86: unify
    power/cpu_(32|64).c)  renamed cpu_32.c to cpu.c, but did not update
    the special compilation flags for the file for the new name.
   =20
    This patch fixes the compilation flags, and therefore fixes resume
    from suspend on my Acer Aspire One.
   =20
    [rjw: The regression from 2.6.30 fixed by this patch is tracked as
     http://bugzilla.kernel.org/show_bug.cgi?id=3D13661]
   =20
    Signed-off-by: Peter Chubb <peterc-3w/jM7ZMsnj0CCvOHzKKcA@public.gmane.org>
    Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>

commit 83c2099f5e1f0a4621ed4f20fc539069c636a24b
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 8 10:15:41 2009 +0300

    UBI: fix compilation warnings
   =20
    The recent "UBI: fix NOR flash recovery" introduced compilation
    warnings which were immediately spotted by our linux-next keeper.
    This patch fixes them.
   =20
    Reported-by: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit dc4c2e6bde77735071dbef7aca6bd6c0116102b3
Author: Andiry Brienza <andiry.xu-5C7GfCeVMHo@public.gmane.org>
Date:   Wed Jul 8 13:55:31 2009 +0800

    ALSA: hda - Disable AMD SB600 64bit address support only
   =20
    HDA driver disabled HD audio 64bit address support for all AMD
    SB600/SB700/SB800 platforms with commit
    09240cf429505891d6123ce14a29f58f2a60121e due to one SB600 issue
    reported by community, but we do not see the similar issue on
    SB700/SB800 platforms.
    This patch is to refine the workaround for SB600 only.
   =20
    Signed-off-by: Andiry Xu <andiry.xu-5C7GfCeVMHo@public.gmane.org>
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit eeafa5ef6de5acf678624a21f7dba7d43ba73845
Author: Saeed Bishara <saeed-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Date:   Tue Jul 7 22:11:52 2009 -0700

    Input: gpio_mouse - use standard driver registration method
   =20
    This patch is needed when the gpio's became available only at late
    stages, for example, when using i2c gpio expander.
   =20
    Signed-off-by: Saeed Bishara <saeed-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit ddaa43433dd77535e4e132787f199f58ce224f44
Author: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org>
Date:   Tue Jul 7 22:10:02 2009 -0700

    Input: mark serio and i8042 as suspended when hibernating too
   =20
    Serio ports are not being restarted any longer because resume operati=
ons
    after hibernate do nothing, since the device has not been marked as
    suspended. This happens because suspend is only considering the SUSPE=
ND
    event but not the FREEZE event.
   =20
    Note that this driver has still to migrate to dev_pm_ops, but this fi=
xes
    this particular bug now.
   =20
    Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org=
>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit 1c55d521f4e58be55735d7ac47e8197d6791fa9a
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Wed Jul 8 07:45:46 2009 +0200

    ALSA: hda - Check widget types while parsing capture source in patch_=
via.c
   =20
    Check the widget type and don't take invalid widgets while parsing
    the capture source in patch_via.c.
   =20
    Also, fixed some compile warnings introduced in the previous commit.
   =20
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit ea96025a26ab8949adab1a8e81419202f92f3f7f
Author: Anton Vorontsov <avorontsov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Date:   Wed Jul 1 10:59:57 2009 +0000

    powerpc: Don't use alloc_bootmem() in init_IRQ() path
   =20
    This patch fixes various badnesses like this for all interrupt
    controllers:
   =20
    ------------[ cut here ]------------
    Badness at c04db9dc [verbose debug info unavailable]
    NIP: c04db9dc LR: c04db9ac CTR: 00000000
    REGS: c053de30 TRAP: 0700   Not tainted  (2.6.31-rc1-00432-ge69b2b5-d=
irty)
    MSR: 00021000 <ME,CE>  CR: 22020084  XER: 00000000
    TASK =3D c0500480[0] 'swapper' THREAD: c053c000
    GPR00: 00000001 c053dee0 c0500480 00000000 00000050 00000020 3fffffff=
 00000000
    GPR08: 00000001 c0540000 e0080080 00000000 22000084 64183600 3ff8f800=
 00000000
    GPR16: 841b0240 449a0303 00000000 00000000 00000000 00000000 00000000=
 c04f5bf4
    GPR24: 00000000 00000000 00000000 00000050 00000020 00000000 3fffffff=
 00000050
    NIP [c04db9dc] alloc_arch_preferred_bootmem+0x48/0x74
    LR [c04db9ac] alloc_arch_preferred_bootmem+0x18/0x74
    Call Trace:
    [c053dee0] [c000a5a4] __of_address_to_resource+0x44/0xd0 (unreliable)
    [c053def0] [c04dba58] ___alloc_bootmem_nopanic+0x50/0x108
    [c053df20] [c04dbb28] ___alloc_bootmem+0x18/0x50
    [c053df30] [c04d5de0] qe_ic_init+0x5c/0x1b0
    [c053df70] [c04d77b0] mpc85xx_mds_pic_init+0xb8/0x10c
    [c053dfb0] [c04cf374] init_IRQ+0x28/0x3c
   =20
    p.s. commit 85355bb272db31a3f2dd99d547eef794805e1319 ("powerpc: Fix
    mpic alloc warning") missed some alloc_bootmem() instances, this is
    now fixed.
   =20
    Signed-off-by: Anton Vorontsov <avorontsov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
    Acked-by: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit ad9064d5e22a6a24f828dad63c4775c4d7280bd4
Author: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Date:   Mon Jun 29 13:40:51 2009 +0000

    powerpc: Fix spin_event_timeout() to be robust over context switches
   =20
    Current implementation of spin_event_timeout can be interrupted by an
    IRQ or context switch after testing the condition, but before checkin=
g
    the timeout.  This can cause the loop to report a timeout when the
    condition actually became true in the middle.
   =20
    This patch adds one final check of the condition upon exit of the loo=
p
    if the last test of the condition was still false.
   =20
    Signed-off-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
    Acked-by: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 30c5af435b2e3e5700b0e4a53ac37a39b3b3516e
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:52 2009 +0000

    powerpc: Use pr_devel() in do_dcache_icache_coherency()
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text    data     bss     dec     hex filename
       2036     368       8    2412     96c arch/powerpc/mm/pgtable.o
   =20
    size after:
       text    data     bss     dec     hex filename
       1677     248       8    1933     78d arch/powerpc/mm/pgtable.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 33875f03307452650309a7d071678b2ca5f2fc26
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:53 2009 +0000

    powerpc/cell: Use pr_devel() in axon_msi.c
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text    data     bss     dec     hex filename
       7083    1616       0    8699    21fb arch/powerpc/../axon_msi.o
   =20
    size after:
       text    data     bss     dec     hex filename
       5772    1208       0    6980    1b44 arch/powerpc/../axon_msi.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 29e5fa59e5ebe06d6bd7e04e7752a47ead23f89e
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:51 2009 +0000

    powerpc: Use pr_devel() in arch/powerpc/mm/gup.c
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text    data     bss     dec     hex filename
       3252     384       0    3636     e34 arch/powerpc/mm/gup.o
   =20
    size after:
       text    data     bss     dec     hex filename
       2576      96       0    2672     a70 arch/powerpc/mm/gup.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 651e2dd2a1c47bb078d446f123a9ae950ba7a1f0
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:51 2009 +0000

    powerpc: Cleanup & use pr_devel() in arch/powerpc/mm/slb.c
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text    data     bss     dec     hex filename
       3261     416       4    3681     e61 arch/powerpc/mm/slb.o
   =20
    size after:
       text    data     bss     dec     hex filename
       2861     248       4    3113     c29 arch/powerpc/mm/slb.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 3665ee36fac936b2ad0ab170d101a3e2c8eb3fd2
Author: Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sat Jun 20 13:37:00 2009 +0000

    powerpc/perf_counter: Remove duplicated #include
   =20
    Remove duplicated #include('s) in
      arch/powerpc/kernel/mpc7450-pmu.c
      arch/powerpc/kernel/ppc970-pmu.c
   =20
    Signed-off-by: Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit a1ac38ab98e8a79ce225347b725f3b9751c70f1e
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:54 2009 +0000

    powerpc: Use pr_devel() in arch/powerpc/mm/mmu_context_nohash.c
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text	   data	    bss	    dec	    hex	filename
       1508	     48	     28	   1584	    630	powerpc/mm/mmu_context_nohash=
.o
   =20
    size after:
       text	   data	    bss	    dec	    hex	filename
       1088	      0	     28	   1116	    45c	powerpc/mm/mmu_context_nohash=
.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit b69e9e931d2c6116921fdb260684e0546285c3c8
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:53 2009 +0000

    powerpc/pseries: Use pr_devel() in xics.c
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text    data     bss     dec     hex filename
       7720    5488     296   13504    34c0 platforms/pseries/xics.o
   =20
    size after:
       text    data     bss     dec     hex filename
       7535	   5456	    296	  13287	   33e7	platforms/pseries/xics.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit d258e64ef595792d6f749518354b69583e9a97f4
Author: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date:   Sun Jun 28 06:26:10 2009 +0000

    powerpc: Remove unnecessary semicolons
   =20
    Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Acked-by: Geoff Levand <geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 551a232c87b7781712c57c31f3e0851303d9f591
Author: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Date:   Wed Jun 17 18:13:50 2009 +0000

    powerpc/pseries: Use pr_devel() in pseries LPAR HPTE routines
   =20
    pr_debug() can now result in code being generated even when DEBUG
    is not defined. That's not really desirable in some places.
   =20
    In particular, pSeries_lpar_hpte_insert() goes from 185 instructions
    to 77 instructions as a result of this patch. Luckily that code
    isn't called very often ...
   =20
    With CONFIG_DYNAMIC_DEBUG=3Dy:
   =20
    size before:
       text    data     bss     dec     hex filename
       7284    1552     296    9132    23ac platforms/pseries/lpar.o
   =20
    size after:
       text    data     bss     dec     hex filename
       5806    1096     296    7198    1c1e platforms/pseries/lpar.o
   =20
    Signed-off-by: Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
    Signed-off-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>

commit 01cc82623aea0b96ee2cba4534d1954ad793cfc3
Merge: faf80d62e44dc627efb741f48db50c1858d1667c a22ebd069d5b533392e9bef77=
b73147a2f82b30b
Author: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date:   Wed Jul 8 13:49:38 2009 +1000

    Merge commit 'jwb/merge' into merge

commit a17458fc9d9edc98b7c5865cdc42681cf9059f1c
Author: Ben Gamari <bgamari.foss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 15:01:36 2009 -0400

    drm/i915: Move lock to more reasonable location
   =20
    Make this consistent with the unlock statement. Also fix a
    minor typo in debugfs formatting
   =20
    Signed-off-by: Ben Gamari <bgamari.foss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit a01c75b338d7c743a8982011f01a4714ad2956de
Author: Ben Gamari <bgamari.foss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 15:01:35 2009 -0400

    drm/i915: Add gtt_offset to gem object list debugfs output
   =20
    This is quite useful for verifying that objects are actually mapped w=
hen
    they need to be.
   =20
    Signed-off-by: Ben Gamari <bgamari.foss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit b5323599af68caa2da08b7041400b62049afb91e
Author: Ben Gamari <bgamari.foss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 15:01:34 2009 -0400

    drm/i915: Remove gtt_bound from drm_i915_gem_object
   =20
    This wasn't even used as far as I could tell and will only confuse
    people (like me).
   =20
    Signed-off-by: Ben Gamari <bgamari.foss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit febc7694a55277b70cd662de05ed8a957685959c
Author: ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jun 25 11:55:57 2009 +0800

    drm/i915: Disable VGA output when doing DRM_MODE_DPMS_OFF.
   =20
    Signed-off-by: Ma Ling <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 8e4d36b993898b344f9176147f1dfeca583f81fd
Author: ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 30 11:35:34 2009 +0800

    drm/i915: crt fetch EDID by DVI-I converter on G4x platform
   =20
    Usually crt mainly get modes via GPIOA ports.
    However on G4X platform we need to probe possible
    ports for DVI-I, which could be wired to GPIOD,
    then fetch our desired EDID, i.e on DG45ID platform
    we successfully fetch EDID by GPIOD port.
   =20
    It fixed freedesktop.org bug #21084
   =20
    Signed-off-by: Ma Ling <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 22bd50c5b9aaf46476cade52c4ae9afa21c44e15
Author: Zhenyu Wang <zhenyuw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Mon Jul 6 17:27:52 2009 +0800

    drm/i915: Don't update display FIFO watermark on IGDNG
   =20
    Signed-off-by: Zhenyu Wang <zhenyuw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 3938b45c1c75e53d45eb65ac253f12e86239c9ba
Author: Luciano Coelho <luciano.coelho-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 08:25:08 2009 +0300

    mac80211: minstrel: avoid accessing negative indices in rix_to_ndx()
   =20
    If rix is not found in mi->r[], i will become -1 after the loop.  Thi=
s value
    is eventually used to access arrays, so we were accessing arrays with=
 a
    negative index, which is obviously not what we want to do.  This patc=
h fixes
    this potential problem.
   =20
    Signed-off-by: Luciano Coelho <luciano.coelho-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Acked-by: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 2dce4c2b5f0b43bd25bf9ea6ded06b7f8a54c91f
Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date:   Thu Jul 2 15:46:41 2009 +0200

    cfg80211: fix refcount leak
   =20
    The code in cfg80211's cfg80211_bss_update erroneously
    grabs a reference to the BSS, which means that it will
    never be freed.
   =20
    Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org [2.6.29, 2.6.30]
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 76d8b64e536362e16e38ee1c279c965ebfe094cc
Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date:   Mon Jun 29 10:53:53 2009 +0200

    hp-wmi: fix rfkill bug
   =20
    Fix the third (I think) polarity error I accidentally
    introduced in the rfkill rewrite to make wireless work
    again on (certain?) HP laptops.
   =20
    Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
    Tested-by: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 59615b5f9d1323898ca94e88e595b5b04115076a
Author: Andrey Yurovsky <andrey-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Date:   Thu Jun 25 16:07:42 2009 -0700

    mac80211: fix allocation in mesh_queue_preq
   =20
    We allocate a PREQ queue node in mesh_queue_preq, however the allocat=
ion
    may cause us to sleep.  Use GFP_ATOMIC to prevent this.
   =20
    [ 1869.126498] BUG: scheduling while atomic: ping/1859/0x10000100
    [ 1869.127164] Modules linked in: ath5k mac80211 ath
    [ 1869.128310] Pid: 1859, comm: ping Not tainted 2.6.30-wl #1
    [ 1869.128754] Call Trace:
    [ 1869.129293]  [<c1023a2b>] __schedule_bug+0x48/0x4d
    [ 1869.129866]  [<c13b5533>] __schedule+0x77/0x67a
    [ 1869.130544]  [<c1026f2e>] ? release_console_sem+0x17d/0x185
    [ 1869.131568]  [<c807cf47>] ? mesh_queue_preq+0x2b/0x165 [mac80211]
    [ 1869.132318]  [<c13b5b3e>] schedule+0x8/0x1f
    [ 1869.132807]  [<c1023c12>] __cond_resched+0x16/0x2f
    [ 1869.133478]  [<c13b5bf0>] _cond_resched+0x27/0x32
    [ 1869.134191]  [<c108a370>] kmem_cache_alloc+0x1c/0xcf
    [ 1869.134714]  [<c10273ae>] ? printk+0x15/0x17
    [ 1869.135670]  [<c807cf47>] mesh_queue_preq+0x2b/0x165 [mac80211]
    [ 1869.136731]  [<c807d1f8>] mesh_nexthop_lookup+0xee/0x12d [mac80211=
]
    [ 1869.138130]  [<c807417e>] ieee80211_xmit+0xe6/0x2b2 [mac80211]
    [ 1869.138935]  [<c80be46d>] ? ath5k_hw_setup_rx_desc+0x0/0x66 [ath5k=
]
    [ 1869.139831]  [<c80c97bc>] ? ath5k_tasklet_rx+0xba/0x506 [ath5k]
    [ 1869.140863]  [<c8075191>] ieee80211_subif_start_xmit+0x6c9/0x6e4
    [mac80211]
    [ 1869.141665]  [<c105cf1c>] ? handle_level_irq+0x78/0x9d
    [ 1869.142390]  [<c12e3f93>] dev_hard_start_xmit+0x168/0x1c7
    [ 1869.143092]  [<c12f1f17>] __qdisc_run+0xe1/0x1b7
    [ 1869.143612]  [<c12e25ff>] qdisc_run+0x18/0x1a
    [ 1869.144248]  [<c12e62f4>] dev_queue_xmit+0x16a/0x25a
    [ 1869.144785]  [<c13b6dcc>] ? _read_unlock_bh+0xe/0x10
    [ 1869.145465]  [<c12eacdb>] neigh_resolve_output+0x19c/0x1c7
    [ 1869.146182]  [<c130e2da>] ? ip_finish_output+0x0/0x51
    [ 1869.146697]  [<c130e2a0>] ip_finish_output2+0x182/0x1bc
    [ 1869.147358]  [<c130e327>] ip_finish_output+0x4d/0x51
    [ 1869.147863]  [<c130e9d5>] ip_output+0x80/0x85
    [ 1869.148515]  [<c130cc49>] dst_output+0x9/0xb
    [ 1869.149141]  [<c130dec6>] ip_local_out+0x17/0x1a
    [ 1869.149632]  [<c130e0bc>] ip_push_pending_frames+0x1f3/0x255
    [ 1869.150343]  [<c13247ff>] raw_sendmsg+0x5e6/0x667
    [ 1869.150883]  [<c1033c55>] ? insert_work+0x6a/0x73
    [ 1869.151834]  [<c8071e00>] ?
    ieee80211_invoke_rx_handlers+0x17da/0x1ae8 [mac80211]
    [ 1869.152630]  [<c132bd68>] inet_sendmsg+0x3b/0x48
    [ 1869.153232]  [<c12d7deb>] __sock_sendmsg+0x45/0x4e
    [ 1869.153740]  [<c12d8537>] sock_sendmsg+0xb8/0xce
    [ 1869.154519]  [<c80be46d>] ? ath5k_hw_setup_rx_desc+0x0/0x66 [ath5k=
]
    [ 1869.155289]  [<c1036b25>] ? autoremove_wake_function+0x0/0x30
    [ 1869.155859]  [<c115992b>] ? __copy_from_user_ll+0x11/0xce
    [ 1869.156573]  [<c1159d99>] ? copy_from_user+0x31/0x54
    [ 1869.157235]  [<c12df646>] ? verify_iovec+0x40/0x6e
    [ 1869.157778]  [<c12d869a>] sys_sendmsg+0x14d/0x1a5
    [ 1869.158714]  [<c8072c40>] ? __ieee80211_rx+0x49e/0x4ee [mac80211]
    [ 1869.159641]  [<c80c83fe>] ? ath5k_rxbuf_setup+0x6d/0x8d [ath5k]
    [ 1869.160543]  [<c80be46d>] ? ath5k_hw_setup_rx_desc+0x0/0x66 [ath5k=
]
    [ 1869.161434]  [<c80beba4>] ? ath5k_hw_get_rxdp+0xe/0x10 [ath5k]
    [ 1869.162319]  [<c80c97bc>] ? ath5k_tasklet_rx+0xba/0x506 [ath5k]
    [ 1869.163063]  [<c1005627>] ? enable_8259A_irq+0x40/0x43
    [ 1869.163594]  [<c101edb8>] ? __dequeue_entity+0x23/0x27
    [ 1869.164793]  [<c100187a>] ? __switch_to+0x2b/0x105
    [ 1869.165442]  [<c1021d5f>] ? finish_task_switch+0x5b/0x74
    [ 1869.166129]  [<c12d963a>] sys_socketcall+0x14b/0x17b
    [ 1869.166612]  [<c1002b95>] syscall_call+0x7/0xb
   =20
    Signed-off-by: Andrey Yurovsky <andrey-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit a7a4e41ed62a6a1fce6eb503c920f615eca27f02
Author: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Wed Jun 24 16:07:22 2009 +0200

    iwmc3200wifi: add Kconfig help
   =20
    We're missing a Kconfig help for the iwmc3200wifi driver.
   =20
    Signed-off-by: Samuel Ortiz <samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit cbfe89c67b58e2bd1b47f6986b3b793f06f3d9b0
Author: Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Date:   Wed Jun 24 18:58:47 2009 +0530

    ath9k: Fix leak in tx descriptor
   =20
    When we reclaim the tx desc, we always assume that the
    last desc is a holding desc, which is not true, and skip it.
    If the tx queue is drained during channel change, internal
    reset and etc, the last descriptor may not be the holding
    descriptor and we fail to reclaim them. This results in the
    following two issues.
   =20
    1. Tx stuck - We drop all the frames coming from upper layer
    due to shortage in tx desc.
   =20
    2. Crash - If we fail to reclaim a tx descriptor, we miss to
    update the tx BA window with the seq number of the frame
    associated to that desc, which, at some point, result in
    the following crash due to an assert failure in ath_tx_addto_baw().
   =20
    This patch fixes these two issues.
   =20
     kernel BUG at ../drivers/net/wireless/ath/ath9k/xmit.c:180!
    [155064.304164] invalid opcode: 0000 [#1] SMP
     Call Trace:
      [<fbc6d83b>] ? ath9k_tx+0xeb/0x160 [ath9k]
      [<fbbc9591>]  ipv6? __ieee80211_tx+0x41/0x120 [mac80211]
      [<fbbcb5ae>] ?  aes_i586ieee80211_master_start_xmit+0x28e/0x560 [ma=
c80211]
      [<c037e501>]  aes_generic? _spin_lock_irqsave+0x31/0x40
      [<c02f347b>] ? dev_hard_start_xmit+0x16b/0x1c0
      [<c03058b5>] ? __qdisc_run+0x1b5/0x200
      [<fbbcda5a>] ?  af_packetieee80211_select_queue+0xa/0x100 [mac80211=
]
      [<c02f53b7>] ?  i915dev_queue_xmit+0x2e7/0x3f0
      [<fbbc9b49>] ? ieee80211_subif_start_xmit+0x369/0x7a0 [mac80211]
      [<c031bc35>] ? ip_output+0x55/0xb0
      [<c02e0188>] ? show_memcpy_count+0x18/0x60
      [<c02eb186>] ? __kfree_skb+0x36/0x90
      [<c02f2202>] ?  binfmt_miscdev_queue_xmit_nit+0xd2/0x110
      [<c02f347b>] ? dev_hard_start_xmit+0x16b/0x1c0
      [<c03058b5>] ? __qdisc_run+0x1b5/0x200
      [<c033bca7>] ?  scoarp_create+0x57/0x2a0
      [<c02f53b7>] ?  bridgedev_queue_xmit+0x2e7/0x3f0
      [<c03034a0>] ? eth_header+0x0/0xc0
      [<c033b95f>]  stp? arp_xmit+0x5f/0x70
      [<c033bf4f>] ? arp_send+0x5f/0x70
      [<c033c8f5>]  bnep? arp_solicit+0x105/0x210
      [<c02fa5aa>] ? neigh_timer_handler+0x19a/0x390
      [<c013bf88>] ? run_timer_softirq+0x138/0x210
      [<c02fa410>] ?  ppdevneigh_timer_handler+0x0/0x390
      [<c02fa410>] ? neigh_timer_handler+0x0/0x390
   =20
    Signed-off-by: Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit fd4973c56f8d9baac8d269791a90e5119ce30a0e
Author: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date:   Sat Jun 20 12:58:11 2009 -0500

    b43/b43legacy: fix radio LED initialization
   =20
    Fix condition in which radio LED did not initialize correctly, and re=
move
    4 compilation warnings.
   =20
    After the recent changes in rfkill, the radio LED used by b43/b43lega=
cy
    did not always initialize correctly.
   =20
    Both b43 and b43legacy used the deprecated variable radio_enabled in
    struct ieee80211_conf.
   =20
    Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 1f5fc70a250cc18f066072119e9fbbc20dad865f
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sat Jun 20 12:31:11 2009 +0200

    Wireless: nl80211, fix lock imbalance
   =20
    Don't forget to unlock cfg80211_mutex in one fail path of
    nl80211_set_wiphy.
   =20
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit 337b9d02b4873ceac91565272545fb6fd446d939
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Tue Jul 7 18:18:59 2009 +0200

    ALSA: hda - Fix capture source selection in patch_via.c
   =20
    The fixed widget NIDs in patch_via.c seem wrong for some codecs,
    and it resulted in the invalid capture source selection.
   =20
    This patch adds the code to parse the topology instead of using
    fixed numbers in order to get the right MUX widget id corresponding
    to the ADCs.
   =20
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit d01730d74d2b0155da50d44555001706294014f7
Author: Jiaying Zhang <jiayingz-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 18:15:21 2009 +0200

    quota: Fix possible deadlock during parallel quotaon and quotaoff
   =20
    The following test script triggers a deadlock on ext2 filesystem:
    while true; do quotaon /dev/hda >&/dev/null; usleep $RANDOM; done &
    while true; do quotaoff /dev/hda >&/dev/null; usleep $RANDOM; done &
   =20
    I found there is a potential deadlock between quotaon and quotaoff (o=
r
    quotasync). Basically, all of quotactl operations need to be protecte=
d by
    dqonoff_mutex. vfs_quota_off and vfs_quota_sync also call sb->s_op->q=
uota_write
    that needs to grab the i_mutex of the quota file.  But in vfs_quota_o=
n_inode
    (called from quotaon operation), the current code tries to grab  the =
i_mutex of
    the quota file first before getting quonoff_mutex.
   =20
    Reverse the order in which we take locks in vfs_quota_on_inode().
   =20
    Jan Kara: Changed changelog to be more readable, made lockdep happy w=
ith
      I_MUTEX_QUOTA.
   =20
    Signed-off-by: Jiaying Zhang <jiayingz-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>

commit 07606309ff5a9136e340b9ca87c831650c1ec47a
Author: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:13 2009 +0200

    [S390] define KTIME_SCALAR for 32-bit s390
   =20
    32-bit s390 has efficient support for 64/32-bit conversions, define
    KTIME_SCALAR to enable the use of the plain scalar nanosecond based
    representation of ktime.
   =20
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit 25ca1251dc55673da1f3c6ddc1bf93fbb7fc83fc
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:12 2009 +0200

    [S390] add generic atomic64 support for 31 bit
   =20
    Performance counters need 64 bit atomic operations.
    To keep the patch small we use the simple generic atomic64_t implemen=
tation.
    The native implementation follows with the next kernel.
   =20
    Fixes this build bug:
   =20
    In file included from kernel/sched.c:42:
    include/linux/perf_counter.h:427: error: expected specifier-qualifier=
-list before 'atomic64_t'
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit 2c48c4d631970b70d60a4f926b0f68f194a0d559
Author: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:11 2009 +0200

    [S390] improve suspend/resume error messages
   =20
    From: Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
   =20
    Signed-off-by: Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit fca3e357d5de31e484c3e0ec7f356e4fc488eb7f
Author: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:10 2009 +0200

    [S390] set SCHED_OMIT_FRAME_POINTER for s390
   =20
    The frame pointer is useless for s390 in the sched.c code.
   =20
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit 5075baca2e95840d76210c3cfda56134007462c9
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:09 2009 +0200

    [S390] add __ucmpdi2() helper function
   =20
    Provide __ucmpdi2() helper function on 31 bit so we don't run
    again and again in compile errors like this one:
   =20
    kernel/built-in.o: In function `T.689':
    perf_counter.c:(.text+0x56c86): undefined reference to `__ucmpdi2'
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit 2651fa2bcb1a7b06793441d50dcbf98efda592c6
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:08 2009 +0200

    [S390] perf_counter build fix
   =20
    Add PERF_COUNTER_INDEX_OFFSET define to fix this build bug:
   =20
    kernel/perf_counter.c: In function 'perf_counter_index':
    kernel/perf_counter.c:1889: error: 'PERF_COUNTER_INDEX_OFFSET' undecl=
ared
   =20
    Same fix as for FRV since s390 doesn't support hw counters.
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit 81088819d588ba4d2dce3bf083fafc91974b14e0
Author: Frank Munzert <munzert-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:07 2009 +0200

    [S390] shutdown actions: save/return rc from init function
   =20
    We always returned -EINVAL when setting of a shutdown action failed. =
This was
    misleading, if for example the hardware did not support the shutdown =
action.
    Now we save each shutdown action's init return code and return it whe=
n the
    action is being set.
   =20
    Signed-off-by: Frank Munzert <munzert-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit aeec92ca3a1d5ca96efe76988fd4df943a90300d
Author: Stefan Haberland <stefan.haberland-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:06 2009 +0200

    [S390] dasd: correct debugfeature sense dump
   =20
    remove loop, add some debug data and use get_sense function
   =20
    Signed-off-by: Stefan Haberland <stefan.haberland-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit bb8c29caffdda55d3df0315ff2485f7df7290b1d
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:05 2009 +0200

    [S390] udelay: disable lockdep to avoid false positives
   =20
    Our udelay implementation enables interrupts to receive a special tim=
er
    interrupt regardless of the context it is called from.
    This might lead to false positive lockdep reports. Since lockdep isn'=
t
    aware of the fact that only a single interrupt source is enabled it
    warns about possible deadlocks that in reality won't happen, like
    the one below.
    To fix this disable lockdep before enabling interrupts.
   =20
    [ 254.040888] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
    [ 254.040904] [ INFO: inconsistent lock state ]
    [ 254.040910] 2.6.30 #9
    [ 254.040914] ---------------------------------
    [ 254.040920] inconsistent {IN-HARDIRQ-W} -> {HARDIRQ-ON-W} usage.
    [ 254.040927] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
    [ 254.040934] (sch->lock){?.-...}, at: [<00000000002e4778>] ccw_devic=
e_timeout+0x48/0x2f0
    [ 254.040961] {IN-HARDIRQ-W} state was registered at:
    [ 254.040969] [<0000000000096f74>] __lock_acquire+0x9d4/0x188c
    [ 254.040985] [<0000000000097f68>] lock_acquire+0x13c/0x16c
    [ 254.040998] [<00000000004527e0>] _spin_lock+0x74/0xb8
    [ 254.041016] [<0000000000457eb2>] do_IRQ+0xde/0x208
    [ 254.041031] [<000000000002d190>] io_return+0x0/0x8
    [ 254.041049] [<0000000000029faa>] vtime_stop_cpu+0xbe/0x114
    [ 254.041066] irq event stamp: 259629
    [ 254.041076] hardirqs last enabled at (259628): [<000000000045238e>]=
 _spin_unlock_irq+0x5e/0x9c
    [ 254.041095] hardirqs last disabled at (259629): [<000000000045292e>=
] _spin_lock_irq+0x4a/0xc4
    [ 254.041126] softirqs last enabled at (259614): [<000000000006500e>]=
 __do_softirq+0x296/0x2b0
    [ 254.041137] softirqs last disabled at (259619): [<0000000000024cf6>=
] do_softirq+0x102/0x108
    [ 254.041147]
    [ 254.041148] other info that might help us debug this:
    [ 254.041153] 2 locks held by swapper/0:
    [ 254.041157] #0: (&priv->timer){+.-...}, at: [<000000000006bf9a>] ru=
n_timer_softirq+0x19a/0x340
    [ 254.041170] #1: (sch->lock){?.-...}, at: [<00000000002e4778>] ccw_d=
evice_timeout+0x48/0x2f0
    [ 254.041182]
    [ 254.041310] Call Trace:
    [ 254.041313] ([<00000000000174fc>] show_trace+0x16c/0x170)
    [ 254.041321] [<0000000000017578>] show_stack+0x78/0x104
    [ 254.041327] [<000000000044d0ca>] dump_stack+0xc6/0xd4
    [ 254.041342] [<00000000000949b4>] print_usage_bug+0x1c8/0x1fc
    [ 254.041353] [<0000000000094e8a>] mark_lock+0x4a2/0x670
    [ 254.041364] [<00000000000950e2>] mark_held_locks+0x8a/0xb4
    [ 254.041375] [<0000000000095398>] trace_hardirqs_on_caller+0x74/0x1a=
c
    [ 254.041388] [<00000000000954fa>] trace_hardirqs_on+0x2a/0x38
    [ 254.041402] [<000000000025f1ec>] __udelay_disabled+0xac/0xfc
    [ 254.041419] [<000000000025f432>] __udelay+0x12a/0x148
    [ 254.041433] [<00000000002d64d8>] cio_commit_config+0x170/0x290
    [ 254.041451] [<00000000002d6978>] cio_disable_subchannel+0x120/0x1cc
    [ 254.041468] [<00000000002e32a4>] ccw_device_recog_done+0x54/0x2f4
    [ 254.041485] [<00000000002e3638>] ccw_device_sense_id_done+0x50/0x90
    [ 254.041508] [<00000000002e615a>] snsid_callback+0xfa/0x3a8
    [ 254.041515] [<00000000002dd96c>] ccwreq_stop+0x80/0x90
    [ 254.041523] [<00000000002dda8e>] ccw_request_timeout+0xc2/0xd0
    [ 254.041530] [<00000000002e2f70>] ccw_device_request_event+0x58/0x90
    [ 254.041537] [<00000000002e47ae>] ccw_device_timeout+0x7e/0x2f0
    [ 254.041555] [<000000000006c02a>] run_timer_softirq+0x22a/0x340
    [ 254.041566] [<0000000000064eb0>] __do_softirq+0x138/0x2b0
    [ 254.041578] [<0000000000024cf6>] do_softirq+0x102/0x108
    [ 254.041590] [<00000000000647ce>] irq_exit+0xee/0x114
    [ 254.041603] [<0000000000457d88>] do_extint+0x130/0x17c
    [ 254.041617] [<000000000002d41e>] ext_no_vtime+0x1e/0x22
    [ 254.041631] [<0000000000029faa>] vtime_stop_cpu+0xbe/0x114
    [ 254.041646] ([<0000000000029f58>] vtime_stop_cpu+0x6c/0x114)
    [ 254.041662] [<000000000001d842>] cpu_idle+0x122/0x1c0
    [ 254.041679] [<00000000004482c6>] start_secondary+0xce/0xe0
    [ 254.041696] [<0000000000000000>] 0x0
    [ 254.041715] [<0000000000000000>] 0x0
    [ 254.041745] INFO: lockdep is turned off.
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit 9935774217afd4cdda81ffd70e56dc6406710b06
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:04 2009 +0200

    [S390] monreader: fix dev_set_drvdata conversion
   =20
    Fix this:
   =20
    drivers/s390/char/monreader.c: In function 'mon_open':
    drivers/s390/char/monreader.c:323: warning: passing argument 1 of 'de=
v_set_drvdata' from incompatible pointer type
    include/linux/device.h:457: note: expected 'struct device *' but argu=
ment is of type 'struct device **'
    drivers/s390/char/monreader.c: In function 'monreader_freeze':
    drivers/s390/char/monreader.c:466: warning: passing argument 1 of 'de=
v_get_drvdata' from incompatible pointer type
    include/linux/device.h:452: note: expected 'const struct device *' bu=
t argument is of type 'struct device **'
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit c9568fddf130cfa0d61eb1205342dbc5ab0ed394
Author: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jul 7 16:37:03 2009 +0200

    [S390] sclp: fix compile error for !SCLP_CONSOLE
   =20
    Define an empty static inline version of sclp_console_pm_event()
    to fix the build error below for !SCLP_CONSOLE.
   =20
    drivers/s390/built-in.o: In function `sclp_rw_pm_event':
    sclp_rw.c:(.text+0x12f68): undefined reference to `sclp_console_pm_ev=
ent'
   =20
    Signed-off-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

commit d3a11e601a51291fbdd40c47f6af6769b6e905ef
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Tue Jul 7 13:43:35 2009 +0200

    ALSA: hda - Add missing EAPD initialization for VIA codecs
   =20
    If the output pin is used and EAPD capability is present, turn on
    the EAPD bit.  This fixes the silent output problem on ASUS laptops
    with VT1708S codec.
   =20
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit 55d1d6c1ef630dddd3cb5354c32a5aca954399e8
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Tue Jul 7 13:39:03 2009 +0200

    ALSA: hda - Clean up VT170x dig-in initialization code
   =20
    Minor clean up for initializing the digital-in pin.
    No functional changes.
   =20
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit 4b8a96744c0c27ab94fb4e8155d4384c3b399e27
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:32:56 2009 +0100

    kmemleak: Add more cond_resched() calls in the scanning thread
   =20
    Following recent fix to no longer reschedule in the scan_block()
    function, the system may become unresponsive with !PREEMPT. This patc=
h
    re-adds the cond_resched() call to scan_block() but conditioned by th=
e
    allow_resched parameter.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
    Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit bf2a76b317c6ccc6f7b6b1dc09664c5b6a155c61
Author: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>
Date:   Tue Jul 7 10:32:55 2009 +0100

    kmemleak: Renice the scanning thread to +10
   =20
    This is a long-running thread but not high-priority. So it makes sens=
e
    to renice it to +10.
   =20
    Signed-off-by: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>

commit 7afdbf23c3acdec3eaf1b94f87132fff3d81ce73
Author: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date:   Tue Jul 7 10:23:43 2009 +0200

    signals: declare sys_rt_tgsigqueueinfo in syscalls.h
   =20
    sys_rt_tgsigqueueinfo needs to be declared in linux/syscalls.h so tha=
t
    architectures defining the system call table in C can reference it.
   =20
    Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <200907071023.44008.arnd-r2nGTMty4D4@public.gmane.org>
    Signed-off-by: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>

commit ebf53f421308c2f59c9bcbad4c5c297a0d00199a
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jul 6 08:57:53 2009 +0300

    UBI: fix NOR flash recovery
   =20
    This commit fixes NOR flash recovery issues observed with Spansion
    S29GL512N NOR.
   =20
    When NOR erases, it first fills PEBs with zeroes, then sets all bytes
    to 0xFF. Filling with zeroes starts from the end of the PEB. And when
    power is cut, this results in PEBs containing correct EC and VID head=
ers
    but corrupted with zeros at the end. This confuses UBI and it mistaki=
nly
    accepts these PEBs and associate them with LEBs.
   =20
    Fis this issue by zeroing EC and VID magics before erasing PEBs, to
    make UBI later refuse zem.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit dd4da3a55f99efbfd46674ebefdcc2878a57ef2a
Author: SUGIOKA Toshinobu <sugioka-h0dGFfYctoLqq2nvvmkE/A@public.gmane.org>
Date:   Tue Jul 7 05:32:07 2009 +0000

    serial: sh-sci: fix sci interrupt handler
   =20
    Fix up the error bit handling on SCI ports.
   =20
    Signed-off-by: SUGIOKA Toshinobu <sugioka-h0dGFfYctoLqq2nvvmkE/A@public.gmane.org>
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit 2b5c0c72ea404d6b554a8284031dd78748314b9e
Merge: 2dbc8a23cc2e677422f6dea991aca4e3d31ab65f dc53fffc105f68cb08ca872ac=
d51550e89aa2e67
Author: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Date:   Tue Jul 7 11:55:05 2009 +0900

    Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/torvalds/linux-2.6 into sh/for-2.6.31

commit 2dbc8a23cc2e677422f6dea991aca4e3d31ab65f
Author: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Date:   Tue Jul 7 11:50:57 2009 +0900

    video: hitfb: Move over to dev_pm_ops.
   =20
    A trivial update to move hitfb over to dev_pm_ops.
   =20
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit 684dcd056178a04374c71459dbd2b18c6d958ef7
Author: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Date:   Tue Jul 7 11:44:56 2009 +0900

    video: hitfb: Convert to framebuffer_alloc().
   =20
    Follows the sh_mobile_lcdcfb change.
   =20
    Also fixes up a memory leak with cmap allocation.
   =20
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit e33afddca174171a68d57476ead8947476ab9240
Author: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Date:   Tue Jul 7 11:24:32 2009 +0900

    video: sh_mobile_lcdcfb: Convert to framebuffer_alloc().
   =20
    All fb_info structures need to be allocated with framebuffer_alloc() =
due
    to special initialization. Switch over to it.
   =20
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit 5ca1ea23c4581f961afaddf1599970e6f05d02dc
Author: Greg Ungerer <gerg-XXXsiaCtIV5Wk0Htik3J/w@public.gmane.org>
Date:   Mon Jul 6 15:23:34 2009 +0000

    fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register
   =20
    fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register
   =20
    The ColdFire 5272 FEC driver has a different register address map
    than other users of the FEC driver. And its definition of the
    FEC_X_DES_ACTIVE register is incorrect, it should be 0x14.
    The fec interface cannot transmit data with the old value.
   =20
    Signed-off-by: Greg Ungerer <gerg-JBU5SbJe1FlAfugRpC6u6w@public.gmane.org>
    ----
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 9ff1a91c027145a53bec618c8255a7bd0a89794b
Author: Greg Ungerer <gerg-JBU5SbJe1FlAfugRpC6u6w@public.gmane.org>
Date:   Mon Jul 6 18:10:25 2009 -0700

    fec: remove extra ";" from definition names
   =20
    Signed-off-by: Greg Ungerer <gerg-JBU5SbJe1FlAfugRpC6u6w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit a2e1b4c31257c07f148a89eb7eea7ca959fd0642
Author: Mark Langsdorf <mark.langsdorf-5C7GfCeVMHo@public.gmane.org>
Date:   Sun Jul 26 10:55:25 2009 -0500

    [CPUFREQ] Powernow-k8: support family 0xf with 2 low p-states
   =20
    Provide support for family 0xf processors with 2 P-states
    below the elevator voltage.  Remove the checks that prevent
    this configuration from being supported and increase the
    transition voltage to prevent errors during the transition.
   =20
    Signed-off-by: Mark Langsdorf <mark.langsdorf-5C7GfCeVMHo@public.gmane.org>
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 3f4a782b5ce2698b1870b5a7b573cd721d4fce33
Author: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Date:   Fri Jul 3 11:25:16 2009 -0400

    [CPUFREQ] fix (utter) cpufreq_add_dev mess
   =20
    OK, I've tried to clean it up the best I could, but please test this =
with
    concurrent cpu hotplug and cpufreq add/remove in loops. I'm sure we w=
ill make
    other interesting findings.
   =20
    This is step one of fixing the overall locking dependency mess in cpu=
freq.
   =20
    Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
    CC: Venkatesh Pallipadi <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    CC: rjw-KKrjLPT3xs0@public.gmane.org
    CC: mingo-X9Un+BFzKDI@public.gmane.org
    CC: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    CC: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
    CC: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    CC: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
    CC: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
    CC: sven.wegener-sQQoR7IzGU7R7s880joybQ@public.gmane.org
    CC: cpufreq-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
    CC: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit ee88415caf736b89500f16e0a545614541a45005
Author: venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:08:33 2009 -0700

    [CPUFREQ] Cleanup locking in conservative governor
   =20
    Redesign the locking inside conservative driver. Make dbs_mutex handl=
e all the
    global state changes inside the driver and invent a new percpu mutex
    to serialize percpu timer and frequency limit change.
   =20
    Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 5a75c82828e7c088ca6e7b4827911dc29cc8e774
Author: venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:08:32 2009 -0700

    [CPUFREQ] Cleanup locking in ondemand governor
   =20
    Redesign the locking inside ondemand driver. Make dbs_mutex handle al=
l the
    global state changes inside the driver and invent a new percpu mutex
    to serialize percpu timer and frequency limit change.
   =20
    Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 37c90e8887efd218dc4af949b7f498ca2da4af9f
Author: venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:08:31 2009 -0700

    [CPUFREQ] Mark policy_rwsem as going static in cpufreq.c wont be expo=
rted
   =20
    lock_policy_rwsem_* and unlock_policy_rwsem_* routines in cpufreq.c a=
re
    currently exported to drivers. Improper use of those locks can
    result in deadlocks and it is better to keep the locks localized.
    Two previous in-kernel users of these interfaces (ondemand and conser=
vative),
    do not use this interfaces any more. Schedule them for removal.
   =20
    Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 7d26e2d5e2da37e92c6c7644b26b294dedd8c982
Author: venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:08:30 2009 -0700

    [CPUFREQ] Eliminate the recent lockdep warnings in cpufreq
   =20
    Commit b14893a62c73af0eca414cfed505b8c09efc613c although it was very
    much needed to properly cleanup ondemand timer, opened-up a can of wo=
rms
    related to locking dependencies in cpufreq.
   =20
    Patch here defines the need for dbs_mutex and cleans up its usage in
    ondemand governor. This also resolves the lockdep warnings reported h=
ere
   =20
    http://lkml.indiana.edu/hypermail/linux/kernel/0906.1/01925.html
    http://lkml.indiana.edu/hypermail/linux/kernel/0907.0/00820.html
   =20
    and few others..
   =20
    Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit faf80d62e44dc627efb741f48db50c1858d1667c
Merge: eca4ee0d1615c4fb01e437f674163542ec2dd072 febe04de3be4bf66f9339d884=
7db2806d99fd164
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 17:45:44 2009 -0700

    Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
   =20
    * 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/=
git/tip/linux-2.6-tip:
      x86: fix usage of bios intcall()
      x86: Remove unused function lapic_watchdog_ok()
      x86: Remove unused variable disable_x2apic
      x86, kvm: Fix section mismatches in kvm.c
      x86: Add missing annotation to arch/x86/lib/copy_user_64.S::copy_to=
_user
      x86: Fix fixmap page order for FIX_TEXT_POKE0,1
      amd-iommu: set evt_buf_size correctly
      amd-iommu: handle alias entries correctly in init code
      x86: Fix printk call in print_local_apic()
      x86: Declare check_efer() before it gets used
      x86: Mark device_nb as static and fix NULL noise
      x86: Remove double declaration of MSR_P6_EVNTSEL0 and MSR_P6_EVNTSE=
L1
      xen: Use kcalloc() in xen_init_IRQ()
      x86: Fix fixmap ordering
      x86: Fix symbol annotation for arch/x86/lib/clear_page_64.S::clear_=
page_c

commit eca4ee0d1615c4fb01e437f674163542ec2dd072
Merge: e5a7675dd503f778987ba1f181799ba5aadde319 557dca5f48a45df88a73e69ee=
0700cfd4e2358c9
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 16:47:54 2009 -0700

    Merge master.kernel.org:/home/rmk/linux-2.6-arm
   =20
    * master.kernel.org:/home/rmk/linux-2.6-arm:
      [ARM] amba: fix amba device resources
      [ARM] pgtable: file pte layout documentation
      [ARM] pgtable: swp pte layout documentation, definitions, and check
      [ARM] export __cpu_flush_dcache_page
      [ARM] 5576/1: Update kb9202_defconfig
      [ARM] 5581/1: U300 clock updates
      [ARM] 5579/1: Updated U300 defconfig

commit e5a7675dd503f778987ba1f181799ba5aadde319
Merge: eeaecb8619fb679006ab24a11ed292e37c74703c 3503e0acbfab0dbcd24ccadd5=
fe841f3f8290e81
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 16:47:15 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6:
      Revert "ide: improve handling of Power Management requests"

commit eeaecb8619fb679006ab24a11ed292e37c74703c
Merge: dc53fffc105f68cb08ca872acd51550e89aa2e67 0ca1b08eba627b4245efd0f71=
b55a062bf163777
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 16:46:57 2009 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
   =20
    * git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6: (39 co=
mmits)
      Revert "p54: Use SKB list handling helpers instead of by-hand code.=
"
      sctp: fix warning at inet_sock_destruct() while release sctp socket
      tun/tap: Fix crashes if open() /dev/net/tun and then poll() it.
      dsa: fix 88e6xxx statistics counter snapshotting
      forcedeth: Fix NAPI race.
      drivers/net/smsc911x.c: Fix resource size off by 1 error
      pcnet_cs: add new id
      bnx2x: Fix the maximal values of coalescing timeouts.
      bnx2x: Disable HC coalescing when setting timeout to zero.
      tun: Fix device unregister race
      be2net: fix spurious interrupt handling in intx mode
      e1000e: disable K1 at 1000Mbps for 82577/82578
      e1000e: delay second read of PHY_STATUS register on failure of firs=
t read
      e1000e: prevent NVM corruption on sectors larger than 4K
      e1000e: do not write SmartSpeed register bits on parts without supp=
ort
      e1000e: delay after LCD reset and proper checks for PHY configurati=
on done
      e1000e: PHY loopback broken on 82578
      ixgbe: Not allow 8259x unsupported wol options change from ethtool
      ixgbe: fix inconsistent SFP/SFP+ failure results.
      ixgbe: fix regression on some 82598 adapters
      ...

commit dc53fffc105f68cb08ca872acd51550e89aa2e67
Merge: f560902c2d39c255bd67c0211f5dd80edb97a712 46b952a3c3a94afa339bd4961=
a4f3d1482436599
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 14:07:00 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/jbarnes/pci-2.6
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jbarne=
s/pci-2.6:
      PCI: Fix IRQ swizzling for ARI-enabled devices
      ia64/PCI: adjust section annotation for pcibios_setup()
      x86/PCI: get root CRS before scanning children
      x86/PCI: fix boundary checking when using root CRS
      PCI MSI: Fix restoration of MSI/MSI-X mask states in suspend/resume
      PCI MSI: Unmask MSI if setup failed
      PCI MSI: shorten PCI_MSIX_ENTRY_* symbol names
      PCI: make pci_name() take const argument
      PCI: More PATA quirks for not entering D3
      PCI: fix kernel-doc warnings
      PCI: check if bus has a proper bridge device before triggering SBR
      PCI: remove pci_dac_dma_... APIs on mn10300
      PCI ECRC: Remove unnecessary semicolons
      PCI MSI: Return if alloc_msi_entry for MSI-X failed

commit f560902c2d39c255bd67c0211f5dd80edb97a712
Merge: 9861df15f44d98eb6fa9a839b558633ecee87194 db6e3f91efd2cf61b9965f722=
902199cf54adc4f
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 14:05:57 2009 -0700

    Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-micro=
blaze
   =20
    * 'fixes-for-linus' of git://git.monstr.eu/linux-2.6-microblaze:
      microblaze: Fix cast warning for init.c
      microblaze: Wire up new syscalls
      microblaze: use generic syscalls.h
      microblaze: clean up signal handling
      microblaze: convert all simple headers to use asm-generic
      microblaze: use the generic lib/checksum.c
      microblaze: fall back on generic header files for the ABI

commit 9861df15f44d98eb6fa9a839b558633ecee87194
Merge: 8871b201da6e443b7ab2967050e3064360d0604f 67fc25ef34a27dc43ce6dfc98=
a8b249db304d641
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 14:05:09 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/penberg/slab-2.6
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/penber=
g/slab-2.6:
      SLAB: Fix lockdep annotations
      fix RCU-callback-after-kmem_cache_destroy problem in sl[aou]b

commit 8871b201da6e443b7ab2967050e3064360d0604f
Merge: 085ff82c9c615d502d1e6754879d8d4ff590d143 0a6843483c256c859cd954236=
1812a29403f0fb5
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 14:04:25 2009 -0700

    Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/mchehab/linux-2.6
   =20
    * 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mcheha=
b/linux-2.6: (25 commits)
      V4L/DVB (12206): get_dvb_firmware: Correct errors in MPC718 firmwar=
e extraction logic
      V4L/DVB (12203): radio-si470x: fix lock imbalance
      V4L/DVB (12202): em28xx, fix lock imbalance
      V4L/DVB (12172): em28xx: Add autodetection code for Silvercrest 1.3=
 mpix
      V4L/DVB (12171): em28xx: fix webcam usage with different output for=
mats
      V4L/DVB (12169): em28xx-video: fix VIDIOC_G_FMT and VIDIOC_ENUMFMT =
with webcams
      V4L/DVB (12156): em28xx: Fix tuning for Terratec Cinergy T XS USB (=
zl10353 version)
      V4L/DVB (12139): em28xx: add other video formats
      V4L/DVB (12138): em28xx: add support for Silvercrest Webcam
      V4L/DVB (12174): mt9v011: let's stick with datasheet values where i=
t works
      V4L/DVB (12173): mt9v011: properly calculate image resolution regis=
ters
      V4L/DVB (12137): mt9v011: CodingStyle fixes
      V4L/DVB (12136): mt9v011: Some fixes at the register initialization=
 table
      V4L/DVB (12135): Add a driver for mt9v011 sensor
      V4L/DVB (12166): cx23885: add FIXME comment above set_frontend over=
ride
      V4L/DVB (12165): cx23885: override set_frontend to allow rf input p=
ath switching on the HVR1275
      V4L/DVB (12148): move V4L2_PIX_FMT_SGRBG8 to the proper place
      V4L/DVB (12182): cx18: Add DVB-T support for Yuan MPC-718 cards wit=
h an MT352 or ZL10353
      V4L/DVB (12181): get_dvb_firmware: Add Yuan MPC718 MT352 DVB-T "fir=
mware" extraction
      V4L/DVB (12180): cx18: Update Yuan MPC-718 card entry with better i=
nformation and guesses
      ...

commit 085ff82c9c615d502d1e6754879d8d4ff590d143
Merge: f63bafe55654caf3a62f73500eafd1b89ca6f7ff 3dfc813d94bba2046c6aed216=
e0fd69ac93a8e03
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 14:03:59 2009 -0700

    Merge git://git.infradead.org/iommu-2.6
   =20
    * git://git.infradead.org/iommu-2.6:
      intel-iommu: Don't use identity mapping for PCI devices behind brid=
ges
      intel-iommu: Use iommu_should_identity_map() at startup time too.
      intel-iommu: No mapping for non-PCI devices
      intel-iommu: Restore DMAR_BROKEN_GFX_WA option for broken graphics =
drivers
      intel-iommu: Add iommu_should_identity_map() function
      intel-iommu: Fix reattaching of devices to identity mapping domain
      intel-iommu: Don't set identity mapping for bypassed graphics devic=
es
      intel-iommu: Fix dma vs. mm page confusion with aligned_nrpages()

commit f63bafe55654caf3a62f73500eafd1b89ca6f7ff
Merge: 4148df9b0f38bdd362dd91d52076926c11cbe5a9 ebbb16bffa646f853899ef3fd=
c0ac7abab888703
Author: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date:   Mon Jul 6 14:03:44 2009 -0700

    Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/ieee1394/linux1394-2.6
   =20
    * 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ieee13=
94/linux1394-2.6:
      ieee1394: sbp2: add support for disks >2 TB (and 16 bytes long CDBs=
)
      firewire: sbp2: add support for disks >2 TB (and 16 bytes long CDBs=
)
      firewire: core: do not DMA-map stack addresses

commit 4148df9b0f38bdd362dd91d52076926c11cbe5a9
Author: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Date:   Mon Jul 6 00:25:57 2009 +0900

    fb: Initialize fb_info mutexes in framebuffer_alloc()
   =20
    This way they'll be properly initialized early enough for users that =
may
    touch them before the framebuffer has been registered.
   =20
    Drivers that allocate their fb_info structure some other way (like
    matrocfb's broken static allocation) need to be fixed up appropriatel=
y.
   =20
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 793285fcafce4719a05e0c99fa74b188157fe7fe
Author: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Sun Jul 5 12:08:26 2009 -0700

    cred_guard_mutex: do not return -EINTR to user-space
   =20
    do_execve() and ptrace_attach() return -EINTR if
    mutex_lock_interruptible(->cred_guard_mutex) fails.
   =20
    This is not right, change the code to return ERESTARTNOINTR.
   =20
    Perhaps we should also change proc_pid_attr_write().
   =20
    Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Acked-by: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 82e3310ace59794ecf0f531eca94647b2863dfda
Author: Tobias Doerffel <tobias.doerffel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 12:08:23 2009 -0700

    linux/sysrq.h needs linux/errno.h
   =20
    In include/linux/sysrq.h the constant EINVAL is being used but is und=
efined
    if include/linux/errno.h is not included before.
   =20
    Fix this by adding #include <linux/errno.h> at the beginning.
   =20
    Signed-off-by: Tobias Doerffel <tobias.doerffel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 600ce1a0faafeed1ce6bcfd421bc040b941cbbc1
Author: InKi Dae <daeinki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 12:08:21 2009 -0700

    drivers/video/s3c-fb.c: fix clock setting for Samsung SoC Framebuffer
   =20
    Correct the CLKVAL_F field value of VIDEO MAIN CONTROLLER 0 REGITSTER.
   =20
    Frame Rate is 1 / [ { (VSPW+1) + (VBPD+1) + (LIINEVAL + 1) + (VFPD+1)
    } x {(HSPW+1) + (HBPD +1)
    + (HFPD+1) + (HOZVAL + 1) } x { ( CLKVAL+1 ) / ( Frequency of Clock
    source ) } ] and VCLK =3D Video Clock Source / (CLKVAL +1).
   =20
    therefore CLKVAL_F should be "CLKVAL_F =3D Frequency of Clock source =
/ pixel
    clock * refresh".
   =20
    for this, I added refresh value in platform data like below.
   =20
    static struct s3c_fb_pd_win xxx_fb_win0 =3D {
    	/* this is to ensure we use win0 */
    	.win_mode =3D {
    		.refresh	=3D 60,
    		.pixclock	=3D (66+4+2+480)*(15+5+3+800),
    		.left_margin	=3D 66,
    		.right_margin	=3D 2,
    		.upper_margin	=3D 15,
    		.lower_margin	=3D 3,
    		.hsync_len	=3D 4,
    		.vsync_len	=3D 5,
    		.xres		=3D 480,
    		.yres		=3D 800,
    	},
    	.max_bpp	=3D 32,
    	.default_bpp	=3D 24,
    };
   =20
    static struct s3c_fb_platdata xxx_lcd_pdata __initdata =3D {
    	.win[0]		=3D &xxx_fb_win0,
    	.vidcon0	=3D VIDCON0_VIDOUT_RGB | VIDCON0_PNRMODE_RGB,
    	.vidcon1	=3D VIDCON1_INV_HSYNC | VIDCON1_INV_VSYNC
    			| VIDCON1_INV_VCLK | VIDCON1_INV_VDEN,
    	.setup_gpio	=3D s5pc1xx_fb_gpio_setup_24bpp,
    };
   =20
    xxx_machine_init()
    {
                       .
                       .
                       .
                   s3c_fb_set_platdata(&xxx_lcd_pdata);
    }
   =20
    platform data defined in machine code should be setting using
    s3c_fb_set_platdata().
   =20
    Signed-off-by: InKi Dae <inki.dae-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
    Cc: Kyungmin Park <kmpark-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Cc: Krzysztof Helt <krzysztof.h1-IjDXvh/HVVUAvxtiuMwx3w@public.gmane.org>
    Cc: Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 5bfd7560979062ad75c9805c1719cec990b5db29
Author: Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 12:08:19 2009 -0700

    Fix virt_to_phys() warnings
   =20
    These warnings were observed on MIPS32 using 2.6.31-rc1 and gcc-4.2.0=
:
   =20
    mm/page_alloc.c: In function 'alloc_pages_exact':
    mm/page_alloc.c:1986: warning: passing argument 1 of 'virt_to_phys' m=
akes pointer from integer without a cast
   =20
    drivers/usb/mon/mon_bin.c: In function 'mon_alloc_buff':
    drivers/usb/mon/mon_bin.c:1264: warning: passing argument 1 of 'virt_=
to_phys' makes pointer from integer without a cast
   =20
    [akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org: fix kernel/perf_counter.c too]
    Signed-off-by: Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
    Cc: Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
    Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit c8236db9cd7aa492dcfcdcca702638e704abed49
Author: Josef Bacik <josef-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Sun Jul 5 12:08:18 2009 -0700

    mm: mark page accessed before we write_end()
   =20
    In testing a backport of the write_begin/write_end AOPs, a 10% re-rea=
d
    regression was noticed when running iozone.  This regression was
    introduced because the old AOPs would always do a mark_page_accessed(=
page)
    after the commit_write, but when the new AOPs where introduced, the o=
nly
    place this was kept was in pagecache_write_end().
   =20
    This patch does the same thing in the generic case as what is done in
    pagecache_write_end(), which is just to mark the page accessed before=
 we
    do write_end().
   =20
    Signed-off-by: Josef Bacik <jbacik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Acked-by: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit a65e7bfcd74e4c0939f235d2bf9f48ddb3a57991
Author: Hui Zhu <teawater-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 12:08:15 2009 -0700

    elf: fix multithreaded program core dumping on arm
   =20
    Fix the multithread program core thread message error.
   =20
    This issue affects arches with neither has CORE_DUMP_USE_REGSET nor
    ELF_CORE_COPY_TASK_REGS, ARM is one of them.
   =20
    The thread message of core file is generated in elf_dump_thread_statu=
s.
    The register values is set by elf_core_copy_task_regs in this functio=
n.
   =20
    If an arch doesn't define ELF_CORE_COPY_TASK_REGS,
    elf_core_copy_task_regs() will do nothing.  Then the core file will n=
ot
    have the register message of thread.
   =20
    So add elf_core_copy_regs to set regiser values if ELF_CORE_COPY_TASK=
_REGS
    doesn't define.
   =20
    The following is how to reproduce this issue:
   =20
    cat 1.c
    #include <stdio.h>
    #include <pthread.h>
    #include <assert.h>
   =20
    void td1(void * i)
    {
           while (1)
           {
                   printf ("1\n");
                   sleep (1);
           }
   =20
           return;
    }
   =20
    void td2(void * i)
    {
           while (1)
           {
                   printf ("2\n");
                   sleep (1);
           }
   =20
           return;
    }
   =20
    int
    main(int argc,char *argv[],char *envp[])
    {
           pthread_t       t1,t2;
   =20
           pthread_create(&t1, NULL, (void*)td1, NULL);
           pthread_create(&t2, NULL, (void*)td2, NULL);
   =20
           sleep (10);
   =20
           assert(0);
   =20
           return (0);
    }
    arm-xxx-gcc -g -lpthread 1.c -o 1
    copy 1.c and 1 to a arm board.
    Goto this board.
    ulimit -c 1800000
    ./1
    # ./1
    1
    2
    1
    ...
    ...
    1
    1: 1.c:37: main: Assertion `0' failed.
    Aborted (core dumped)
    Then you can get a core file.
    gdb 1 core.xxx
    Without the patch:
    (gdb) info threads
     3 process 909  0x00000000 in ?? ()
     2 process 908  0x00000000 in ?? ()
    * 1 process 907  0x4a6e2238 in raise () from /lib/libc.so.6
    You can found that the pc of 909 and 908 is 0x00000000.
    With the patch:
    (gdb) info threads
     3 process 885  0x4a749974 in nanosleep () from /lib/libc.so.6
     2 process 884  0x4a749974 in nanosleep () from /lib/libc.so.6
    * 1 process 883  0x4a6e2238 in raise () from /lib/libc.so.6
    The pc of 885 and 884 is right.
   =20
    Signed-off-by: Hui Zhu <teawater-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Jakub Jelinek <jakub-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Russell King <rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 3beab0b42413e83a7907db7176b54c840fc75a81
Author: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Sun Jul 5 12:08:08 2009 -0700

    sys_sync(): fix 16% performance regression in ffsb create_4k test
   =20
    I run many ffsb test cases on JBODs (typically 13/12 disks).  Compari=
ng
    with kernel 2.6.30, 2.6.31-rc1 has about 16% regression with
    ffsb_create_4k.  The sub test case creates files continuously for 10
    minitues and every file is 1MB.
   =20
    Bisect located below patch.
   =20
    5cee5815d1564bbbd505fea86f4550f1efdb5cd0 is first bad commit
    commit 5cee5815d1564bbbd505fea86f4550f1efdb5cd0
    Author: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Date:   Mon Apr 27 16:43:51 2009 +0200
   =20
        vfs: Make sys_sync() use fsync_super() (version 4)
   =20
        It is unnecessarily fragile to have two places (fsync_super() and=
 do_sync())
        doing data integrity sync of the filesystem. Alter __fsync_super(=
) to
        accommodate needs of both callers and use it. So after this patch
        __fsync_super() is the only place where we gather all the calls n=
eeded to
        properly send all data on a filesystem to disk.
   =20
    As a matter of fact, ffsb calls sys_sync in the end to make sure all =
data
    is flushed to disks and the flushing is counted into the result.  vms=
tat
    shows ffsb is blocked when syncing for a long time.  With 2.6.30, ffs=
b is
    blocked for a short time.
   =20
    I checked the patch and did experiments to recover the original metho=
ds.
    Eventually, the root cause is the patch deletes the calling to
    wakeup_pdflush when syncing, so only ffsb is blocked on disk I/O.
    wakeup_pdflush could ask pdflush to write back pages with ffsb at the
    same time.
   =20
    [akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org: restore comment too]
    Signed-off-by: Zhang Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
    Acked-by: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit f386c61fe1a1f36f0e434f1b577e6b112698caf7
Author: Peter Oberparleiter <oberpar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sun Jul 5 12:08:06 2009 -0700

    gcov: exclude code operating in userspace from profiling
   =20
    Fix for this issue on x86_64:
   =20
    rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org wrote:
    > On bootup of the latest kernel my init segfaults. Debugging it,
    > I found  that vread_tsc (a vsyscall) increments some strange
    > kernel memory:
    >
    > 0000000000000000 <vread_tsc>:
    >    0:   55                      push   %rbp
    >    1:   48 ff 05 00 00 00 00    incq   0(%rip)
    >                         # 8 <vread_tsc+0x8>
    >                         4: R_X86_64_PC32        .bss+0x3c
    >    8:   48 89 e5                mov    %rsp,%rbp
    >    b:   66 66 90                xchg   %ax,%ax
    >    e:   48 ff 05 00 00 00 00    incq   0(%rip)
    >                         # 15 <vread_tsc+0x15>
    >                         11: R_X86_64_PC32       .bss+0x44
    >   15:   66 66 90                xchg   %ax,%ax
    >   18:   48 ff 05 00 00 00 00    incq   0(%rip)
    >                         # 1f <vread_tsc+0x1f>
    >                         1b: R_X86_64_PC32       .bss+0x4c
    >   1f:   0f 31                   rdtsc
    >
    >
    > Those "incq" is very bad to happen in vsyscall memory, since
    > userspace can not modify it. You need to make something prevent
    > profiling of vsyscall  memory (like I do with ftrace).
   =20
    Signed-off-by: Peter Oberparleiter <oberpar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Reported-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
    Tested-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 28df30e61b46a33d1f0bb60757747396886ef687
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 12:08:03 2009 -0700

    rtc: ds1374, fix lock imbalance
   =20
    When i2c_smbus_read_byte_data fails in ds1374_work, we forgot to unlo=
ck
    the held lock.  Fix that.
   =20
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Alessandro Zummo <a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org>
    Cc: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit efc0cfa6d16103bd72a7c398f1321816b635370f
Author: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Date:   Sun Jul 5 12:08:02 2009 -0700

    vlynq: fix typo in Kconfig to enable debugging
   =20
    Fix a typo in the VLYNQ bus driver Kconfig which prevented to turn on
    VLYNQ bus debugging.
   =20
    Signed-off-by: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 9e2db5c90a25acf7657edb3687b8d5813ccddfee
Author: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Date:   Sun Jul 5 12:08:00 2009 -0700

    vlynq: correct typo of missing "CONFIG_" prefix in ifdef
   =20
    Fix a typo in the vlynq bus driver which was missing the CONFIG_ pref=
ix to
    turn on debugging code.
   =20
    Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
    Signed-off-by: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit cbad1cbb51d92c0b5c3f47ef9dbf125de81fae08
Author: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
Date:   Mon Jul 6 21:11:24 2009 +0200

    sisfb: fix regression with uninitalized fb_info->mm_lock mutex
   =20
    Remove redundant call to the sisfb_get_fix() before sis frambuffer is
    registered.
   =20
    This fixes a problem with uninitialized the fb_info->mm_lock mutex
    introduced by the commit 537a1bf059f " fbdev: add mutex for fb_mmap
    locking"
   =20
    Signed-off-by: Krzysztof Helt <krzysztof.h1-5tc4TXWwyLM@public.gmane.org>
    Tested-by: Wu Zhangjin <wuzhangjin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

commit 0ca1b08eba627b4245efd0f71b55a062bf163777
Author: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date:   Mon Jul 6 12:49:18 2009 -0700

    Revert "p54: Use SKB list handling helpers instead of by-hand code."
   =20
    This reverts commit a1091aae19b1d9c85d91c86915a611387f67a26b.

commit 1bc4ee4088c9a502db0e9c87f675e61e57fa1734
Author: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Sun Jul 5 19:45:48 2009 +0000

    sctp: fix warning at inet_sock_destruct() while release sctp socket
   =20
    Commit 'net: Move rx skb_orphan call to where needed' broken sctp pro=
tocol
    with warning at inet_sock_destruct(). Actually, sctp can do this righ=
t with
    sctp_sock_rfree_frag() and sctp_skb_set_owner_r_frag() pair.
   =20
        sctp_sock_rfree_frag(skb);
        sctp_skb_set_owner_r_frag(skb, newsk);
   =20
    This patch not revert the commit d55d87fdff8252d0e2f7c28c2d443aee17e9=
d70f,
    instead remove the sctp_sock_rfree_frag() function.
   =20
    ------------[ cut here ]------------
    WARNING: at net/ipv4/af_inet.c:151 inet_sock_destruct+0xe0/0x142()
    Modules linked in: sctp ipv6 dm_mirror dm_region_hash dm_log dm_multi=
path
    scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wai=
t_scan]
    Pid: 1808, comm: sctp_test Not tainted 2.6.31-rc2 #40
    Call Trace:
     [<c042dd06>] warn_slowpath_common+0x6a/0x81
     [<c064a39a>] ? inet_sock_destruct+0xe0/0x142
     [<c042dd2f>] warn_slowpath_null+0x12/0x15
     [<c064a39a>] inet_sock_destruct+0xe0/0x142
     [<c05fde44>] __sk_free+0x19/0xcc
     [<c05fdf50>] sk_free+0x18/0x1a
     [<ca0d14ad>] sctp_close+0x192/0x1a1 [sctp]
     [<c0649f7f>] inet_release+0x47/0x4d
     [<c05fba4d>] sock_release+0x19/0x5e
     [<c05fbab3>] sock_close+0x21/0x25
     [<c049c31b>] __fput+0xde/0x189
     [<c049c3de>] fput+0x18/0x1a
     [<c049988f>] filp_close+0x56/0x60
     [<c042f422>] put_files_struct+0x5d/0xa1
     [<c042f49f>] exit_files+0x39/0x3d
     [<c043086a>] do_exit+0x1a5/0x5dd
     [<c04a86c2>] ? d_kill+0x35/0x3b
     [<c0438fa4>] ? dequeue_signal+0xa6/0x115
     [<c0430d05>] do_group_exit+0x63/0x8a
     [<c0439504>] get_signal_to_deliver+0x2e1/0x2f9
     [<c0401d9e>] do_notify_resume+0x7c/0x6b5
     [<c043f601>] ? autoremove_wake_function+0x0/0x34
     [<c04a864e>] ? __d_free+0x3d/0x40
     [<c04a867b>] ? d_free+0x2a/0x3c
     [<c049ba7e>] ? vfs_write+0x103/0x117
     [<c05fc8fa>] ? sys_socketcall+0x178/0x182
     [<c0402a56>] work_notifysig+0x13/0x19
    ---[ end trace 9db92c463e789fba ]---
   =20
    Signed-off-by: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Acked-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
    Acked-by: Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 3c8a9c63d5fd738c261bd0ceece04d9c8357ca13
Author: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
Date:   Sun Jul 5 19:48:35 2009 +0000

    tun/tap: Fix crashes if open() /dev/net/tun and then poll() it.
   =20
    Fix NULL pointer dereference in tun_chr_pool() introduced by commit
    33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554 ("tun: Limit amount of queue=
d
    packets per device") and triggered by this code:
   =20
    	int fd;
    	struct pollfd pfd;
    	fd =3D open("/dev/net/tun", O_RDWR);
    	pfd.fd =3D fd;
    	pfd.events =3D POLLIN | POLLOUT;
    	poll(&pfd, 1, 0);
   =20
    Reported-by: Eugene Kapun <abacabadabacaba-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 3503e0acbfab0dbcd24ccadd5fe841f3f8290e81
Author: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date:   Mon Jul 6 12:39:27 2009 -0700

    Revert "ide: improve handling of Power Management requests"
   =20
    This reverts commit a1317f714af7aed60ddc182d0122477cbe36ee9b.

commit db6e3f91efd2cf61b9965f722902199cf54adc4f
Author: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Date:   Mon Jul 6 08:21:09 2009 +0200

    microblaze: Fix cast warning for init.c
   =20
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit 4ae78338157a1fe2d7a398d86bb9f9043d600d2b
Author: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Date:   Wed Jul 1 15:32:14 2009 +0200

    microblaze: Wire up new syscalls
   =20
    Wire up new syscalls rt_tgsigqueueinfo and perf_counter_open.
   =20
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit e513588f75912f022677866244de6b19b98b8d9a
Author: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date:   Thu Jun 18 19:55:30 2009 +0200

    microblaze: use generic syscalls.h
   =20
    The prototypes in syscalls.h all make sense for
    microblaze, but for some of them, the actual implementation
    in sys_microblaze.c needs to be adapted.
   =20
    Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit 3183e06863f49a500fc76427db4d60825a26f81b
Author: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date:   Thu Jun 18 19:55:29 2009 +0200

    microblaze: clean up signal handling
   =20
    When legacy signal handling is disabled, the
    arch/microblaze/kernel/signal.c implementation can
    be much simpler, as most of it is handled generically
    from kernel/signal.c.
   =20
    This is also a prerequisite for using the generic
    asm/unistd.h, which does not provide __NR_sigreturn,
    because this macro is referenced by the current signal.c
    implementation.
   =20
    Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit 0a58458341fd571e521be542ff746a4a8995980c
Author: Remis Lima Baima <remis.developer-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date:   Thu Jun 18 19:55:33 2009 +0200

    microblaze: convert all simple headers to use asm-generic
   =20
    All the simple microblaze header files were adapted to use their
    asm-generic implementations. These files are more simple and were qui=
te
    straightforward to change.
   =20
    fb.h, vga.h and parport.h previously did not exist, using
    the generic version makes it possible to build more drivers
    successfully in allyesonfig.
   =20
    Signed-off-by: Remis Lima Baima <remis.developer-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
    Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit 14f8738976991d2f8fb6ab6e10e9003562c3d6bb
Author: Remis Lima Baima <remis.developer-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date:   Thu Jun 18 19:55:32 2009 +0200

    microblaze: use the generic lib/checksum.c
   =20
    The microblaze checksum code is mostly identical to
    the asm-generic+lib version, so use that instead.
   =20
    Signed-off-by: Remis Lima Baima <remis.developer-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit 81d8279ea31a3fc6d4ffacd87119a04c561ca62e
Author: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date:   Thu Jun 18 19:55:27 2009 +0200

    microblaze: fall back on generic header files for the ABI
   =20
    Almost all of the ABI relevant header files now have generic
    versions, so use those now in order to reduce the amount
    of architecture specific code.
   =20
    Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>

commit 67fc25ef34a27dc43ce6dfc98a8b249db304d641
Merge: 8e4a718ff38d8539938ec3421935904c27e00c39 ec5a36f94e7ca4b1f28ae4dd1=
35cd415a704e772
Author: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Date:   Mon Jul 6 10:51:54 2009 +0300

    Merge branch 'slab/urgent' into for-linus

commit 1ded3f59f35a2642852b3e2a1c0fa8a97777e9af
Author: Stephane Contri <Stephane.Contri-Omk3PdybHIaN9aS15agKxg@public.gmane.org>
Date:   Thu Jul 2 23:26:48 2009 +0000

    dsa: fix 88e6xxx statistics counter snapshotting
   =20
    The bit that tells us whether a statistics counter snapshot operation
    has completed is located in the GLOBAL register block, not in the
    GLOBAL2 register block, so fix up mv88e6xxx_stats_wait() to poll the
    right register address.
   =20
    Signed-off-by: Stephane Contri <Stephane.Contri-Omk3PdybHIaN9aS15agKxg@public.gmane.org>
    Signed-off-by: Lennert Buytenhek <buytenh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 78c29bd95bd8d2c3bcf7932cb3ab8ae01cd8f58f
Author: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 04:04:45 2009 +0000

    forcedeth: Fix NAPI race.
   =20
    Eric Dumazet a =C3=A9crit :
    > Ingo Molnar a =C3=A9crit :
    >>> The following changes since commit 52989765629e7d182b4f146050ebba=
0abf2cb0b7:
    >>>   Linus Torvalds (1):
    >>>         Merge git://git.kernel.org/.../davem/net-2.6
    >>>
    >>> are available in the git repository at:
    >>>
    >>>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git m=
aster
    >> Hm, something in this lot quickly wrecked networking here - see th=
e
    >> tx timeout dump below. It starts with:
    >>
    >> [  351.004596] WARNING: at net/sched/sch_generic.c:246 dev_watchdo=
g+0x10b/0x19c()
    >> [  351.011815] Hardware name: System Product Name
    >> [  351.016220] NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0=
 timed out
    >>
    >> Config attached. Unfortunately i've got no time to do bisection
    >> today.
    >
    >
    >
    > forcedeth might have a problem, in its netif_wake_queue() logic, bu=
t
    > I could not see why a recent patch could make this problem visible =
now.
    >
    > CPU0/1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
    > is not a new cpu either :)
    >
    > forcedeth uses an internal tx_stop without appropriate barrier.
    >
    > Could you try following patch ?
    >
    > (random guess as I dont have much time right now)
   =20
    We might have a race in napi_schedule(), leaving interrupts disabled =
forever.
    I cannot test this patch, I dont have the hardware...
   =20
    Tested-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
   =20
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 3942453948015228d6b1ae9835a6f6ca3e842aaa
Author: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Date:   Sat Jul 4 11:31:47 2009 +0000

    drivers/net/smsc911x.c: Fix resource size off by 1 error
   =20
    The call resource_size(res) returns res->end - res->start + 1 and thu=
s the
    second change is semantics-preserving.  res_size is then used as the =
second
    argument of a call to request_mem_region, and the memory allocated by=
 this
    call appears to be the same as what is released in the two calls to
    release_mem_region.  So the size argument for those calls should be
    resource_size(size) as well.  Alternatively, in the second call to
    release_mem_region, the second argument could be res_size, as that va=
riable
    has already been initialized at the point of this call.
   =20
    The problem was found using the following semantic patch:
    (http://www.emn.fr/x-info/coccinelle/)
   =20
    // <smpl>
    @@
    struct resource *res;
    @@
   =20
    - (res->end - res->start) + 1
    + resource_size(res)
   =20
    @@
    struct resource *res;
    @@
   =20
    - res->end - res->start
    + BAD(resource_size(res))
    // </smpl>
   =20
    Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 4c3dd308adbda61f2ab46a14a0adcca8e1338ea5
Author: Ken Kawasaki <ken_kawasaki-uKGOhI97zADnmG91ENUOYw@public.gmane.org>
Date:   Sat Jul 4 14:17:10 2009 +0000

    pcnet_cs: add new id
   =20
    add new id (RIOS System PC CARD3 ETHERNET).
   =20
    Signed-off-by: Ken Kawasaki <ken_kawasaki-uKGOhI97zADnmG91ENUOYw@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 1e9d9987598fa58f4bd8e72ee152c879136d6723
Author: Eilon Greenstein <eilong-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date:   Sun Jul 5 04:18:14 2009 +0000

    bnx2x: Fix the maximal values of coalescing timeouts.
   =20
    This patch properly defines the maximum values for rx/tx coalescing t=
imeouts.
   =20
    Signed-off-by: Vlad Zolotarov <vladz-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
    Signed-off-by: Eilon Greenstein <eilong-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 3799cf47e3497a472b05f88e7a52a14931597d78
Author: Eilon Greenstein <eilong-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date:   Sun Jul 5 04:18:12 2009 +0000

    bnx2x: Disable HC coalescing when setting timeout to zero.
   =20
    Problem reported by Flavio Leitner <fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>:
    When setting rx/tx coalescing timeout to the values less than 12 traf=
fic was
    stopped.
   =20
    The FW supports coalescing in 12us granularity, and so value of less =
then 12
    should be interpreted as disabling coalescing
   =20
    Signed-off-by: Vlad Zolotarov <vladz-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
    Signed-off-by: Eilon Greenstein <eilong-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit d23e43658aed286b885d398ff0810f04f6aae97f
Author: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date:   Thu Jul 2 23:03:55 2009 +0000

    tun: Fix device unregister race
   =20
    It is currently possible for an asynchronous device unregister
    to cause the same tun device to be unregistered twice.  This
    is because the unregister in tun_chr_close only checks whether
    __tun_get(tfile) !=3D NULL.  This however has nothing to do with
    whether the device has already been unregistered.  All it tells
    you is whether __tun_detach has been called.
   =20
    This patch fixes this by using the most obvious thing to test
    whether the device has been unregistered.
   =20
    It also moves __tun_detach outside of rtnl_unlock since nothing
    that it does requires that lock.
   =20
    Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 0a6843483c256c859cd9542361812a29403f0fb5
Author: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
Date:   Sun Jul 5 16:22:45 2009 -0300

    V4L/DVB (12206): get_dvb_firmware: Correct errors in MPC718 firmware =
extraction logic
   =20
    The extraction routine for the MPC718 "firmware" had 2 bugs in it, wh=
ere one
    bug masked the effect of the other.  The loop iteration should have s=
et
    $prevlen =3D $currlen at the end of the loop, and the if() check shou=
ld have used
    && instead of || for deciding if the firmware length is reasonable.
   =20
    Signed-off-by: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit a5ca3a1bc719cb9056acc6f24340a1e2674f21a0
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 15:44:20 2009 -0300

    V4L/DVB (12203): radio-si470x: fix lock imbalance
   =20
    There is one path with omitted unlock in si470x_fops_release. Fix tha=
t.
   =20
    Cc: Tobias Lorenz <tobias.lorenz-hi6Y0CQ0nG0@public.gmane.org>
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Douglas Schilling Landgraf <dougsland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 11b79ea75ada39b7f1efdebdad520c93c3ac1f0e
Author: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 14:06:41 2009 -0300

    V4L/DVB (12202): em28xx, fix lock imbalance
   =20
    There is one omitted unlock in em28xx_usb_probe. Fix that.
   =20
    Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Douglas Schilling Landgraf <dougsland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 791a08fc01aaa293a73c9dce260327fdee288faf
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jul 3 15:36:18 2009 -0300

    V4L/DVB (12172): em28xx: Add autodetection code for Silvercrest 1.3 m=
pix
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 58fc1ce37aba8e6371e1ec8a90d650b1965ee6c8
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jul 3 02:54:18 2009 -0300

    V4L/DVB (12171): em28xx: fix webcam usage with different output forma=
ts
   =20
    Discovered the bug that were limiting the output format to just RGB56=
5.
    Now, it is possible to output image at Bayer format (the original one=
,
    as generated by Silvercrest sensor, and two others), and also on YUY.
   =20
    Adds Bayer formats also to the driver.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 557dca5f48a45df88a73e69ee0700cfd4e2358c9
Author: Russell King <rmk-MIedHU+rSCMANfyc6IWni62ZND6+EDdj@public.gmane.org>
Date:   Sun Jul 5 22:39:08 2009 +0100

    [ARM] amba: fix amba device resources
   =20
    AMBA device resources were being reported as:
   =20
    10004000-10004fff : <BAD>
   =20
    This is because dev_name() was returning NULL prior to device_registe=
r.
    Ensure that the struct device is properly initialized, and the name i=
s
    set before adding it to the device tree.
   =20
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit ed5f1431ebeeba8cc6739e9cd905a7895b66184c
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 17:34:04 2009 -0300

    V4L/DVB (12169): em28xx-video: fix VIDIOC_G_FMT and VIDIOC_ENUMFMT wi=
th webcams
   =20
    Webcams have different constraints than other v4l devices. This patch
    makes the format ioctls to behave better. It also fixes a bug at open=
()
    handler, that were always reseting resolution to the maximum availabl=
e
    one.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit f797608cc4f19b44b83ec39c87e14af6fa07826d
Author: Devin Heitmueller <dheitmueller-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
Date:   Mon Jun 22 22:32:32 2009 -0300

    V4L/DVB (12156): em28xx: Fix tuning for Terratec Cinergy T XS USB (zl=
10353 version)
   =20
    Fix the code so that the zl10353 version of the Terratec Cinergy T XS=
 USB
    starts working again.  This includes fixing what must have been a typ=
o in the
    GPIO definition for the digital side of the board, and setting of the
    disable_i2c_gate_ctrl property for the zl10353 config, so that the i2=
c bus
    doesn't get wedged the first time something tries to close the gate.
   =20
    Also, add a printk() making clear that the mt352 version still isn't
    supported.  This issue is still being actively debugged, but in the m=
eantime
    at least the dmesg output will show a very clear error...
   =20
    Thanks to Jelle de Jong for providing sample hardware to test with.
   =20
    Thanks to Simon Kenyon for testing various patches and providing SSH =
access to
    his environment so I could debug with access to a valid signal source.
   =20
    Cc: Jelle de Jong <jelledejong-OIcJOM8/mISwoUgIn9SVlA@public.gmane.org>
    Cc: Simon Kenyon <simon-YTvESifDTt4@public.gmane.org>
    Signed-off-by: Devin Heitmueller <dheitmueller-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 43cb9fe3291bb96390c1d188eb61c2d1581bb61e
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jun 30 08:36:17 2009 -0300

    V4L/DVB (12139): em28xx: add other video formats
   =20
    Add suppport for the teste RGB565 format (16 bits/pixel).
    Currently, webcam support works only at RGB565, at 640x480.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 02e7804b2135ff941b8846f5820cf48fbfdadd54
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jun 29 11:35:05 2009 -0300

    V4L/DVB (12138): em28xx: add support for Silvercrest Webcam
   =20
    This webcam uses a em2710 chipset, that identifies itself as em2820,
    plus a mt9v011 sensor, and a DY-301P lens.
   =20
    It needs a few different initializations than a normal em28xx device.
   =20
    Thanks to Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> and Douglas Landgraf
    <dougsland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> for providing the acces for the webcam during
    this weekend, I could make a patch for it while returning back from
    FISL/Fudcom LATAM 2009.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 6934e6fface7b7d5fe7e578c3f43cbe8f23af2d4
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Sat Jul 4 08:15:11 2009 -0300

    V4L/DVB (12174): mt9v011: let's stick with datasheet values where it =
works
   =20
    The original driver for Silvercrest cameras were using some values th=
at
    are different from what datasheet says. As result, it was taken very
    less snapshots per second than expected.
   =20
    A test with the datasheet values showed that they work fine and give =
a
    better frame rate. So, let's stick with datasheet values.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 27fe4a30a211a0561c72b0e519997e91fa91c452
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Sat Jul 4 08:03:48 2009 -0300

    V4L/DVB (12173): mt9v011: properly calculate image resolution registe=
rs
   =20
    Instead of working with a table of precalculated values, fill them wi=
th
    the proper values. Also, adds format functions that allow changing th=
e
    resolution, by cropping the image to the center of the sensor.
   =20
    While here, move the sensor version check to the probe routine, to
    indicate to the caller if the sensor is not supported by this driver.
   =20
    Also, fixes a stupid bug where we're using &buffer[] instead of
    buffer[].
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit fbe2800c932573e90e38a9c703165839e0c00515
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jun 29 11:12:05 2009 -0300

    V4L/DVB (12137): mt9v011: CodingStyle fixes
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit afe09f821ffa733d1cbfbf4e7cc41bd1cb8dcffb
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jun 29 11:03:22 2009 -0300

    V4L/DVB (12136): mt9v011: Some fixes at the register initialization t=
able
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 7dfba00d05f3c7db9510f3b54a472981cf1521af
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jun 29 05:41:26 2009 -0300

    V4L/DVB (12135): Add a driver for mt9v011 sensor
   =20
    Adds driver for mt9v011 based on its datasheet, available at:
    	http://download.micron.com/pdf/datasheets/imaging/MT9V011.pdf
   =20
    The driver was tested with a webcam that will be added on a next patc=
h.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit b179bc4579f67c6f1df524c48b28cacf0c7a1b91
Author: Michael Krufky <mkrufky-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
Date:   Tue Jun 16 17:08:17 2009 -0300

    V4L/DVB (12166): cx23885: add FIXME comment above set_frontend overri=
de
   =20
    add FIXME comment to indicate that the set_frontend override is a
    temporary hack.  This will be done a better way in the next kernel.
   =20
    Signed-off-by: Michael Krufky <mkrufky-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit f35b9e8039c04f0cb9fe3a051ce941b1524a8798
Author: Michael Krufky <mkrufky-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
Date:   Fri May 8 22:39:24 2009 -0300

    V4L/DVB (12165): cx23885: override set_frontend to allow rf input pat=
h switching on the HVR1275
   =20
    Use separate RF input spigots for Antennae and Cable.
   =20
    Reviewed-by: Steven Toth <stoth-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
    Signed-off-by: Michael Krufky <mkrufky-eb9eJ82Ua7k9XoPSrs7Ehg@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 509dd025a4ac6f32921211557cfd434b81d8d7a7
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jun 30 16:07:26 2009 -0300

    V4L/DVB (12148): move V4L2_PIX_FMT_SGRBG8 to the proper place
   =20
    Instead of defining a new pif format on an internal header, move it t=
o
    the V4L2 API header.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit ff861fb21e44ab178eddc6a1dd7c5478e3eb2ec5
Author: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
Date:   Fri Jul 3 11:54:40 2009 -0300

    V4L/DVB (12182): cx18: Add DVB-T support for Yuan MPC-718 cards with =
an MT352 or ZL10353
   =20
    Add DVB-T support for Yuan MPC-718 cards with an MT352 or ZL10353 dem=
odulator.
   =20
    There are apparently some units with a DiBcom demodulator which could=
 be
    supported by one of the dib7000 modules - but this is not implemented=
 in the
    cx18 driver (yet).
   =20
    Due to lack of porgramming details for the MT352 and the mt352 module=
 requiring
    a "demod_init" function, a "firmware" must be obtained and loaded to =
get
    DVB-T working for Yuan MPC-718 cards with an MT352.
   =20
    Tested-by: Steve Firth <firth650-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
    Signed-off-by: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 9f38a920b232800fd4000ba3d4617b41198e017e
Author: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
Date:   Fri Jul 3 11:33:17 2009 -0300

    V4L/DVB (12181): get_dvb_firmware: Add Yuan MPC718 MT352 DVB-T "firmw=
are" extraction
   =20
    Add routine to support extracting the MT352 DVB-T demodulator initial=
ization
    sequence for Yuan MPC718 cards for use by the cx18 driver.
   =20
    This routine uses a hueristic for extracting a good sequence.  It sho=
uld work
    on all different versions of the "yuanrap.sys" file, given the way th=
e MT352
    tuning sequences are stored in all versions of that file I have seen =
so far.
    However, the current patch simply looks for one specific archive URL.
   =20
    Signed-off-by: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 637fb3d70b1e53a127cba5ffae5aa3b2b9f57df6
Author: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
Date:   Fri Jul 3 11:30:27 2009 -0300

    V4L/DVB (12180): cx18: Update Yuan MPC-718 card entry with better inf=
ormation and guesses
   =20
    Signed-off-by: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 6e707b4c6d1fcf0fca6a4525e0ff66d35e21a517
Author: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
Date:   Thu Jun 11 07:57:50 2009 -0300

    V4L/DVB (12167): tuner-xc2028: Fix 7 MHz DVB-T
   =20
    The following patch should fix 7 MHz DVB-T with the XC3028 using the
    DTV7 firmware from the xc3028-v27.fw firmware image.
   =20
    Tested-by: Terry Wu <terrywu2009-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    [mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org: thanks to John Ferlito, we have a real test in A=
ustralia]
    Signed-off-by: Andy Walls <awalls-HKHfaON4UMNeoWH0uzbU5w@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit c06950ae4dccf59566fec7ae269aaeb24685c16c
Author: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
Date:   Wed Jun 24 10:31:25 2009 -0300

    V4L/DVB (12160): soc-camera: fix missing clean up on error path
   =20
    If soc_camera_init_user_formats() fails in soc_camera_probe(), we hav=
e to call
    client's .remove() method to unregister the video device.
   =20
    Reported-by: Kuninori Morimoto <morimoto.kuninori-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 14df2ccead8f6da5a9c8f904fc629aaf849b7e55
Author: Stefan Herbrechtsmeier <hbmeier-8FcPADsy+UPLerCH+ut/6Wfrygkm6VTR@public.gmane.org>
Date:   Wed Jun 24 10:31:25 2009 -0300

    V4L/DVB (12159): soc_camera: Fix debug output of supported formats co=
unt
   =20
    The supported formats count must be set to 0 after debug output
    right before the second pass.
   =20
    Signed-off-by: Stefan Herbrechtsmeier <hbmeier-8FcPADsy+UPLerCH+ut/6Wfrygkm6VTR@public.gmane.org>
    Signed-off-by: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit 3175da83a0a85fa03c9c34061906a9ca0725af0d
Author: Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
Date:   Fri Jun 26 15:35:04 2009 -0300

    V4L/DVB (12153): ttpci: config TTPCI_EEPROM depends on I2C
   =20
    If I2C is not enabled, then we shouldn't build ttpci_eeprom.c.
   =20
    Signed-off-by: Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit fe96efc1a3c049f0a1bcd9b65e0faeb751ce5ec6
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 30 16:11:59 2009 +0300

    UBI: nicify image sequence number handling
   =20
    Move the image seq. number handling from I/O level to the scanning
    lever, where it really belongs to. Move the @image_seq_set variable
    to the @struct ubi_scan_info structure, which exists only during
    scanning.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 0c6c7fa1313fcb69cae35e34168d2e83b8da854a
Author: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jun 26 14:58:01 2009 +0300

    UBI: add image sequence number to EC header
   =20
    An image sequence number is added to the UBI erase-counter header
    to be able determine if the root file system contains a mixture
    of old and new images (because the flashing failed to complete).
   =20
    A change to nolo is also needed for this to take effect.
   =20
    Signed-off-by: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 1398788fe7b730db10e97dcb9f838603e41922d5
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 15:58:36 2009 +0300

    UBI: remove bogus debugging checks
   =20
    The 'paranoid_check_empty()' is bogus because, which is easilly
    seen on NOR flash, which has long erase cycles, and which may
    easilly end-up with half-erased eraseblocks. In this case the
    paranoid check fails. I is just wrong to assume that PEBs which
    do not have EC headers always contain all 0xFF. Such assumption
    should not be made on the I/O level, which is quite low.
   =20
    Thus, just kill the check.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 40a71a87fa8e0cb3ec0fca4d152263734b203eb2
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 19:16:55 2009 +0300

    UBI: add empty eraseblocks verification
   =20
    This patch adds code which makes sure eraseblocks contain all 0xFF
    bytes before starting using them. The verification is done only when
    debugging checks are enabled.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 8f6035732a0484a84a1c9cd85312de234ddaa309
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 11:21:54 2009 +0300

    MAINTAINERS: update ahunter's e-mail address
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 7fcd9c3ecbf09c0a77db7ba01aac75b32fb79a93
Author: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Date:   Thu Jul 2 17:15:47 2009 +0200

    UBIFS: allow more than one volume to be mounted
   =20
    UBIFS uses a bdi device per volume, but does not care to hand out uni=
que
    names to each of them. This causes an error when trying to mount more
    than one volumes. Append the UBI volume and device ID to avoid that.
   =20
    [Amended a bit by Artem Bityutskiy]
   =20
    Signed-off-by: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
    Cc: Artem Bityutskiy <dedekind-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Cc: Adrian Hunter <ext-adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 1fb8bd01ed0af0d0577e010e8c6b4234de583fa6
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 18:31:58 2009 +0300

    UBIFS: fix assertion warning
   =20
    When debugging is enabled and an unclean file-system is mounter,
    the following assertion is triggered:
   =20
    UBIFS assert failed in ubifs_tnc_start_commit at 805 (pid 1081)
    Call Trace:
    [cfaffbd0] [c0006cf8] show_stack+0x44/0x16c (unreliable)
    [cfaffc10] [c011b738] ubifs_tnc_start_commit+0xbb8/0xd18
    [cfaffc90] [c0112670] do_commit+0x150/0xa44
    [cfaffd10] [c0125234] ubifs_rcvry_gc_commit+0xd8/0x544
    [cfaffd60] [c0100e9c] ubifs_fill_super+0xe78/0x15f8
    [cfaffdf0] [c0102118] ubifs_get_sb+0x20c/0x320
    [cfaffe70] [c007f764] vfs_kern_mount+0x58/0xe0
    [cfaffe90] [c007f83c] do_kern_mount+0x40/0xf8
    [cfaffeb0] [c0095c24] do_mount+0x550/0x758
    [cfafff10] [c0095ebc] sys_mount+0x90/0xe0
    [cfafff40] [c000ed4c] ret_from_syscall+0x0/0x3c
   =20
    The reason is that we initialize 'c->min_leb_idx' early, and do
    not re-calculate it after journal replay.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 681947d2fa1a00629de33c4df3ca72c39f06a14c
Author: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jun 24 09:59:38 2009 +0300

    UBIFS: minor spelling and grammar fixes
   =20
    Signed-off-by: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 44737589442bf69d811e003d9d0064b8fc1541d6
Author: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jun 24 10:15:12 2009 +0300

    UBIFS: fix 64-bit divisions in debug print
   =20
    Signed-off-by: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit cb54ef8b1304fe25f3d57031e0f85558a043239f
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 23 20:30:32 2009 +0300

    UBIFS: few spelling fixes
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 2a35a3a8ab3e94afd631ed4b45878ceb98f7ab28
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 23 20:26:33 2009 +0300

    UBIFS: set write-buffer timout to 3-5 seconds
   =20
    This patch cleans up write-buffer timeout initialization and
    sets it to 3-5 interval.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 0b335b9d7d5f0b832e90ac469480789c07be80ad
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 23 12:30:43 2009 +0300

    UBIFS: slightly optimize write-buffer timer usage
   =20
    This patch adds the following minor optimization:
   =20
    1. If write-buffer does not use the timer, indicate it with the
       wbuf->no_timer variable, instead of using the wbuf->softlimit
       variable. This is better because wbuf->softlimit is of ktime_t
       type, and the ktime_to_ns function contains 64-bit multiplication.
   =20
    2. Do not call the 'hrtimer_cancel()' function for write-buffers
       which do not use timers.
   =20
    3. Do not cancel the timer in 'ubifs_put_super()' because the
       synchronization function does this.
   =20
    This patch also removes a confusing comment.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 70aee2f153972f70fad5f7025134fec063f9efbe
Author: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jun 18 13:37:15 2009 +0300

    UBIFS: improve debugging messaged
   =20
    1. Make the I/O debugging message print the journal head number.
    2. Add prints to timer functions.
   =20
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit e3dc5a665d39112e98cfd5bbc7fda2963c00c12c
Author: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 22 17:31:09 2009 +0300

    UBIFS: fix integer overflow warning
   =20
    Fix the following warning:
   =20
    fs/ubifs/io.c: In function 'ubifs_wbuf_init':
    fs/ubifs/io.c:860: warning: integer overflow in expression
   =20
    And limit maximum hrtimer delta to ULONG_MAX because the
    argument is 'unsigned long'.
   =20
    Signed-off-by: Adrian Hunter <adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

commit 65b1bfc13e8f50034187e339aa12b81cd6785bd5
Author: Russell King <rmk-MIedHU+rSCMANfyc6IWni62ZND6+EDdj@public.gmane.org>
Date:   Sun Jul 5 11:52:21 2009 +0100

    [ARM] pgtable: file pte layout documentation
   =20
    Document the layout of our file PTE entries.
   =20
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit fb93a1c75eb646fde35985e9af23da936775ae52
Author: Russell King <rmk-MIedHU+rSCMANfyc6IWni62ZND6+EDdj@public.gmane.org>
Date:   Sun Jul 5 11:30:15 2009 +0100

    [ARM] pgtable: swp pte layout documentation, definitions, and check
   =20
    Document the layout of our swp PTE entries, adding definitions for
    the bit masks/shifts/sizes, and implement MAX_SWAPFILES_CHECK()
    such that we fail to build if we are unable to properly encode the
    swp type field.
   =20
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit ba9b42e4ff5eb68f9c946378229d7e45299d7151
Author: Russell King <rmk-MIedHU+rSCMANfyc6IWni62ZND6+EDdj@public.gmane.org>
Date:   Sun Jul 5 10:50:37 2009 +0100

    [ARM] export __cpu_flush_dcache_page
   =20
    Now required for libsas:
   =20
      Kernel: arch/arm/boot/Image is ready
      Kernel: arch/arm/boot/zImage is ready
      Building modules, stage 2.
      MODPOST 1096 modules
    ERROR: "xscale_flush_kern_dcache_page" [drivers/scsi/libsas/libsas.ko=
] undefined!
   =20
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit a22ebd069d5b533392e9bef77b73147a2f82b30b
Author: Josh Boyer <jwboyer-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sun Jul 5 10:02:15 2009 -0400

    powerpc/44x: Fix build error with -Werror for Warp platform
   =20
    With -Werror enabled during the build, the warp.c file fails to build
    due to the temp_isr function not containing a return statement.  This
    fixes the build error and documents that the function never returns.
   =20
    Signed-off-by: Josh Boyer <jwboyer-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit ba703e1a7a0b32f740bcfba8e60ad193afa4e723
Author: Sean MacLennan <smaclennan-Qtffpm9i2AVWk0Htik3J/w@public.gmane.org>
Date:   Sun Jun 28 11:22:51 2009 +0000

    powerpc/4xx: Have Warp take advantage of GPIO LEDs default-state =3D =
keep
   =20
    The GPIO LEDS driver now has a default state of "keep".  Update the W=
arp DTS
    and platform file to take advantage of this new state.  This removes =
the
    hardcoding of the two LEDs on the Warp.
   =20
    Signed-off-by: Sean MacLennan <smaclennan-Qtffpm9i2AVWk0Htik3J/w@public.gmane.org>
    Signed-off-by: Josh Boyer <jwboyer-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit 7c3a742a86055df1d18aac25bb8652735b3491ef
Author: Sean MacLennan <smaclennan-Qtffpm9i2AVWk0Htik3J/w@public.gmane.org>
Date:   Tue Jun 16 05:24:35 2009 +0000

    powerpc/44x: Update Warp defconfig
   =20
    * Enable GPIO LEDS and LED triggers
    * Move to SLUB
    * Enable HOTPLUG
    * Enable timestamps on printks
    * Enable UBIFS
    * Enable in-kernel config
   =20
    Signed-off-by: Sean MacLennan <smaclennan-Qtffpm9i2AVWk0Htik3J/w@public.gmane.org>
    Signed-off-by: Josh Boyer <jwboyer-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

commit c285addb3991c9b73b8d1a2b652ce0f1f67e90e1
Author: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jun 25 16:28:23 2009 -0300

    V4L/DVB (12134): vivi: bug: don't assume that S_STD will be called be=
fore streaming
   =20
    precalculate_bars() improved vivi performance. However, it assumed th=
at
    always before streaming, the driver would call VIDIOC_S_STD. This is =
not
    an API requirement, and the testing apps don't do that.
   =20
    Due to that, a regression were caused by the patch that added it.
   =20
    This patch moves the precalculate_bars to the proper place of the cod=
e,
    calling it at buffer_prepare() callback.
   =20
    Signed-off-by: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

commit aba6653617754e12763a0d3c9dda332b66190a50
Author: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date:   Sun Jul 5 11:44:46 2009 +0200

    ALSA: hda - Fix error path in the sanity check in azx_pcm_open()
   =20
    Release resources cleanly after errors in the sanity check in
    azx_pcm_open().
   =20
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit 805d127d62472f17c7d79baa001a7651afe2fa47
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 07:39:21 2009 +0200

    perf report: Add "Fractal" mode output - support callchains with rela=
tive overhead rate
   =20
    The current callchain displays the overhead rates as absolute:
    relative to the total overhead.
   =20
    This patch provides relative overhead percentage, in which each
    branch of the callchain tree is a independant instrumentated object.
   =20
    This provides a 'fractal' view of the call-chain profile: each
    sub-graph looks like a profile in itself - relative to its parent.
   =20
    You can produce such output by using the "fractal" mode
    that you can abbreviate via f, fr, fra, frac, etc...
   =20
    ./perf report -s sym -c fractal
   =20
    Example:
   =20
         8.46%  [k] copy_user_generic_string
                    |
                    |--52.01%-- generic_file_aio_read
                    |          do_sync_read
                    |          vfs_read
                    |          |
                    |          |--97.20%-- sys_pread64
                    |          |          system_call_fastpath
                    |          |          pread64
                    |          |
                    |           --2.81%-- sys_read
                    |                     system_call_fastpath
                    |                     __read
                    |
                    |--39.85%-- generic_file_buffered_write
                    |          __generic_file_aio_write_nolock
                    |          generic_file_aio_write
                    |          do_sync_write
                    |          reiserfs_file_write
                    |          vfs_write
                    |          |
                    |          |--97.05%-- sys_pwrite64
                    |          |          system_call_fastpath
                    |          |          __pwrite64
                    |          |
                    |           --2.95%-- sys_write
                    |                     system_call_fastpath
                    |                     __write_nocancel
    [...]
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246772361-9960-5-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit e05b876c222178bc6abcfa9f23d8311731691046
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 07:39:20 2009 +0200

    perf_counter tools: callchains: Manage the cumul hits on the fly
   =20
    The cumul hits are the number of hits of every childs of a node
    plus the hits of the current nodes, required for percentage
    computing of a branch.
   =20
    Theses numbers are calculated during the sorting of the branches of
    the callchain tree using a depth first postfix traversal, so that
    cumulative hits are propagated in the right order.
   =20
    But if we plan to implement percentages relative to the parent and no=
t
    absolute percentages (relative to the whole overhead), we need to kno=
w
    the cumulative hits of the parent before computing the children
    because the relative minimum acceptable number of entries (ie: minimu=
m
    rate against the cumulative hits from the parent) is the basis to
    filter the children against a given rate.
   =20
    Then we need to handle the cumul hits on the fly to prepare the
    implementation of relative overhead rates.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246772361-9960-4-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 94a8eb028a57854157a936c7e66b09e2559f115a
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 07:39:19 2009 +0200

    perf report: Change default callchain parameters
   =20
    The default callchain parameters are set to use the flat mode and nev=
er
    filter any overhead threshold of backtrace.
   =20
    But flat mode is boring compared to graph mode.
    Also the number of callchains may be very high if none is
    filtered.
   =20
    Let's change this to set the graph view and a minimum overhead of 0.5=
%
    as default parameters.
   =20
    Reported-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246772361-9960-3-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit be9038859e56f729cc9d3b070a35fb8829a73696
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 07:39:18 2009 +0200

    perf report: Use a modifiable string for default callchain options
   =20
    If the user doesn't provide options to tune his callchain output
    (ie: if he uses -c without arguments) then the default value passed
    in the OPT_CALLBACK_DEFAULT() macro is used.
   =20
    But it's parsed later by strtok() which will replace comma separators
    to a zero. This may segfault as we are using a read-only string.
   =20
    Use a modifiable one instead, and also fix the "100%" default
    minimum threshold value by turning it into a 0 (output every callchai=
ns)
    as it was intended in the origin.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246772361-9960-2-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 91b4eaea93f5be95f4477554399680a53aff2343
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jul 5 07:39:17 2009 +0200

    perf report: Warn on callchain output request from non-callchain file
   =20
    perf report segfaults while trying to handle callchains from a non
    callchain data file.
   =20
    Instead of a segfault, print a useful message to the user.
   =20
    Reported-by: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Reported-by: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246772361-9960-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit d9a0a345ab7a58a30ec38e5bb7401a28714914d2
Author: Jiro SEKIBA <jir-hfpbi5WX9J54Eiagz67IpQ@public.gmane.org>
Date:   Sat Jul 4 23:00:53 2009 +0900

    nilfs2: fix disorder in cp count on error during deleting checkpoints
   =20
    This fixes a bug that checkpoint count gets wrong on errors when
    deleting a series of checkpoints.
   =20
    The count error is persistent since the checkpoint count is stored on
    disk.  Some userland programs refer to the count via ioctl, and this
    bugfix is needed to prevent malfunction of such programs.
   =20
    Signed-off-by: Jiro SEKIBA <jir-hfpbi5WX9J54Eiagz67IpQ@public.gmane.org>
    Signed-off-by: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

commit ff54de363afa4583e2a6249f25fe21dfaeb11ea2
Author: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date:   Fri Jun 19 02:53:56 2009 +0900

    nilfs2: fix lockdep warning between regular file and inode file
   =20
    This will fix the following false positive of recursive locking which
    lockdep has detected:
   =20
    =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
    [ INFO: possible recursive locking detected ]
    2.6.30-nilfs #42
    ---------------------------------------------
    nilfs_cleanerd/10607 is trying to acquire lock:
     (&bmap->b_sem){++++-.}, at: [<e0d025b7>] nilfs_bmap_lookup_at_level+=
0x1a/0x74 [nilfs2]
   =20
    but task is already holding lock:
     (&bmap->b_sem){++++-.}, at: [<e0d024e0>] nilfs_bmap_truncate+0x19/0x=
6a [nilfs2]
    other info that might help us debug this:
    2 locks held by nilfs_cleanerd/10607:
     #0:  (&nilfs->ns_segctor_sem){++++.+}, at: [<e0d0d75a>] nilfs_transa=
ction_begin+0xb6/0x10c [nilfs2]
     #1:  (&bmap->b_sem){++++-.}, at: [<e0d024e0>] nilfs_bmap_truncate+0x=
19/0x6a [nilfs2]
   =20
    Signed-off-by: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>

commit 4a52df779700080de4afb0436d9dd9188514a69b
Author: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date:   Thu Jun 18 23:53:25 2009 +0900

    nilfs2: fix incorrect KERN_CRIT messages in case of write failures
   =20
    In case of write-failure retries, the following KERN_CRIT level
    messages are mistakenly output by nilfs_dat_commit_start() function:
   =20
    nilfs_dat_commit_start: vbn =3D 408463, start =3D 12506, end =3D 1844=
6744073709551615, pbn =3D 530210
    nilfs_dat_commit_start: vbn =3D 408515, start =3D 12506, end =3D 1844=
6744073709551615, pbn =3D 530211
    nilfs_dat_commit_start: vbn =3D 408464, start =3D 12506, end =3D 1844=
6744073709551615, pbn =3D 530212
    ...
   =20
    This suppresses these messages.
   =20
    Signed-off-by: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

commit 8227b29722fdbac72357aae155d171a5c777670c
Author: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date:   Thu Jun 18 23:52:23 2009 +0900

    nilfs2: fix hang problem of log writer which occurs after write failu=
res
   =20
    Leandro Lucarella gave me a report that nilfs gets stuck after its
    write function fails.
   =20
    The problem turned out to be caused by bugs which leave writeback fla=
g
    on pages.  This fixes the problem by ensuring to clear the writeback
    flag in error path.
   =20
    Reported-by: Leandro Lucarella <llucax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

commit 0cfae3d8795f388f9de78adb0171520d19da77e9
Author: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Date:   Thu Jun 18 11:42:53 2009 +0900

    nilfs2: remove unlikely directive causing mis-conversion of error cod=
e
   =20
    The following error code handling in nilfs_segctor_write() function
    wrongly converted negative error codes to a truth value (i.e. 1):
   =20
       err =3D unlikely(err) ? : res;
   =20
    which originaly meant to be
   =20
       err =3D err ? : res;
   =20
    This mis-conversion caused that write or sync functions receive the
    unexpected error code.  This fixes the bug by removing the unlikely
    directive.
   =20
    Signed-off-by: Ryusuke Konishi <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

commit febe04de3be4bf66f9339d8847db2806d99fd164
Author: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 11:13:07 2009 +0900

    x86: fix usage of bios intcall()
   =20
    Some intcall() misuses the input biosregs as output in
    cf06de7b9cdd3efee7a59dced1977b3c21d43732
   =20
    This fixes the problem vga=3Dask boot option doesn't show enough mode=
s.
   =20
    Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <20090701021307.GA3127-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
    Signed-off-by: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>

commit 3dfc813d94bba2046c6aed216e0fd69ac93a8e03
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 19:11:08 2009 +0100

    intel-iommu: Don't use identity mapping for PCI devices behind bridge=
s
   =20
    Our current strategy for pass-through mode is to put all devices into
    the 1:1 domain at startup (which is before we know what their dma_mas=
k
    will be), and only _later_ take them out of that domain, if it turns =
out
    that they really can't address all of memory.
   =20
    However, when there are a bunch of PCI devices behind a bridge, they =
all
    end up with the same source-id on their DMA transactions, and hence i=
n
    the same IOMMU domain. This means that we _can't_ easily move them fr=
om
    the 1:1 domain into their own domain at runtime, because there might =
be DMA
    in-flight from their siblings.
   =20
    So we have to adjust our pass-through strategy: For PCI devices not o=
n
    the root bus, and for the bridges which will take responsibility for
    their transactions, we have to start up _out_ of the 1:1 domain, just=
 in
    case.
   =20
    This fixes the BUG() we see when we have 32-bit-capable devices behin=
d a
    PCI-PCI bridge, and use the software identity mapping.
   =20
    It does mean that we might end up using 'normal' mapping mode for som=
e
    devices which could actually live with the faster 1:1 mapping -- but
    this is only for PCI devices behind bridges, which presumably aren't =
the
    devices for which people are most concerned about performance.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 6941af2810c6fc970b88f7c0d52ba4e286acbee5
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 18:24:27 2009 +0100

    intel-iommu: Use iommu_should_identity_map() at startup time too.
   =20
    At boot time, the dma_mask won't have been set on any devices, so we
    assume that all devices will be 64-bit capable (and thus get a 1:1 ma=
p).
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 9731f4a202f29ff402ea2ddad7ff6f3a559c0c82
Author: Magnus Damm <damm-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
Date:   Fri Jul 3 09:40:03 2009 +0000

    sh: add r8a66597 usb0 host to the se7724 board
   =20
    Add USB host support for port CN27 on the Solution Engine 7724
    board. The r8a66597-hcd driver is hooked up as a platform device
    and some registers are configured to enable the USB host function.
    The hardware driving the USB port is the on-chip USB0 block in
    the sh7724 processor configured as USB host controller.
   =20
    Signed-off-by: Magnus Damm <damm-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit 64614e66fbfcaa57598c1678d699520dfbf4f531
Author: Magnus Damm <damm-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
Date:   Fri Jul 3 09:12:46 2009 +0000

    usb: allow sh7724 to enable on-chip r8a66597
   =20
    The sh7724 processor has two on-chip r8a66597 blocks, so add
    it to the list of processors for SUPERH_ON_CHIP_R8A66597.
   =20
    Signed-off-by: Magnus Damm <damm-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit 736768325efcbee7b0861d62670d01a54c2d158b
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 14:08:36 2009 +0100

    intel-iommu: No mapping for non-PCI devices
   =20
    This should fix kernel.org bug #11821, where the dcdbas driver makes =
up
    a platform device and then uses dma_alloc_coherent() on it, in an
    attempt to get memory < 4GiB.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 02358fcfa54ce018a0bb56ca9f5a898de574a9d3
Author: Herton Ronaldo Krzesinski <herton-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org>
Date:   Sat Jul 4 01:44:59 2009 -0300

    ALSA: hda - move 8086:fb30 quirk (stac9205) to the proper section
   =20
    Signed-off-by: Herton Ronaldo Krzesinski <herton-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org>
    Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>

commit 62edf5dc4a524e4cb525e6020b955a1ad593d9ba
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 10:59:46 2009 +0100

    intel-iommu: Restore DMAR_BROKEN_GFX_WA option for broken graphics dr=
ivers
   =20
    We need to give people a little more time to fix the broken drivers.
    Re-introduce this, but tied in properly with the 'iommu=3Dpt' support=
 this
    time. Change the config option name and make it default to 'no' too.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 40e4aa34324bff3938a900014254f88943d05e15
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 10:55:41 2009 +0100

    intel-iommu: Add iommu_should_identity_map() function
   =20
    We do this twice, and it's about to get more complicated. This makes =
the
    code slightly clearer about what it's doing, too.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 1b7bc0a1618b4de1e6f55c6d95b790f4ab6fcd9e
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 10:49:46 2009 +0100

    intel-iommu: Fix reattaching of devices to identity mapping domain
   =20
    When we reattach a device to the si_domain (because it's been removed
    from a VM), we weren't calling domain_context_mapping() to actually t=
ell
    the hardware about that.
   =20
    We should really put the call to domain_context_mapping() into
    domain_add_dev_info() -- we never call the latter without also doing =
the
    former, and we can keep the error paths simple that way. But that's a
    cleanup which can wait for 2.6.32 now.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit a79f0da80a508448434476b77f9d3d1a469eab67
Author: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 16:50:10 2009 +0200

    x86: atomic64: Inline atomic64_read() again
   =20
    Now atomic64_read() is light weight (no register pressure and
    small icache), we can inline it again.
   =20
    Also use "=3D&A" constraint instead of "+A" to avoid warning
    about unitialized 'res' variable. (gcc had to force 0 in eax/edx)
   =20
      $ size vmlinux.prev vmlinux.after
         text    data     bss     dec     hex filename
      4908667  451676 1684868 7045211  6b805b vmlinux.prev
      4908651  451676 1684868 7045195  6b804b vmlinux.after
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <4A4E1AA2.30002-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    [ Also fix typo in atomic64_set() export ]
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 1e4c64c46d413de84cc0b786bd6a9b555ba7d111
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 10:40:38 2009 +0100

    intel-iommu: Don't set identity mapping for bypassed graphics devices
   =20
    We should check iommu_dummy() _first_, because that means it's attach=
ed
    to an iommu that we've just disabled completely. At the moment, we mi=
ght
    try to put the device into the identity mapping domain.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit 5a5e02a614e59db7536cd11029e6674adc41b191
Author: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sat Jul 4 09:35:44 2009 +0100

    intel-iommu: Fix dma vs. mm page confusion with aligned_nrpages()
   =20
    The aligned_nrpages() function rounds up to the next VM page, but
    returns its result as a number of DMA pages.
   =20
    Purely theoretical except on IA64, which doesn't boot with VT-d right
    now anyway.
   =20
    Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

commit c001c213b109c8baeeb6d012b422bf059b18368f
Author: Sathya Perla <sathyap-i5Eg4PDOvn3+uv41P6q33AC/G2K4zDHf@public.gmane.org>
Date:   Wed Jul 1 01:06:07 2009 +0000

    be2net: fix spurious interrupt handling in intx mode
   =20
    Occasionally we may see an interrupt without an event in the eq.
    In intx, we currently see the event queue and return IRQ_NONE causing
    a the irq to be disabled ("no one cared".) Instead, read the CEV_ISR
    reg to check the existence of the interrupt.
   =20
    Signed-off-by: Sathya Perla <sathyap-i5Eg4PDOvn3+uv41P6q33AC/G2K4zDHf@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 7d3cabbcc86f7f69c47cb20c23ee84350ae6cfbb
Author: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:29:08 2009 +0000

    e1000e: disable K1 at 1000Mbps for 82577/82578
   =20
    This workaround is required for an issue in hardware where noise on t=
he
    interconnect between the MAC and PHY could be generated by a lower po=
wer
    mode (K1) at 1000Mbps resulting in bad packets.  Disable K1 while at =
1000
    Mbps but keep it enabled for 10/100Mbps and when the cable is disconn=
ected.
   =20
    Signed-off-by: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 906e8d9792b1c4a8b58c1383f4c00fc4c9936fc3
Author: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:28:50 2009 +0000

    e1000e: delay second read of PHY_STATUS register on failure of first =
read
   =20
    Some PHYs may require two reads of the PHY_STATUS register to determi=
ne the
    link status.  If the PHY is being accessed by another thread it is po=
ssible
    the first read could timeout and fail.  In this case, put a delay in =
so
    the second read will pick up the correct link status.
   =20
    Signed-off-by: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 28c9195a570a32de2760310ca278d44a4fd060a4
Author: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:28:32 2009 +0000

    e1000e: prevent NVM corruption on sectors larger than 4K
   =20
    Limit NVM writes to 4K sections to prevent NVM corruption on larger
    sector allocations (up to 64K).
   =20
    Signed-off-by: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 60f1292fcbdff03ef5caea56404d3d81d05026f6
Author: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:28:14 2009 +0000

    e1000e: do not write SmartSpeed register bits on parts without suppor=
t
   =20
    The driver was accessing register bits for features on parts that do
    not support that feature.  This could cause problems in the hardware.
   =20
    Signed-off-by: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit fc0c7760aea07c74af3395ad18f96ba62eecac36
Author: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:27:55 2009 +0000

    e1000e: delay after LCD reset and proper checks for PHY configuration=
 done
   =20
    A previous workaround for 82578 to avoid link stall causes some PHY
    registers to get cleared inadvertently.  Add a delay after all LCD re=
sets
    to make sure PHY registers are in a stable state before continuing.  =
Also,
    after resets check the EEC register for the state of PHY configuratio=
n
    performed by the MAC for ICH9 and earlier parts (as done before), but=
 check
    the LAN_INIT_DONE bit in the STATUS register for ICH10 and newer part=
s (EEC
    doesn't exist in these newer parts).
   =20
    Signed-off-by: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit e65fa87c225fadd1980068b7d360e08ac0e985dd
Author: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:27:31 2009 +0000

    e1000e: PHY loopback broken on 82578
   =20
    PHY loopback on 82578 fails to work as a result of flushing the packe=
ts
    in the FIFO buffer in the link stall workaround.  Don't perform the
    workaround if in PHY loopback mode.
   =20
    Signed-off-by: Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit e5d57af52464f37dd3c67906a493a6400bc51b43
Author: Mallikarjuna R Chilakala <mallikarjuna.chilakala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 12:51:10 2009 +0000

    ixgbe: Not allow 8259x unsupported wol options change from ethtool
   =20
    Wake-on-lan is currently only supported by 82599 KX4 devices, in all
    other cases return a proper value from ixgbe_wol_exclusion function c=
all.
    Otherwise from ethtool we will be able to change wol options of
    unsupported 8259x devices.
   =20
    Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel=
.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 5da43c1a78cbc16518017dfb058da6ec4829781b
Author: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 12:50:52 2009 +0000

    ixgbe: fix inconsistent SFP/SFP+ failure results.
   =20
    Currently if we loaded the driver, insert an unsupported module, and =
then
    attempt to "ifconfig up" the device it will be brought down but the n=
etdev
    would not be unregistered. This behavior is different than all other
    code paths. This patch corrects that by down'ing the device and then
    scheduling the sfp_config_module_task tasklet. The tasklet will detec=
t
    this condition (like it does with other code paths) and do the
    unregister_netdev().
   =20
    I also removed the log message as this condition (an unsupported SFP+
    module) will be logged in sfp_config_module_task.
   =20
    Signed-off-by: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 19343de279d28e4ed039c8ad00510d19dc4d6d12
Author: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 12:50:31 2009 +0000

    ixgbe: fix regression on some 82598 adapters
   =20
    The change to check the SFP+ module again on open() was
    causing the XFP (non-SFP+) adapters to be rejected. We
    only want to try and re-identify the SFP+ module if the
    original probe found that this device was an SFP+ device.
    So for this code path (driver loaded with SFP module, module
    inserted, ifconfig up of the device) the type will be
    ixgbe_phy_unknown for an unidentified SFP+ module.  So we
    only check if that is the case.
   =20
    This problem also shows up on Copper devices.
   =20
    Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org=
>
    Signed-off-by: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 63d6e1d80a8c3118be2ca0f1f21ba883f282060c
Author: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 12:50:12 2009 +0000

    ixgbe: fix issues with failing to detect insert of unsupported module
   =20
    Several small fixes around negative test case of the insertion of a
    IXGBE_ERR_NOT_SUPPORTED module.
   =20
    - mdio45_probe call was always failing due to mdio.prtad not being
    set.  The function set to mdio.mdio_read was still working as we just
    happen to always be at prtad =3D=3D 0.  This will allow us to set the=
 phy_id
    and phy.type correctly now.
   =20
    - There was timing issue with i2c calls when initiated from a tasklet.
    A small delay was added to allow the electrical oscillation to calm d=
own.
   =20
    - Logic change in ixgbe_sfp_task that allows NOT_SUPPORTED condition
    to be recognized.
   =20
    Signed-off-by: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit e332471c035708441de89d4c59f7f7cdc2700c0d
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:13 2009 +0000

    qlge: Fix sizeof usage.
   =20
    Some usage was only sizing a pointer rather than the data type.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 6a47330892e697ae27d2d56a3c4c7fec2015be93
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:12 2009 +0000

    qlge: Add/use function for link up/down.
   =20
    We need to set/clear the mac address register when the link goes up/d=
own
    respectively.  Without this both ports of a 2-port device can end up
    with the same mac address in a bonding scenario.
    The new ql_link_on() and ql_link_off() will also be used in handling
    certain firmware events.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 7fab3bfe08a2c5c4221685499ec4fef83ad82f83
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:11 2009 +0000

    qlge: Fix MAC address bonding issue.
   =20
    This addes functionality to set/clear the MAC address in the hardware
    when the link goes up/down.
    The MAC address register is persistent across function resets. In
    bonding the same address can bounce from one port to the other.  This
    can cause packets to be delivered to the wrong port.
    This patch clears the MAC address in the hardware when the link is do=
wn
    and sets it when the link comes up.
    It was found that pulling/pushing the cable from one port to another
    causes the same MAC address to be in both ports.
    The next patch in this series will use this functionality as well.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 13cfd5be53d01a9316907512f17f34d3858450e8
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:10 2009 +0000

    qlge: Fix tx byte counter.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 6e9e4795e688fd61fa83f7f4cad4992939fd4ca3
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:09 2009 +0000

    qlge: Fix redundant call to free resources.
   =20
    The caller will free acquired resouces if a failure occurs.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 8b007de19026e91991ae70ca0def31c42435e008
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:08 2009 +0000

    qlge: Fix carrier on condition.
   =20
    We were turning on the carrier without verifying the link was up.
    This adds link up to the link initialize check before turning carrier
    on.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit a5f59dc926844bf95be2261c1bb0a24597b7a8c5
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:07 2009 +0000

    qlge: Clear frame to queue routing before reset.
   =20
    Not clearing the routing bits can cause frames to erroneously get rou=
ted to
    management processor.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 4322c5bee85ed58042ec04235ec7086065ad5074
Author: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 06:06:06 2009 +0000

    qlge: Expand coverage of hw lock for config register.
   =20
    The hardware semaphore covers the configuration register as well as t=
he
    ICB registers.  The ICB high and low regs contain the address of the
    initialization control block and the config register is used to signa=
l
    the hardware that a block is ready to be downloaded.  Currently we we=
re
    only protecting the ICB regs.  This changes expands to cover the conf=
ig
    register as well.
   =20
    Signed-off-by: Ron Mercer <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit a1ed05263b74921742b454ef52c30b609ec6940f
Author: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Date:   Thu Jul 2 07:10:52 2009 +0000

    IPv6: preferred lifetime of address not getting updated
   =20
    There's a bug in addrconf_prefix_rcv() where it won't update the
    preferred lifetime of an IPv6 address if the current valid lifetime
    of the address is less than 2 hours (the minimum value in the RA).
   =20
    For example, If I send a router advertisement with a prefix that
    has valid lifetime =3D preferred lifetime =3D 2 hours we'll build
    this address:
   =20
    3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
        inet6 2001:1890:1109:a20:217:8ff:fe7d:4718/64 scope global dynami=
c
           valid_lft 7175sec preferred_lft 7175sec
   =20
    If I then send the same prefix with valid lifetime =3D preferred
    lifetime =3D 0 it will be ignored since the minimum valid lifetime
    is 2 hours:
   =20
    3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
        inet6 2001:1890:1109:a20:217:8ff:fe7d:4718/64 scope global dynami=
c
           valid_lft 7161sec preferred_lft 7161sec
   =20
    But according to RFC 4862 we should always reset the preferred lifeti=
me
    even if the valid lifetime is invalid, which would cause the address
    to immediately get deprecated.  So with this patch we'd see this:
   =20
    5: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
        inet6 2001:1890:1109:a20:21f:29ff:fe5a:ef04/64 scope global depre=
cated dynamic
           valid_lft 7163sec preferred_lft 0sec
   =20
    The comment winds-up being 5x the size of the code to fix the problem.
   =20
    Update the preferred lifetime of IPv6 addresses derived from a prefix
    info option in a router advertisement even if the valid lifetime in
    the option is invalid, as specified in RFC 4862 Section 5.5.3e.  Fixe=
s
    an issue where an address will not immediately become deprecated.
    Reported by Jens Rosenboom.
   =20
    Signed-off-by: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 59cae0092e4da753b5a2adb32933e0d1b223bcc5
Author: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Thu Jul 2 16:59:49 2009 +0000

    xfrm6: fix the proto and ports decode of sctp protocol
   =20
    The SCTP pushed the skb above the sctp chunk header, so the
    check of pskb_may_pull(skb, nh + offset + 1 - skb->data) in
    _decode_session6() will never return 0 and the ports decode
    of sctp will always fail. (nh + offset + 1 - skb->data < 0)
   =20
    Signed-off-by: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Acked-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit c615c9f3f3cea60279b1bb38e8ef27bd575ecd0c
Author: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Thu Jul 2 16:57:23 2009 +0000

    xfrm4: fix the ports decode of sctp protocol
   =20
    The SCTP pushed the skb data above the sctp chunk header, so the chec=
k
    of pskb_may_pull(skb, xprth + 4 - skb->data) in _decode_session4() wi=
ll
    never return 0 because xprth + 4 - skb->data < 0, the ports decode of
    sctp will always fail.
   =20
    Signed-off-by: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Acked-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit ddf9a003d32f720805ac30bcc15755e9289073de
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 20:11:30 2009 +0200

    x86: atomic64: Clean up atomic64_sub_and_test() and atomic64_add_nega=
tive()
   =20
    Linus noticed that the variable name 'old_val' is
    confusingly named in these functions - the correct
    naming is 'new_val'.
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907030942260.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 3a8d1788b37435baf6c296f4ea8beb4fa4955f44
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 19:56:36 2009 +0200

    x86: atomic64: Improve atomic64_xchg()
   =20
    Remove the read-first logic from atomic64_xchg() and simplify
    the loop.
   =20
    This function was the last user of __atomic64_read() - remove it.
   =20
    Also, change the 'real_val' assumption from the somewhat quirky
    1ULL << 32 value to the (just as arbitrary, but simpler) value
    of 0.
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <tip-05118ab8859492ac9ddda0154cf90e37b0a4a0b0-UBY8oZYcAkM@public.gmane.org=
nel.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 1fde902d52ee13ab9fab155bbae757fdf7daf0c1
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 17:28:57 2009 +0200

    x86: atomic64: Export APIs to modules
   =20
    atomic64_t primitives are used by a handful of drivers,
    so export the APIs consistently. These were inlined
    before.
   =20
    Also mark atomic64_32.o a core object, so that the symbols
    are available even if not linked to core kernel pieces.
   =20
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <tip-05118ab8859492ac9ddda0154cf90e37b0a4a0b0-UBY8oZYcAkM@public.gmane.org=
nel.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 637a935aaba2f05e2178c9d1b714d7a2c36c8b44
Author: Lars-Peter Clausen <lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org>
Date:   Fri Jul 3 01:04:16 2009 +0200

    ASoC: Fix wm8753 register cache size and initialization
   =20
    Register cache space was not being allocated for the final register,
    causing bugs when it was used.  Allocate space for it.
   =20
    Also ensure that the final register is displayed in sysfs.
   =20
    [Commit message rewritten to document actual issue. -- broonie]
   =20
    Signed-off-by: Lars-Peter Clausen <lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org>
    Signed-off-by: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>

commit 67d7178f8fc64b7f68d7dd8a1b21dfa0d42c220c
Author: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 13:23:02 2009 +0200

    x86: atomic64: Improve atomic64_read()
   =20
    Optimize atomic64_read() as a special open-coded
    cmpxchg8b variant. This generates nicer code:
   =20
    arch/x86/lib/atomic64_32.o:
   =20
       text	   data	    bss	    dec	    hex	filename
        435	      0	      0	    435	    1b3	atomic64_32.o.before
        431	      0	      0	    431	    1af	atomic64_32.o.after
   =20
    md5:
       bd8ab95e69c93518578bfaf0ea3be4d9  atomic64_32.o.before.asm
       2bdfd4bd1f6b7b61b7fc127aef90ce3b  atomic64_32.o.after.asm
   =20
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 8e049ef054f1cc765f05f13e1396bb9a17c19e66
Author: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Thu Jul 2 08:57:12 2009 +1000

    x86: atomic64: Code atomic(64)_read and atomic(64)_set in C not CPP
   =20
    Occasionally we get bugs where atomic_read or atomic_set are
    used on atomic64_t variables or vice versa.  These bugs don't
    generate warnings on x86 because atomic_read and atomic_set are
    coded as macros rather than C functions, so we don't get any
    type-checking on their arguments; similarly for atomic64_read
    and atomic64_set in 64-bit kernels.
   =20
    This converts them to C functions so that the arguments are
    type-checked and bugs like this will get caught more easily. It
    also converts atomic_cmpxchg and atomic_xchg, and
    atomic64_cmpxchg and atomic64_xchg on 64-bit, so we get
    type-checking on their arguments too.
   =20
    Compiling a typical 64-bit x86 config, this generates no new
    warnings, and the vmlinux text is 86 bytes smaller.
   =20
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 22a26e6663008e1fc4d1467aaff7e775124bce31
Merge: c7210e1ff8a95a0a6dba0d04a95b3ddd9d165fab 1bc6f83813441d15a74dfa979=
66fb68fa1bdec76
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 14:35:02 2009 +0200

    Merge branch 'amd-iommu/fixes' of git://git.kernel.org/pub/scm/linux/=
kernel/git/joro/linux-2.6-iommu into x86/urgent

commit c7210e1ff8a95a0a6dba0d04a95b3ddd9d165fab
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Thu Jul 2 22:35:35 2009 +0530

    x86: Remove unused function lapic_watchdog_ok()
   =20
    lapic_watchdog_ok() is a global function but no one is using it.
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
    Cc: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    LKML-Reference: <1246554335.2242.29.camel-CPyRvq6ZSiQZljRQcayd8Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 23d0cd8e718723f1ddda37637bc6b7c34caec64a
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Thu Jul 2 22:33:59 2009 +0530

    x86: Remove unused variable disable_x2apic
   =20
    setup_nox2apic() is writing 1 to disable_x2apic but no one is reading=
 it.
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <1246554239.2242.27.camel-CPyRvq6ZSiQZljRQcayd8Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit d3ac88157c1e9153f37cd2b9313117ae11735063
Author: Rakib Mullick <rakib.mullick-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 11:40:36 2009 +0600

    x86, kvm: Fix section mismatches in kvm.c
   =20
    The function paravirt_ops_setup() has been refering the
    variable no_timer_check, which is a __initdata. Thus generates
    the following warning. paravirt_ops_setup() function is called
    from kvm_guest_init() which is a __init function. So to fix
    this we mark paravirt_ops_setup as __init.
   =20
    The sections-check output that warned us about this was:
   =20
       LD      arch/x86/built-in.o
      WARNING: arch/x86/built-in.o(.text+0x166ce): Section mismatch in
      reference from the function paravirt_ops_setup() to the variable
      .init.data:no_timer_check
      The function paravirt_ops_setup() references
      the variable __initdata no_timer_check.
      This is often because paravirt_ops_setup lacks a __initdata
      annotation or the annotation of no_timer_check is wrong.
   =20
    Signed-off-by: Rakib Mullick <rakib.mullick-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Acked-by: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    LKML-Reference: <b9df5fa10907012240y356427b8ta4bd07f0efc6a049-Rq2MYuBUFGs@public.gmane.org=
ail.com>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 3fd382cedfb4fb742a8cc17ba15288ec03131db1
Author: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date:   Thu Jul 2 07:27:20 2009 +0200

    x86: Add missing annotation to arch/x86/lib/copy_user_64.S::copy_to_u=
ser
   =20
    While examining symbol generation in perf_counter tools, I
    noticed that copy_to_user() had no size in vmlinux's symtab.
   =20
    Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Acked-by: Alexander van Heukelum <heukelum-97jfqw80gc6171pxa8y+qA@public.gmane.org>
    Acked-by: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
    LKML-Reference: <1246512440.13293.3.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 12b9d7ccb841805e347fec8f733f368f43ddba40
Author: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Date:   Wed Jul 1 17:37:22 2009 -0400

    x86: Fix fixmap page order for FIX_TEXT_POKE0,1
   =20
    Masami reported:
   =20
    > Since the fixmap pages are assigned higher address to lower,
    > text_poke() has to use it with inverted order (FIX_TEXT_POKE1
    > to FIX_TEXT_POKE0).
   =20
    I prefer to just invert the order of the fixmap declaration.
    It's simpler and more straightforward.
   =20
    Backward fixmaps seems to be used by both x86 32 and 64.
   =20
    It's really rare but a nasty bug, because it only hurts when
    instructions to patch are crossing a page boundary. If this
    happens, the fixmap write accesses will spill on the following
    fixmap, which may very well crash the system. And this does not
    crash the system, it could leave illegal instructions in place.
    Thanks Masami for finding this.
   =20
    It seems to have crept into the 2.6.30-rc series, so this calls
    for a -stable inclusion.
   =20
    Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
    Acked-by: Masami Hiramatsu <mhiramat-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    LKML-Reference: <20090701213722.GH19926@Krystal>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 199e23780a7e75c63a9e3d1108804e3af450ea3e
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 13:02:39 2009 +0200

    x86: atomic64: Fix unclean type use in atomic64_xchg()
   =20
    Linus noticed that atomic64_xchg() uses atomic_read(), which
    happens to work because atomic_read() is a macro so the
    .counter value gets u64-read on 32-bit too - but this is really
    bogus and serious bugs are waiting to happen.
   =20
    Fix atomic64_xchg() to use __atomic64_read() instead.
   =20
    No code changed:
   =20
    arch/x86/lib/atomic64_32.o:
   =20
       text	   data	    bss	    dec	    hex	filename
        435	      0	      0	    435	    1b3	atomic64_32.o.before
        435	      0	      0	    435	    1b3	atomic64_32.o.after
   =20
    md5:
       bd8ab95e69c93518578bfaf0ea3be4d9  atomic64_32.o.before.asm
       bd8ab95e69c93518578bfaf0ea3be4d9  atomic64_32.o.after.asm
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 3217120873598533234b6dedda9c371ce30001d0
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 13:06:01 2009 +0200

    x86: atomic64: Make atomic_read() type-safe
   =20
    Linus noticed that atomic64_xchg() uses atomic_read(), which
    happens to work because atomic_read() is a macro so the
    .counter value gets u64-read on 32-bit too - but this is really
    bogus and serious bugs are waiting to happen.
   =20
    Change atomic_read() to be a type-safe inline, and this exposes
    the atomic64 bogosity as well:
   =20
      arch/x86/lib/atomic64_32.c: In function =E2=80=98atomic64_xchg=E2=80=
=99:
      arch/x86/lib/atomic64_32.c:39: warning: passing argument 1 of =E2=80=
=98atomic_read=E2=80=99 from incompatible pointer type
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 3ac805d2afd3fa4a07cb5bcf352fd7fa83f28935
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 12:51:19 2009 +0200

    x86: atomic64: Reduce size of functions
   =20
    cmpxchg8b is a huge instruction in terms of register footprint,
    we almost never want to inline it, not even within the same
    code module.
   =20
    GCC 4.3 still messes up for two functions, under-judging the
    true cost of this instruction - so annotate two key functions
    to reduce the bloat:
   =20
    arch/x86/lib/atomic64_32.o:
   =20
       text	   data	    bss	    dec	    hex	filename
       1763	      0	      0	   1763	    6e3	atomic64_32.o.before
        435	      0	      0	    435	    1b3	atomic64_32.o.after
   =20
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 824975ef190e7dcb77718d1cc2cb53769b16d918
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 12:39:07 2009 +0200

    x86: atomic64: Improve atomic64_add_return()
   =20
    Linus noted (based on Eric Dumazet's numbers) that we would
    probably be better off not trying an atomic_read() in
    atomic64_add_return() but intead intentionally let the first
    cmpxchg8b fail - to get a cache-friendly 'give me ownership
    of this cacheline' transaction. That can then be followed
    by the real cmpxchg8b which sets the value local to the CPU.
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 69237f94e65d3d7f539f1adb98ef68685c595004
Author: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 13:26:41 2009 +0200

    x86: atomic64: Improve cmpxchg8b()
   =20
    Rewrite cmpxchg8b() to not use %edi register but a generic "+m"
    constraint, to increase compiler freedom in code generation and
    possibly better code.
   =20
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit aacf682fd8c66b57383c407eecd9d4a28264ee91
Author: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 12:14:27 2009 +0200

    x86: atomic64: Improve atomic64_read()
   =20
    Linus noticed that the 32-bit version of atomic64_read() was
    being overly complex with re-reading the value and doing a
    retry loop over that.
   =20
    Instead we can just rely on cmpxchg8b returning either the new
    value or returning the current value.
   =20
    We can use any 'old' value, which will be faster as it can be
    loaded via immediates. Using some value that is not equal to
    the real value in memory the instruction gets faster.
   =20
    This also has the advantage that the CPU could avoid dirtying
    the cacheline.
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit b7882b7c65abb00194bdb3d4a22d27d70fcc59ba
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 13:26:39 2009 +0200

    x86: atomic64: Move the 32-bit atomic64_t implementation to a .c file
   =20
    Linus noted that the atomic64_t primitives are all inlines
    currently which is crazy because these functions have a large
    register footprint anyway.
   =20
    Move them to a separate file: arch/x86/lib/atomic64_32.c
   =20
    Also, while at it, rename all uses of 'unsigned long long' to
    the much shorter u64.
   =20
    This makes the appearance of the prototypes a lot nicer - and
    it also uncovered a few bugs where (yet unused) API variants
    had 'long' as their return type instead of u64.
   =20
    [ More intrusive changes are not yet done in this patch. ]
   =20
    Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit bbf2a330d92c5afccfd17592ba9ccd50f41cf748
Author: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Fri Jul 3 00:08:26 2009 +0200

    x86: atomic64: The atomic64_t data type should be 8 bytes aligned on =
32-bit too
   =20
    Locked instructions on two cache lines at once are painful. If
    atomic64_t uses two cache lines, my test program is 10x slower.
   =20
    The chance for that is significant: 4/32 or 12.5%.
   =20
    Make sure an atomic64_t is 8 bytes aligned.
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
    LKML-Reference: <alpine.LFD.2.01.0907021653030.3210-bi+AKbBUZKY6gyzm1THtWWGXanvQGlWp@public.gmane.org=
main>
    [ changed it to __aligned(8) as per Andrew's suggestion ]
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 029e5b1636d0511ef143af3a20c83c48e44c03f3
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 13:17:28 2009 +0200

    perf report: Annotate variable initialization
   =20
    Certain versions of GCC dont see the initialization that is done here=
:
   =20
      builtin-report.c: In function =E2=80=98__cmd_report=E2=80=99:
      builtin-report.c:1038: warning: =E2=80=98syms=E2=80=99 may be used =
uninitialized in this function
   =20
    So annotate it with a NULL initialization.
   =20
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <new-submission>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 0827d6ba0b76be398a3c4298afd41f4965d2cdcb
Author: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Date:   Thu Jul 2 11:57:25 2009 -0600

    ASoC: add locking to mpc5200-psc-ac97 driver
   =20
    AC97 bus register read/write hooks need to provide locking, but the
    mpc5200-psc-ac97 driver does not.  This patch adds a mutex around
    the register access routines.
   =20
    Signed-off-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
    Acked-by: Jon Smirl <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>

commit 07573534b0b030226ee5ab560e53aac7e6c0dd84
Author: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Date:   Thu Jul 2 11:57:19 2009 -0600

    ASoC: Fix mpc5200-psc-ac97 to ensure the data ready bit is cleared
   =20
    When doing register reads, it is possible for there to be a stale
    data ready bit set which will cause subsequent reads to return
    prematurely with incorrect data.  This patch fixes the issues by
    ensuring stale data is cleared before starting another transaction.
   =20
    Signed-off-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
    Acked-by: Jon Smirl <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>

commit 1df892cba45f9856d369a6a317ad2d1e44bca423
Author: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
Date:   Fri Jul 3 10:33:39 2009 +0100

    ASoC: Fix register cache initialisation for WM8753
   =20
    The wrong register cache variable was being used to provide the size =
for
    the memcpy(), resulting in a copy of only a void * of data.
   =20
    Reported-by: Lars-Peter Clausen <lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org>
    Signed-off-by: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

commit c222dce48cb2adf5ed68201fb2a59d00544b9a74
Merge: f6faac71d502be1c29c81b2f45657662c3b84470 b0a5b83ee0fce9dbf8ff5fe1f=
8c9ae7dfafe458c
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Fri Jul 3 11:03:10 2009 +0200

    Merge branch 'dma-debug/fixes' of git://git.kernel.org/pub/scm/linux/=
kernel/git/joro/linux-2.6-iommu into core/urgent

commit 44e18e9eda1f5c318a888989d929188eea93c8dc
Author: Magnus Damm <damm-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
Date:   Fri Jul 3 08:39:34 2009 +0000

    sh-sci: update receive error handling for muxed irqs
   =20
    This patch updates the receive error code for muxed
    interrupts in the sh-sci driver.
   =20
    Receive error interrupts may be generated by the hardware
    if RE or REIE bits in SCSCR are set. Update the muxed
    interrupt handling code to acknowledge error interrupts
    if RE or REIE is set, instead of only acknowledging if
    REIE is set.
   =20
    Without this patch error interrupts may be generated but
    never acked resulting in a "nobody cared" crash.
   =20
    Signed-off-by: Magnus Damm <damm-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit 30d7a77dd5a9720430af72f6f62f5156fe073e55
Author: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jul 2 21:24:14 2009 -0300

    perf_counter tools: Adjust symbols in ET_EXEC files too
   =20
    Ingo Molnar wrote:
   =20
    > i just bisected a 'perf report' bug that would cause us to not
    > resolve all user-space symbols in a 'git gc' run to:
    >
    > f5812a7a336fb952d819e4427b9a2dce02368e82 is first bad commit
    > commit f5812a7a336fb952d819e4427b9a2dce02368e82
    > Author: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    > Date:   Tue Jun 30 11:43:17 2009 -0300
    >
    >     perf_counter tools: Adjust only prelinked symbol's addresses
   =20
    Rename ->prelinked to ->adjust_symbols and making what was done
    only for prelinked libraries also to ET_EXEC binaries, such as
    /usr/bin/git:
   =20
    [acme@doppio pahole]$ readelf -h /usr/bin/git | grep Type
      Type:                              EXEC (Executable file)
    [acme@doppio pahole]$
   =20
    And after installing the 'git-debuginfo' package, I get correct resul=
ts:
   =20
    [acme@doppio linux-2.6-tip]$ perf report --sort comm,dso,symbol -d /u=
sr/bin/git | head -20
   =20
     #
     # (1139614 samples)
     #
     # Overhead           Command  Shared Object              Symbol
     # ........  ................  .........................  ......
     #
        34.98%               git  /usr/bin/git               [.] send_sid=
eband
        33.39%               git  /usr/bin/git               [.] enter_re=
po
         6.81%               git  /usr/bin/git               [.] diff_opt=
_parse
         4.95%               git  /usr/bin/git               [.] is_repos=
itory_shallow
         3.24%               git  /usr/bin/git               [.] odb_mkst=
emp
         1.39%               git  /usr/bin/git               [.] output
         1.34%               git  /usr/bin/git               [.] xmmap
         1.25%               git  /usr/bin/git               [.] receive_=
pack_config
         1.16%               git  /usr/bin/git               [.] git_path=
dup
         0.90%               git  /usr/bin/git               [.] read_obj=
ect_with_reference
         0.86%               git  /usr/bin/git               [.] show_pat=
ch_diff
         0.85%               git  /usr/bin/git               0x0000000009=
5e2e
         0.69%               git  /usr/bin/git               [.] display
    [acme@doppio linux-2.6-tip]$
   =20
    I'll check what are the last cases where we can't resolve symbols, li=
ke
    this 0x00000000095e2e later.
   =20
    And I guess this will fix the problems Mike were seeing too:
   =20
     [acme@doppio linux-2.6-tip]$ readelf -h ../build/perf/vmlinux | grep=
 Type
       Type:                              EXEC (Executable file)
     [acme@doppio linux-2.6-tip]$
   =20
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <new-submission>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 47220f623c3216ca276bad517ed208ea2ffceaa2
Author: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Date:   Fri Jul 3 13:08:28 2009 +0900

    sh: define PERF_COUNTER_INDEX_OFFSET.
   =20
    Fixes up recent build breakage.
   =20
    Signed-off-by: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>

commit b3d254955fb5797232ec329b136c363aa4fdaa05
Author: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jun 24 23:09:15 2009 -0700

    drm/i915: Adjust DisplayPort clocks to use 96MHz reference
   =20
    For some reason, the DP clocks were based off a 100MHz reference inst=
ead of
    the standard 96MHz reference. This caused some DP monitors to fail to=
 lock
    to the signal.
   =20
    Signed-off-by: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 66d9e2102af038bcd3286a6efce83e1877e5997b
Author: Matthias Kaehlcke <matthias-RprLehDfhQ3k1uMJSBkQmQ@public.gmane.org>
Date:   Sun Jun 28 11:19:39 2009 +0100

    [ARM] 5576/1: Update kb9202_defconfig
   =20
    The default configuration file for the KwikByte kb9202 board was base=
d on a 2.6.13-rc2 kernel and doesn't produce a bootable kernel. Update th=
e
    configuration in order to produce a bootable image.
   =20
    Signed-off-by: Matthias Kaehlcke <matthias-RprLehDfhQ3k1uMJSBkQmQ@public.gmane.org>
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit 15da4b1612d608a47e095439b3dd1d77ffe20e0c
Author: Abhishek Kulkarni <adkulkar-r/HDY37nXir2fBVCVOL8/A@public.gmane.org>
Date:   Wed Jul 1 08:50:54 2009 +0000

    net/9p: Fix crash due to bad mount parameters.
   =20
    It is not safe to use match_int without checking the token type retur=
ned
    by match_token (especially when the token type returned is Opt_err an=
d
    args is empty). Fix it.
   =20
    Signed-off-by: Abhishek Kulkarni <adkulkar-r/HDY37nXir2fBVCVOL8/A@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 887b5ea3683ce04966e35fa2e5fe215bedcde73c
Author: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 13:38:26 2009 +0000

    if_ether: add define for 1588 aka Timesync
   =20
    This patch adds ETH_P_1588 protocol ID define.
   =20
    Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 42caa074042e22f873c408a0d13be657b16192f1
Author: Wade Farnsworth <wfarnsworth-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 1 13:00:34 2009 +0000

    phylib: fixes for PHY_RESUMING state changes
   =20
    The PHY_HALTED state disables phydev->link, but the link will not be
    updated upon entering PHY_RESUMING.  Add a call to phy_read_status() =
to
    update the link before entering PHY_RUNNING.  If the link is not up a=
t
    this point, enter the PHY_NOLINK state instead.
   =20
    Also, when transitioning from PHY_RESUMING to PHY_RUNNING, calls to
    netif_carrier_on() and phydev->adjust_link() are missing.  Add the ca=
lls
    similar to the other transitions to PHY_RUNNING.
   =20
    Signed-off-by: Wade Farnsworth <wfarnsworth-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
    Acked-by: Andy Fleming <afleming-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 67c38fc61af930fa03b042932b6b14fbf8126222
Author: Dhananjay Phadke <dhananjay-ke4iAOjMrpvQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 1 11:41:43 2009 +0000

    netxen: avoid frequent firmware reset
   =20
    Restrict firmware reset to following cases -
   =20
    o chip rev is NX2031 (firmare doesn't support heartbit).
    o firmware is dead.
    o previous attempt to init firmware had failed.
    o we have got newer file firmware.
   =20
    This speeds up module load tremendously (by upto 8 sec),
    also avoids downtime for NCSI (management) pass-thru
    traffic.
   =20
    Signed-off-by: Dhananjay Phadke <dhananjay-ke4iAOjMrpvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 98e31bb00983a5b6d638a31e4ff77e5ca1ccf93e
Author: Dhananjay Phadke <dhananjay-ke4iAOjMrpvQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 1 11:41:42 2009 +0000

    netxen: fix the version code macro
   =20
    Correct firmware encoding is 8 bit major, 8 bit minor and
    16 bit subversion. Flash has sizes rightly set, but original
    driver submission messed it leaving 16 bit major and 8 bit
    subversion.
   =20
    Also fix a infinite loop when cut-thru file firmware is
    invalid.
   =20
    Signed-off-by: Dhananjay Phadke <dhananjay-ke4iAOjMrpvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit c56bd0c39ce31e694b6f32223c15bdd582263a3f
Author: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Date:   Wed Jul 1 11:20:57 2009 +0000

    gigaset: drop pointless check
   =20
    Drop a sanity check which doesn't serve any useful purpose anymore.
   =20
    Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit bceb0f126f25184eaec3f3c8f00c92b0d899e5de
Author: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Date:   Wed Jul 1 11:20:57 2009 +0000

    gigaset: accept connection establishment messages in any order
   =20
    ISDN connection setup failed if the "connection active" and
    "B channel up" messages from the device arrived in a different
    order than expected. Modify the state machine to accept them in
    any order.
   =20
    Impact: bugfix
    Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
    CC: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 24b57c6988c5791628c89a8838910991abc9cc1e
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 20:14:35 2009 +0200

    perf_counter tools: Display percents of hits in callchain with overhe=
ad colors
   =20
    This adds the use of colors to signal at a glance the important
    overhead thresholds in callchains hit rates.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246558475-10624-3-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org=
>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 1e11fd82d247e4e48a1d6c49402214434538d3fd
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 20:14:34 2009 +0200

    perf_counter tools: Provide helper to print percents color
   =20
    Among perf annotate, perf report and perf top, we can find the
    common colored printing of percents according to the following
    rules:
   =20
        High overhead =3D  > 5%, colored in red
        Mid overhead =3D  > 0.5%, colored in green
        Low overhead =3D  < 0.5%, default color
   =20
    Factorize these multiple checks in a single function named
    percent_color_fprintf() and also provide a get_percent_color()
    for sites which print percentages and other things at the same
    time.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246558475-10624-2-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org=
>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit c20ab37ef30f4a874cf27e84c12c73e584e6f5cc
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 20:14:33 2009 +0200

    perf_counter tools: Set the minimum percent for callchains to be disp=
layed
   =20
    Callchains output may become a burden on a trace because even
    rarely hit site are exposed. This can be too much information.
   =20
    Let the user set a threshold as a minimum percent of hits using
    the new pattern for the -c option:
   =20
        -c mode,min_percent
   =20
    Example:
   =20
    $ perf report -s sym -c flat,4
   =20
         8.25%  [k] copy_user_generic_string
                 4.19%
                    copy_user_generic_string
                    generic_file_aio_read
                    do_sync_read
                    vfs_read
                    sys_pread64
                    system_call_fastpath
                    pread64
   =20
         5.39%  [k] search_by_key
         4.63%  0x00000000009e0a
         2.36%  [k] memcpy_c
    [...]
   =20
    $ perf report -s sym -c graph,2
   =20
         8.25%  [k] copy_user_generic_string
                    |
                    |--4.31%-- generic_file_aio_read
                    |          do_sync_read
                    |          vfs_read
                    |          |
                    |           --4.19%-- sys_pread64
                    |                     system_call_fastpath
                    |                     pread64
                    |
                     --3.24%-- generic_file_buffered_write
                               __generic_file_aio_write_nolock
                               generic_file_aio_write
                               do_sync_write
                               reiserfs_file_write
                               vfs_write
                               |
                                --3.14%-- sys_pwrite64
                                          system_call_fastpath
                                          __pwrite64
   =20
         5.39%  [k] search_by_key
                    |
                     --2.23%-- reiserfs_update_sd_size
   =20
         4.63%  0x00000000009e0a
   =20
         2.36%  [k] memcpy_c
    [...]
   =20
    You can also omit it and it will default to 0.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246558475-10624-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org=
>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit ebbb16bffa646f853899ef3fdc0ac7abab888703
Author: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date:   Tue Jun 30 20:28:31 2009 +0200

    ieee1394: sbp2: add support for disks >2 TB (and 16 bytes long CDBs)
   =20
    Increase the command ORB data structure to transport up to 16 bytes l=
ong
    CDBs (instead of 12 bytes), and tell the SCSI mid layer about it.  Th=
is
    is notably necessary for READ CAPACITY(16) and friends, i.e. support =
of
    large disks.
   =20
    Signed-off-by: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>

commit af2719415a5ceae06f2a6d33e78b555e64697fc8
Author: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date:   Tue Jun 30 20:27:59 2009 +0200

    firewire: sbp2: add support for disks >2 TB (and 16 bytes long CDBs)
   =20
    Increase the command ORB data structure to transport up to 16 bytes l=
ong
    CDBs (instead of 12 bytes), and tell the SCSI mid layer about it.  Th=
is
    is notably necessary for READ CAPACITY(16) and friends, i.e. support =
of
    large disks.
   =20
    Signed-off-by: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>

commit 4eb3e4788b8a5e220a0aeb590f88c28850726ebe
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:58:21 2009 +0200

    perf report: Add support for callchain graph output
   =20
    Currently, the printing of callchains is done in a single
    vertical level, this is the "flat" mode:
   =20
    8.25%  [k] copy_user_generic_string
                 4.19%
                    copy_user_generic_string
                    generic_file_aio_read
                    do_sync_read
                    vfs_read
                    sys_pread64
                    system_call_fastpath
                    pread64
   =20
    This patch introduces a new "graph" mode which provides a
    hierarchical output of factorized paths recursively sorted:
   =20
     8.25%  [k] copy_user_generic_string
                    |
                    |--4.31%-- generic_file_aio_read
                    |          do_sync_read
                    |          vfs_read
                    |          |
                    |          |--4.19%-- sys_pread64
                    |          |          system_call_fastpath
                    |          |          pread64
                    |          |
                    |           --0.12%-- sys_read
                    |                     system_call_fastpath
                    |                     __read
                    |
                    |--3.24%-- generic_file_buffered_write
                    |          __generic_file_aio_write_nolock
                    |          generic_file_aio_write
                    |          do_sync_write
                    |          reiserfs_file_write
                    |          vfs_write
                    |          |
                    |          |--3.14%-- sys_pwrite64
                    |          |          system_call_fastpath
                    |          |          __pwrite64
                    |          |
                    |           --0.10%-- sys_write
    [...]
   =20
    The command line has then changed.
   =20
    By providing the -c option, the callchain will output in the
    flat mode by default.
   =20
    But you can override it:
   =20
        perf report -c graph
   =20
    or
   =20
        perf report -c flat
   =20
    You can also pass the abreviated mode:
   =20
        perf report -c g
   =20
    or
   =20
        perf report -c gra
   =20
    will both make use of the graph mode.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246550301-8954-3-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 5a4b181721375700124513cdd9f97056e1c66675
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:58:20 2009 +0200

    perf_counter tools: Add new OPT_CALLBACK_DEFAULT option
   =20
    There is no predefined macro to create an option that can have
    a custom value or a default one if none is given.
   =20
    This patch provides a new helper OPT_CALLBACK_DEFAULT() which
    defines such kind of option.
   =20
    For example, considering an option -c, we want to get the
    default value in the following cases:
   =20
        perf command -c -d
        perf command -d -c
   =20
    And the foo value when it's given:
   =20
        perf command -c foo -d
        perf command -d -c foo
   =20
    That's also why PARSE_OPT_LASTARG_DEFAULT is extended here to
    support default values whatever the position of the option, not
    only in the end.
   =20
    Should it now be renamed to PARSE_OPT_ARG_DEFAULT ?
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: git-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
    LKML-Reference: <1246550301-8954-2-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 14f4654cbd531d48651e005cf05907c14bddb193
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Jul 2 17:58:19 2009 +0200

    perf_counter tools: Create new chain_for_each_child() iterator
   =20
    Iterating through children of a node in the callchain tree
    shows something that may be quite confusing at a first glance.
    The head is the children field of the parent and the list nodes
    are in the brothers field of the children.
   =20
    This is because the childs are linked to the parent as a list
    of "brothers" using the "children" list of the parent as a
    head:
   =20
      ---------------
     | Parent (head) |-------------------------------------
      ---------------                                      |
         |                                                 |
      children                                             |
         |                                                 |
      -----------               -----------                |
     | 1st child |---brother---| 2nd child |---brother-----
      -----------               -----------
   =20
    This makes the following strange pattern often occuring:
   =20
     list_for_each_entry(child, &parent->children, brothers) {
            // do something with children
     }
   =20
    Abstract it to chain_for_each_child() to factorize and simplify
    this pattern.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246550301-8954-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 1bc6f83813441d15a74dfa97966fb68fa1bdec76
Author: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>
Date:   Thu Jul 2 18:32:05 2009 +0200

    amd-iommu: set evt_buf_size correctly
   =20
    The setting of this variable got lost during the suspend/resume
    implementation.  But keeping this variable zero causes a divide-by-ze=
ro
    error in the interrupt handler. This patch fixes this.
   =20
    Signed-off-by: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>

commit 4ebfc3dba59fb84b315ebb0059347dc9342a32f1
Author: Linus Walleij <linus.walleij-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Date:   Thu Jul 2 00:27:57 2009 +0100

    [ARM] 5581/1: U300 clock updates
   =20
    This adds a few default locks to the clocks (the clocks were used
    before the locks were initialized by code), then renames the clocks
    a bit to fit with the latest driver names (some changed during
    review). Lastly it moves the initialization of the clock debugfs
    entry to module_init() initcall level since the debugfs isn't up
    in core_initcall().
   =20
    Signed-off-by: Linus Walleij <linus.walleij-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit 9be4b17c4c900f634ab9be3d13e116aa31edb7cb
Author: Linus Walleij <linus.walleij-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Date:   Wed Jul 1 23:41:12 2009 +0100

    [ARM] 5579/1: Updated U300 defconfig
   =20
    This defconfig update selects all the new U300 drivers merged for
    2.6.31-rc1 in the merge window and add defaults for the new
    config options. It compiles and boots nicely from initramfs on
    the U300.
   =20
    Signed-off-by: Linus Walleij <linus.walleij-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
    Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

commit 7a6a3a086fe60bb3b739f66e47dc5bbc8f530d32
Author: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>
Date:   Thu Jul 2 12:23:23 2009 +0200

    amd-iommu: handle alias entries correctly in init code
   =20
    An alias entry in the ACPI table means that the device can send reque=
sts to the
    IOMMU with both device ids, its own and the alias. This is not handle=
d properly
    in the ACPI init code. This patch fixes the issue.
   =20
    Signed-off-by: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>

commit 251e1e44b97852aa5e53e71c4b47e55b2dfd054e
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Thu Jul 2 08:54:01 2009 +0200

    x86: Fix printk call in print_local_apic()
   =20
    Instead of this:
   =20
    [   75.690022] <7>printing local APIC contents on CPU#0/0:
    [   75.704406] ... APIC ID:      00000000 (0)
    [   75.707905] ... APIC VERSION: 00060015
    [   75.722551] ... APIC TASKPRI: 00000000 (00)
    [   75.725473] ... APIC PROCPRI: 00000000
    [   75.728592] ... APIC LDR: 00000001
    [   75.742137] ... APIC SPIV: 000001ff
    [   75.744101] ... APIC ISR field:
    [   75.746648] 0123456789abcdef0123456789abcdef
    [   75.746649] <7>00000000000000000000000000000000
   =20
    Improve the code to be saner and simpler and just print out
    the bitfield in a single line using hexa values - not as a
    (rather pointless) binary bitfield.
   =20
    Partially reused Linus's initial fix for this.
   =20
    Reported-and-Tested-by: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    LKML-Reference: <4A4C43BC.90506-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit e1af3aec3e2e7d21d4b3054323779d478c19d907
Author: Xiao Guangrong <xiaoguangrong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Wed Jul 1 16:50:25 2009 +0800

    tracing: Fix trace_print_seq()
   =20
    We will lose something if trace_seq->buffer[0] is 0, because the copy=
 length
    is calculated by strlen() in seq_puts(), so using seq_write() instead=
 of
    seq_puts().
   =20
    There have a example:
    after reboot:
   =20
     # echo kmemtrace > current_tracer
     # echo 0 > options/kmem_minimalistic
     # cat trace
     # tracer: kmemtrace
     #
     #
   =20
    Nothing is exported, because the first byte of trace_seq->buffer[ ]
    is KMEMTRACE_USER_ALLOC.
   =20
    ( the value of KMEMTRACE_USER_ALLOC is zero, seeing
      kmemtrace_print_alloc_user() in kernel/trace/kmemtrace.c)
   =20
    Signed-off-by: Xiao Guangrong <xiaoguangrong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Acked-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Acked-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
    Acked-by: Eduard - Gabriel Munteanu <eduard.munteanu-5yxVlmDh9pahKNWrAYCRhA@public.gmane.org>
    Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
    LKML-Reference: <4A4B2351.5010300-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 429764873cf3fc3e73142872a674bb27cda589c1
Author: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date:   Thu Jul 2 08:09:46 2009 +0200

    perf_counter tools: Enable kernel module symbol loading in tools
   =20
    Add the -m/--modules option to perf report and perf annotate,
    which enables live module symbol/image loading. To be used
    with -k/--vmlinux.
   =20
    (Also give perf annotate a -P/--full-paths option.)
   =20
    Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246514986.13293.48.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 6cfcc53ed4f3ecb9319e73a03f34f1eddcb644dd
Author: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date:   Thu Jul 2 08:08:36 2009 +0200

    perf_counter tools: Connect module support infrastructure to symbol l=
oading infrastructure
   =20
    Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246514916.13293.46.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 208b4b4a59351011b7f212e273f2b7bc47a9c482
Author: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date:   Thu Jul 2 08:07:10 2009 +0200

    perf_counter tools: Add infrastructure to support loading of kernel m=
odule symbols
   =20
    Add infrastructure for module path discovery and section load address=
es.
   =20
    Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246514830.13293.44.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 9974f496782b7612e36a143bedda858f1cb953d4
Author: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date:   Thu Jul 2 08:05:58 2009 +0200

    perf_counter tools: Make symbol loading consistently return number of=
 loaded symbols
   =20
    perf_counter tools: Make symbol loading consistently return number of=
 loaded symbols.
   =20
    Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246514758.13293.42.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 1ae8c0a56eeb3ed358b78ccadd024d6b721f26bc
Author: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
Date:   Sun Jun 28 15:42:17 2009 -0700

    drm/i915: Make driver less chatty
   =20
    Convert many printk calls to DRM_DEBUG calls to reduce kernel log noi=
se
    for normal activities. Switch other printk calls to DRM_ERROR or DRM_=
INFO.
   =20
    Signed-off-by: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 956dba3caaf66b84fe5f6180e0e4dd03902c7980
Author: Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date:   Wed Jul 1 15:20:59 2009 +0100

    drm/i915: fix up a raw 64bit divide
   =20
    We are seeing compilation failures on i386 in some environments due
    to an undefined reference as below:
   =20
        ERROR: "__udivdi3" [drivers/gpu/drm/i915/i915.ko] undefined!
   =20
    This is generated due to a raw 64 bit divide in the i915 driver.  Fix=
 up
    this raw divide.
   =20
    Signed-off-by: Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
    Acked-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit cc0bad7552308e8905d6ea56e6b7811fa67e716d
Author: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Thu Jun 25 00:56:52 2009 -0400

    cifs: add new cifs_iget function and convert unix codepath to use it
   =20
    cifs: add new cifs_iget function and convert unix codepath to use it
   =20
    In order to unify some codepaths, introduce a common cifs_fattr struc=
t
    for storing inode attributes. The different codepaths (unix, legacy,
    normal, etc...) can fill out this struct with inode info. It can then=
 be
    passed as an arg to a common set of routines to get and update inodes.
   =20
    Add a new cifs_iget function that uses iget5_locked to identify inode=
s.
    This will compare inodes based on the uniqueid value in a cifs_fattr
    struct.
   =20
    Rather than filling out an already-created inode, have
    cifs_get_inode_info_unix instead fill out cifs_fattr and hand that of=
f
    to cifs_iget. cifs_iget can then properly look for hardlinked inodes.
   =20
    On the readdir side, add a new cifs_readdir_lookup function that spaw=
ns
    populated dentries. Redefine FILE_UNIX_INFO so that it's basically a
    FILE_UNIX_BASIC_INFO that has a few fields wrapped around it. This
    allows us to more easily use the same function for filling out the fa=
ttr
    as the non-readdir codepath.
   =20
    With this, we should then have proper hardlink detection and can
    eventually get rid of some nasty CIFS-specific hacks for handing them.
   =20
    Signed-off-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
    Signed-off-by: Steve French <sfrench-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 46b952a3c3a94afa339bd4961a4f3d1482436599
Author: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Date:   Wed Jul 1 14:24:30 2009 -0700

    PCI: Fix IRQ swizzling for ARI-enabled devices
   =20
    For many purposes, including interrupt-swizzling, devices with ARI
    enabled behave as if they have one device (number 0) and 256 function=
s.
    This probably hasn't bitten us in practice because all ARI devices I'=
ve
    seen are also IOV devices, and IOV devices are required to use MSI.
    This isn't guaranteed, and there are legitimate reasons to use ARI
    without IOV, and hence potentially use pin-based interrupts.
   =20
    Signed-off-by: Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit a92bef0f216bbf3d05c0c0709ea02e267f2b920e
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 21:02:10 2009 +0200

    perf stat: Handle pipe read failures in perf stat
   =20
    Building builtin-stat.c reports the following errors:
   =20
    cc1: warnings being treated as errors
    builtin-stat.c: In function =E2=80=98run_perf_stat=E2=80=99:
    builtin-stat.c:242: erreur: ignoring return value of =E2=80=98read=E2=
=80=99, declared with attribute warn_unused_result
    builtin-stat.c:255: erreur: ignoring return value of =E2=80=98read=E2=
=80=99, declared with attribute warn_unused_result
    make: *** [builtin-stat.o] Erreur 1
   =20
    This patch handles the possible pipe read failures.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246474930-6088-2-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 0406ca6d8e849d9dd027c8cb6791448e81411aef
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 21:02:09 2009 +0200

    perf_counter: Ignore the nmi call frames in the x86-64 backtraces
   =20
    About every callchains recorded with perf record are filled up
    including the internal perfcounter nmi frame:
   =20
     perf_callchain
     perf_counter_overflow
     intel_pmu_handle_irq
     perf_counter_nmi_handler
     notifier_call_chain
     atomic_notifier_call_chain
     notify_die
     do_nmi
     nmi
   =20
    We want ignore this frame as it's not interesting for
    instrumentation. To solve this, we simply ignore every frames
    from nmi context.
   =20
    New example of "perf report -s sym -c" after this patch:
   =20
    9.59%  [k] search_by_key
                 4.88%
                    search_by_key
                    reiserfs_read_locked_inode
                    reiserfs_iget
                    reiserfs_lookup
                    do_lookup
                    __link_path_walk
                    path_walk
                    do_path_lookup
                    user_path_at
                    vfs_fstatat
                    vfs_lstat
                    sys_newlstat
                    system_call_fastpath
                    __lxstat
                    0x406fb1
   =20
                 3.19%
                    search_by_key
                    search_by_entry_key
                    reiserfs_find_entry
                    reiserfs_lookup
                    do_lookup
                    __link_path_walk
                    path_walk
                    do_path_lookup
                    user_path_at
                    vfs_fstatat
                    vfs_lstat
                    sys_newlstat
                    system_call_fastpath
                    __lxstat
                    0x406fb1
    [...]
   =20
    For now this patch only solves the problem in x86-64.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246474930-6088-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 5da50258584469ddfee6545feb4eb2252a8d7e7b
Author: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 1 14:46:08 2009 -0300

    perf_counter tools: Share list.h with the kernel
   =20
    The copy we were using came from another copy I did for the dwarves
    (pahole) package, that came from the kernel years ago.
   =20
    The only function that is used by the perf tools and that isn't in th=
e
    kernel is list_del_range, that I'm leaving in the perf tools only for
    now.
   =20
    Signed-off-by: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    LKML-Reference: <20090701174608.GA5823-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 43cbcd8acb4c992cbd22d1ec8a08c0591be5d719
Author: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jul 1 12:28:37 2009 -0300

    perf_counter tools: Share rbtree.with the kernel
   =20
    The tools/perf/util/rbtree.c copy already drifted by three
    csets:
   =20
     4b324126e0c6c3a5080ca3ec0981e8766ed6f1ee
     4c60117811171d867d4f27f17ea07d7419d45dae
     16c047add3ceaf0ab882e3e094d1ec904d02312d
   =20
    So remove the copy and use the lib/rbtree.c directly, sharing
    the source code while still generating a separate object file,
    since tools/perf uses a far more agressive -O6 switch.
   =20
    Signed-off-by: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <20090701152837.GG15682-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 12682a971160959072c4970da9b7778709f60bc9
Author: ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Tue Jun 30 11:35:35 2009 +0800

    drm/i915: enable sdvo lvds scaling function.
   =20
    Currently we implemented basic sdvo lvds function,
    But except for sdvo lvds fixed mode, we can not switch
    to other modes, otherwise display get black. The patch
    handle three operations to enable sdvo lvds. At first
    duplicate sdvo fixed mode for adjustment, then according
    to fixed mode line valid all modes, at last adjust input
    mode to fit our requirement.
   =20
    Acked by Li Peng <peng.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Ma Ling <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Ian Romanick <idr-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 6ff4fd05676bc5b5c930bef25901e489f7843660
Author: ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu Jun 25 10:59:22 2009 +0800

    drm/i915: Set SSC frequency for 8xx chips correctly
   =20
    All 8xx class chips have the 66/48 split, not just 855.
   =20
    Signed-off-by: Ma Ling <ling.ma-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 7662c8bd6545c12ac7b2b39e4554c3ba34789c50
Author: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jun 26 11:23:55 2009 +0800

    drm/i915: add FIFO watermark support
   =20
    This patch from jbarnes and myself adds FIFO watermark control to the
    driver.  This is needed for both power saving features on new platfor=
ms
    with the so-called "big FIFO" and for controlling FIFO allocation
    between pipes in multi-head configurations.
   =20
    It's also necessary infrastructure to support things like framebuffer
    compression and configuration supportability checks (i.e. checking a
    configuration against available bandwidth).
   =20
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    Signed-off-by: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 63eeaf38251183ec2b1caee11e4a2c040cb5ce6c
Author: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Date:   Thu Jun 18 16:56:52 2009 -0700

    drm/i915: enable error detection & state collection
   =20
    This patch enables error detection by enabling several types of error
    interrupts.  When an error interrupt is received, the interrupt
    handler captures the error state; hopefully resulting in an accurate
    set of error data (error type, active head pointer, etc.).  The new
    record is then available from sysfs.  The current code will also dump
    the error state to the system log.
   =20
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
    Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>

commit 76c06927f2a78143763dcff9b4c362d15eb29cc2
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 1 19:54:23 2009 +0530

    x86: Declare check_efer() before it gets used
   =20
    This sparse warning:
   =20
      arch/x86/mm/init.c:83:16: warning: symbol 'check_efer' was not decl=
ared. Should it be static?
   =20
    triggers because check_efer() is not decalared before using it.
    asm/proto.h includes the declaration of check_efer(), so
    including asm/proto.h to fix that - this also addresses the
    sparse warning.
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    LKML-Reference: <1246458263.6940.22.camel-b91qqBXZ9ZExq86mLogaLw@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit b25ae679f613ed04aaf6ccbfdb9122fce668e4bb
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 1 19:53:14 2009 +0530

    x86: Mark device_nb as static and fix NULL noise
   =20
    This sparse warning:
   =20
      arch/x86/kernel/amd_iommu.c:1195:23: warning: symbol 'device_nb' wa=
s not declared. Should it be static?
   =20
    triggers because device_nb is global but is only used in a
    single .c file. change device_nb to static to fix that - this
    also addresses the sparse warning.
   =20
    This sparse warning:
   =20
      arch/x86/kernel/amd_iommu.c:1766:10: warning: Using plain integer a=
s NULL pointer
   =20
    triggers because plain integer 0 is used in place of a NULL
    pointer. change 0 to NULL to fix that - this also address the
    sparse warning.
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>
    LKML-Reference: <1246458194.6940.20.camel-b91qqBXZ9ZExq86mLogaLw@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 73c24cb86c51ff6445b292d9914d31236204393b
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 1 18:36:18 2009 +0530

    perf list: Add cache events
   =20
    After:
   =20
    $ ./perf list
   =20
    List of pre-defined events (to be used in -e):
   =20
      cpu-cycles OR cycles                     [Hardware event]
      instructions                             [Hardware event]
      cache-references                         [Hardware event]
      cache-misses                             [Hardware event]
      branch-instructions OR branches          [Hardware event]
      branch-misses                            [Hardware event]
      bus-cycles                               [Hardware event]
   =20
      cpu-clock                                [Software event]
      task-clock                               [Software event]
      page-faults OR faults                    [Software event]
      minor-faults                             [Software event]
      major-faults                             [Software event]
      context-switches OR cs                   [Software event]
      cpu-migrations OR migrations             [Software event]
   =20
      L1-d$-loads                              [Hardware cache event]
      L1-d$-load-misses                        [Hardware cache event]
      L1-d$-stores                             [Hardware cache event]
      L1-d$-store-misses                       [Hardware cache event]
      L1-d$-prefetches                         [Hardware cache event]
      L1-d$-prefetch-misses                    [Hardware cache event]
      L1-i$-loads                              [Hardware cache event]
      L1-i$-load-misses                        [Hardware cache event]
      L1-i$-prefetches                         [Hardware cache event]
      L1-i$-prefetch-misses                    [Hardware cache event]
      LLC-loads                                [Hardware cache event]
      LLC-load-misses                          [Hardware cache event]
      LLC-stores                               [Hardware cache event]
      LLC-store-misses                         [Hardware cache event]
      LLC-prefetches                           [Hardware cache event]
      LLC-prefetch-misses                      [Hardware cache event]
      dTLB-loads                               [Hardware cache event]
      dTLB-load-misses                         [Hardware cache event]
      dTLB-stores                              [Hardware cache event]
      dTLB-store-misses                        [Hardware cache event]
      dTLB-prefetches                          [Hardware cache event]
      dTLB-prefetch-misses                     [Hardware cache event]
      iTLB-loads                               [Hardware cache event]
      iTLB-load-misses                         [Hardware cache event]
      branch-loads                             [Hardware cache event]
      branch-load-misses                       [Hardware cache event]
   =20
      rNNN                                     [raw hardware event descri=
ptor]
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <1246453578.3072.1.camel-6Ww87KsxWewAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 44973998a111dfda09b952aa0f27cad326a97793
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 1 17:49:38 2009 +0530

    x86: Remove double declaration of MSR_P6_EVNTSEL0 and MSR_P6_EVNTSEL1
   =20
    MSR_P6_EVNTSEL0 and MSR_P6_EVNTSEL1 is already declared in msr-index.=
h.
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <1246450778.6940.8.camel-b91qqBXZ9ZExq86mLogaLw@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit b9ebdcc0ce1c676ebf5dc4f6df6b440d8fcf88ab
Author: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jul 1 15:05:09 2009 +0530

    perf stat: Define MATCH_EVENT for easy attr checking
   =20
    MATCH_EVENT is useful:
   =20
     1. for multiple attrs checking
     2. avoid repetition of PERF_TYPE_ and PERF_COUNT_ and save space
     3. avoids line breakage
   =20
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    LKML-Reference: <1246440909.3403.5.camel-b91qqBXZ9ZExq86mLogaLw@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit f37a291c527c954df4da568de718ebb36b8261c0
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Wed Jul 1 12:37:06 2009 +0200

    perf_counter tools: Add more warnings and fix/annotate them
   =20
    Enable -Wextra. This found a few real bugs plus a number
    of signed/unsigned type mismatches/uncleanlinesses. It
    also required a few annotations
   =20
    All things considered it was still worth it so lets try with
    this enabled for now.
   =20
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <new-submission>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit a70c352a37671fe1ebcbd317b439aa4760f4ccb7
Author: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Date:   Wed Jul 1 11:51:18 2009 +0300

    xen: Use kcalloc() in xen_init_IRQ()
   =20
    The init_IRQ() function is now called with slab allocator initialized.
    Therefore, we must not use the bootmem allocator in xen_init_IRQ().
   =20
    Fixes the following boot-time warning:
   =20
      ------------[ cut here ]------------
      WARNING: at mm/bootmem.c:535 alloc_arch_preferred_bootmem+0x27/0x45=
()
      Modules linked in:
      Pid: 0, comm: swapper Not tainted 2.6.30 #1
      Call Trace:
       [<ffffffff8102d6e3>] ? warn_slowpath_common+0x73/0xb0
       [<ffffffff810210d9>] ? pvclock_clocksource_read+0x49/0x90
       [<ffffffff812e522f>] ? alloc_arch_preferred_bootmem+0x27/0x45
       [<ffffffff812e5761>] ? ___alloc_bootmem_nopanic+0x39/0xc9
       [<ffffffff812e57fa>] ? ___alloc_bootmem+0x9/0x2f
       [<ffffffff812e9e21>] ? xen_init_IRQ+0x25/0x61
       [<ffffffff812d69ee>] ? start_kernel+0x1b5/0x29e
      ---[ end trace 4eaa2a86a8e2da22 ]---
   =20
    Acked-by: Jeremy Fitzhardinge <jeremy.fitzhardinge-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
    Tested-by: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
    Reported-by: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
    Signed-off-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
    Cc: lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org
    Cc: jeremy.fitzhardinge-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org
    LKML-Reference: <1246438278.22417.28.camel@penberg-laptop>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 88a69dfbc6ab1e3b51bba8c9103055e21089ebb9
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Wed Jul 1 11:17:20 2009 +0200

    perf report: Fix HV bit mismerge
   =20
    Fix:
   =20
     builtin-report.c: In function =E2=80=98hist_entry__add=E2=80=99:
     builtin-report.c:1015: error: case label not within a switch stateme=
nt
     builtin-report.c:1017: error: break statement not within loop or swi=
tch
   =20
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <new-submission>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 4a2bb6fcc80e6330ca2f2393e98605052cc7780b
Author: Masami Hiramatsu <mhiramat-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jun 30 17:08:09 2009 -0400

    kprobes: No need to unlock kprobe_insn_mutex
   =20
    Remove needless kprobe_insn_mutex unlocking during safety check
    in garbage collection, because if someone releases a dirty slot
    during safety check (which ensures other cpus doesn't execute
    all dirty slots), the safety check must be fail. So, we need to
    hold the mutex while checking safety.
   =20
    Signed-off-by: Masami Hiramatsu <mhiramat-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Ananth N Mavinakayanahalli <ananth-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
    Cc: Jim Keniston <jkenisto-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Ananth N Mavinakayanahalli <ananth-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <20090630210809.17851.28781.stgit-bi+AKbBUZKY6gyzm1THtWbh0DlRQRlKF@public.gmane.org=
in>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 61c45981ddbd718136d49464f00d2f11938aaa6e
Author: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 13:04:34 2009 +1000

    perf_counter tools: Rework event string parsing/syntax
   =20
    This reworks the parser for event descriptors to make it more
    consistent in what it accepts.  It is now structured as a
    recursive descent parser for the following grammar:
   =20
    events		::=3D event ( ("," | space) space* event )*
    event		::=3D ( raw_event | numeric_event | symbolic_event |
    		      generic_hw_event ) [ event_modifier ]
    raw_event	::=3D "r" hex_number
    numeric_event	::=3D number ":" number
    number		::=3D decimal_number | "0x" hex_number | "0" octal_number
    symbolic_event	::=3D string_from_event_symbols_array
    generic_hw_event::=3D cache_type ( "-" ( cache_op | cache_result ) )*
    event_modifier	::=3D ":" ( "u" | "k" | "h" )+
   =20
    with the extra restriction that you can have at most one
    cache_op and at most one cache_result.
   =20
    We pass the current string pointer by reference (i.e. as a
    const char **) to the various parsing functions so that they
    can advance the pointer to indicate how much they consumed.
    They return 0 if they didn't recognize the thing at the pointer
    or 1 if they did (and advance the pointer past it).
   =20
    This also fixes parse_aliases to take the longest matching
    alias from the table, not the first one.  Otherwise "l1-data"
    would match the "l1-d" alias and the "ata" would not be
    consumed.
   =20
    This allows event modifiers indicating what processor modes to
    count in to be applied to any event, not just numeric events,
    and adds a ":h" modifier to indicate counting in hypervisor
    mode.  Specifying ":u" now sets both exclude_kernel and
    exclude_hv, and so on.  Multiple modes can be specified, e.g.
    ":uk" will count in user or hypervisor mode (i.e. only
    exclude_kernel will be set).
   =20
    Signed-off-by: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <19018.53826.843815.189847-UYQwCShxghk5kJ7NmlRacFaTQe2KTcn/@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 0a456fc58fb8ef3c53d18297ab5cd5d2a70d146b
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 13:07:01 2009 +1000

    powerpc/perf_counter: Enable alternate PR/HV bits for POWER7
   =20
    POWER7 has the same PR/HV bit layout as POWER6, so set the flag.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Acked-by: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org
    LKML-Reference: <20090701030701.GI3563@kryten>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit deac911cbdcb124fa0cee47c588e0cb0400b23b7
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 05:35:15 2009 +0200

    perf_counter tools: Various fixes for callchains
   =20
    The symbol resolving has of course revealed some bugs in the
    callchain tree handling. This patch fixes some of them,
    including:
   =20
    - inherit the children from the parents while splitting a node
    - fix list range moving
    - fix indexes setting in callchains
    - create a child on the current node if the path doesn't match in
      the existent children (was only done on the root)
    - compare using symbols when possible so that we can match a function
      using any ip inside by referring to its start address.
   =20
    The practical effects are:
   =20
    - remove double callchains
    - fix upside down or any random order of callchains
    - fix wrong paths
    - fix bad hits and percentage accounts
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246419315-9968-4-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 4424961ad6621a02c6b4c9093e801002c1bb9f65
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 05:35:14 2009 +0200

    perf_counter tools: Resolve symbols in callchains
   =20
    This patch resolves the names, when possible, of each ip
    present in the callchains while using the -c option with perf
    report.
   =20
    Example:
   =20
    5.40%  [k] __d_lookup
                 5.37%
                    perf_callchain
                    perf_counter_overflow
                    intel_pmu_handle_irq
                    perf_counter_nmi_handler
                    notifier_call_chain
                    atomic_notifier_call_chain
                    notify_die
                    do_nmi
                    nmi
                    do_lookup
                    __link_path_walk
                    path_walk
                    do_path_lookup
                    user_path_at
                    sys_faccessat
                    sys_access
                    system_call_fastpath
                    0x7fb609846f77
   =20
                 0.01%
                    perf_callchain
                    perf_counter_overflow
                    intel_pmu_handle_irq
                    perf_counter_nmi_handler
                    notifier_call_chain
                    atomic_notifier_call_chain
                    notify_die
                    do_nmi
                    nmi
                    do_lookup
                    __link_path_walk
                    path_walk
                    do_path_lookup
                    user_path_at
                    sys_faccessat
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246419315-9968-3-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 9198aa77b69647d1d91207f8075763abe7dc0bf4
Author: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Wed Jul 1 05:35:13 2009 +0200

    perf_counter tools: Fix storage size allocation of callchain list
   =20
    Fix a confusion while giving the size of a callchain list
    during its allocation. We are using the wrong structure size.
   =20
    Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    LKML-Reference: <1246419315-9968-2-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 087021ba41e9481202103d51d3dd0c4706899a2b
Merge: fb9c818873a788c5c01c9868cc6050df96e2c7df e83c2b0ff325f52dda1aff357=
2d0e1516216c54b
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Wed Jul 1 09:56:10 2009 +0200

    Merge branch 'linus' into perfcounters/urgent
   =20
    Merge reason: this branch was on a .30-ish base before, update
                  it to an almost-.31-rc2 upstream base to pick up fixes.
   =20
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 944c54e7fc5ccf961bef2b5449958436b85de459
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Wed Jul 1 00:10:16 2009 +0200

    ia64/PCI: adjust section annotation for pcibios_setup()
   =20
    Should be __init.
   =20
    Acked-by: Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit fb9c818873a788c5c01c9868cc6050df96e2c7df
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 09:00:49 2009 +1000

    perf report: Add hypervisor dso
   =20
    Add a dso for hypervisor samples. We don't get any symbol
    information on the ppc64 hypervisor but this at least gives
    us a high level summary of the time spent in there.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
    LKML-Reference: <20090630230141.182536873-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit d8db1b57d31a6b30ea2f0df318eab50fc92b38d6
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 09:00:48 2009 +1000

    perf report: Fix reporting of hypervisor
   =20
    PERF_EVENT_MISC_* is not a bitmask, so we have to mask and compare.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
    LKML-Reference: <20090630230141.088394681-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 3a3393ef75a14ae259a82f3f38624efa17884168
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 09:00:47 2009 +1000

    perf top: Add ppc64 specific skip symbols and strip ppc64 . prefix
   =20
    Filter out some ppc64 specific idle loop functions and remove
    leading '.' on ppc64 text symbols.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
    LKML-Reference: <20090630230140.995643441-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 2ab52083ffc057014e502cf3473adc41436922fa
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 09:00:46 2009 +1000

    perf top: Move skip symbols to an array
   =20
    Move the list of symbols we skip into an array, making it
    easier to add new ones.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
    LKML-Reference: <20090630230140.904782938-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 6717534ddc328ae5cdf89f1ef802db83fc451f19
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 09:00:45 2009 +1000

    perf_counter tools: Remove zlib dependency
   =20
    The zlib devel libraries may not be installed and since we aren't
    using zlib we may as well remove it.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
    LKML-Reference: <20090630230140.802078956-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 1f208ea67821703fd4de056ea6f0baa81f4ad4a5
Author: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date:   Wed Jul 1 09:00:44 2009 +1000

    perf report: Fix -z option
   =20
    Fix a copy and paste error, -z was setting the group option.
   =20
    Signed-off-by: Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
    Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
    LKML-Reference: <20090630230140.714204656-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 789d03f584484af85dbdc64935270c8e45f36ef7
Author: Jan Beulich <JBeulich-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Date:   Tue Jun 30 11:52:23 2009 +0100

    x86: Fix fixmap ordering
   =20
    The merge of the 32- and 64-bit fixmap headers made a latent
    bug on x86-64 a real one: with the right config settings
    it is possible for FIX_OHCI1394_BASE to overlap the FIX_BTMAP_*
    range.
   =20
    Signed-off-by: Jan Beulich <jbeulich-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
    Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> # for 2.6.30.x
    LKML-Reference: <4A4A0A8702000078000082E8-Qfbpwmsw6RoS3W1tAdPHOtBPR1lH4CV8@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 9e314996e3dc5189b9b36dce67088e882e989897
Author: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Date:   Tue Jun 30 15:00:20 2009 +0200

    x86: Fix symbol annotation for arch/x86/lib/clear_page_64.S::clear_pa=
ge_c
   =20
    Noticed the zero-sized function symbol while looking at 'perf' profil=
es,
    it causes the profiler to display those addresses in hexa.
   =20
    Turns out that this was wrong/bogus for an eternity.
   =20
    Signed-off-by: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
    Acked-by: Alexander van Heukelum <heukelum-97jfqw80gc6171pxa8y+qA@public.gmane.org>
    Acked-by: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <1246366820.6538.1.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 626fdfec1588ac1341a37805809d03a719d977e0
Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jun 24 20:00:12 2009 -0700

    x86/PCI: get root CRS before scanning children
   =20
    This allows us to remove adjust_transparent_bridge_resources and give
    x86_pci_root_bus_res_quirks a chance when _CRS is not used or not the=
re.
   =20
    Acked-by: Gary Hade <garyhade-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Tested-by: Gary Hade <garyhade-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 2cdb3f1d834aab27a927be7555fbf4f9e43e9261
Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jun 24 19:01:19 2009 -0700

    x86/PCI: fix boundary checking when using root CRS
   =20
    Don't touch info->res_num if we are out of space.
   =20
    Acked-by: Gary Hade <garyhade-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Tested-by: Gary Hade <garyhade-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 12abb8ba8444f7c9b355bbdd44a6d0839f7a41b6
Author: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Date:   Wed Jun 24 12:08:09 2009 +0900

    PCI MSI: Fix restoration of MSI/MSI-X mask states in suspend/resume
   =20
    There are 2 problems on mask states in suspend/resume.
   =20
    [1]:
    It is better to restore the mask states of MSI/MSI-X to initial state=
s
    (MSI is unmasked, MSI-X is masked) when we release the device.
    The pci_msi_shutdown() does the restoration of mask states for MSI,
    while the msi_free_irqs() does it for MSI-X.  In other words, in the
    "disable" path both of MSI and MSI-X are handled, but in the "shutdow=
n"
    path only MSI is handled.
   =20
    MSI:
       pci_disable_msi()
          =3D> pci_msi_shutdown()
             [ mask states for MSI restored ]
             =3D> msi_set_enable(dev, pos, 0);
          =3D> msi_free_irqs()
   =20
    MSI-X:
       pci_disable_msix()
          =3D> pci_msix_shutdown()
             =3D> msix_set_enable(dev, 0);
          =3D> msix_free_all_irqs
             =3D> msi_free_irqs()
                [ mask states for MSI-X restored ]
   =20
    This patch moves the masking for MSI-X from msi_free_irqs() to
    pci_msix_shutdown().
   =20
    This change has some positive side effects:
     - It prevents OS from touching mask states before reading preserved
       bits in the register, which can be happen if msi_free_irqs() is
       called from error path in msix_capability_init().
     - It also prevents touching the register after turning off MSI-X in
       "disable" path, which can be a problem on some devices.
   =20
    [2]:
    We have cache of the mask state in msi_desc, which is automatically
    updated when msi/msix_mask_irq() is called.  This cached states are
    used for the resume.
   =20
    But since what need to be restored in the resume is the states before
    the shutdown on the suspend, calling msi/msix_mask_irq() from
    pci_msi/msix_shutdown() is not appropriate.
   =20
    This patch introduces __msi/msix_mask_irq() that do mask as same
    as msi/msix_mask_irq() but does not update cached state, for use
    in pci_msi/msix_shutdown().
   =20
    [updated: get rid of msi/msix_mask_irq_nocache() (proposed by Matthew=
 Wilcox)]
   =20
    Reviewed-by: Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 7ba1930db02fc3118165338ef4e562869f575583
Author: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Date:   Tue Jun 23 17:39:27 2009 +0900

    PCI MSI: Unmask MSI if setup failed
   =20
    The initial state of mask register of MSI is unmasked.  We set it
    masked before calling arch_setup_msi_irqs().  If arch_setup_msi_irq()
    fails, it is better to restore the state of the mask register.
   =20
    Reviewed-by: Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 2c21fd4b333e4c780a46edcd6d1e85bfc6cdf371
Author: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Date:   Tue Jun 23 17:40:04 2009 +0900

    PCI MSI: shorten PCI_MSIX_ENTRY_* symbol names
   =20
    These names are too long!  Drop _OFFSET to save some bytes/lines.
   =20
    Reviewed-by: Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 2fc90f6133a87da8177636866557d4cc5f56e661
Author: Alexey Zaytsev <zaytsev-GA1wtrUrUs+HXe+LvDLADg@public.gmane.org>
Date:   Wed Jun 24 16:22:30 2009 +0400

    PCI: make pci_name() take const argument
   =20
    Since this function should never modify it (saves warnings when calle=
d with
    const args too).
   =20
    Signed-off-by: Alexey Zaytsev <zaytsev-GA1wtrUrUs+HXe+LvDLADg@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 7a661c6f1082693a7e9627e9ad2d1546a9337fdc
Author: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date:   Wed Jun 24 16:02:27 2009 +0100

    PCI: More PATA quirks for not entering D3
   =20
    The ALi loses some state if it goes into D3. Unfortunately even with =
the
    chipset documents I can't figure out how to restore some bits of it.
   =20
    The VIA one saves/restores apparently fine but the ACPI _GTM methods =
break
    on some platforms if we do this and this causes cable misdetections.
   =20
    These are both effectively regressions as historically nothing matche=
d the
    devices and then decided not to bind to them. Nowdays something is bi=
nding
    to all sorts of devices and a result they get dumped into D3.
   =20
    Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Acked-by: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 503998ca4a295f7da233689850ba4b9d13cf41e7
Author: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date:   Wed Jun 24 09:18:14 2009 -0700

    PCI: fix kernel-doc warnings
   =20
    Add documentation for missing parameters in PCI hotplug code.
   =20
    Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 654b75e044119bf8e7d773bce41ea039281bbfbe
Author: Yu Zhao <yu.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Fri Jun 26 14:04:46 2009 +0800

    PCI: check if bus has a proper bridge device before triggering SBR
   =20
    For devices attached to the root bus, we can't trigger Secondary Bus
    Reset because there is no bridge device associated with the bus. So
    need to check bus->self again NULL first before using it.
   =20
    Reviewed-by: Kenji Kaneshige <kaneshige.kenji-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Yu Zhao <yu.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 977badb2f385db14d8ba3fcf02fbd7ead8e63d0f
Author: Fernando Luis V=C3=A1zquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Date:   Fri Jun 26 11:27:41 2009 +0900

    PCI: remove pci_dac_dma_... APIs on mn10300
   =20
    It seems that mn10300 made it upstream after Jan Beulich's pci_dac_dm=
a_*
    cleanup work and still defines pci_dac_dma_supported(). This API is n=
ot
    required by the PCI subsystem anymore, so remove it.
   =20
    Acked-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Fernando Luis Vazquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 50e5628a4ac465a52f0d4ca6567343be029731a0
Author: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date:   Sun Jun 28 09:26:40 2009 -0700

    PCI ECRC: Remove unnecessary semicolons
   =20
    Acked-by: Andrew Patterson <andrew.patterson-VXdhtT5mjnY@public.gmane.org>
    Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 0d07348931daef854aca8c834a89f1a99ba4ff2b
Author: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Date:   Wed Jun 24 12:08:27 2009 +0900

    PCI MSI: Return if alloc_msi_entry for MSI-X failed
   =20
    In current code it continues setup even if alloc_msi_entry() for MSI-=
X
    is failed due to lack of memory.  It means arch_setup_msi_irqs() migh=
t
    be called with msi_desc entries less than its argument nvec.
   =20
    At least x86's arch_setup_msi_irqs() uses list_for_each_entry() for
    dev->msi_list that suspected to have entries same numbers as nvec, an=
d
    it doesn't check the number of allocated vectors and passed arg nvec.
    Therefore it will result in success of pci_enable_msix(), with less
    vectors allocated than requested.
   =20
    This patch fixes the error route to return -ENOMEM, instead of contin=
uing
    the setup (proposed by Matthew Wilcox).
   =20
    Note that there is no iounmap in msi_free_irqs() if no msi_disc is
    allocated.
   =20
    Reviewed-by: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
    Signed-off-by: Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>

commit 238a24f626628cb16a3015f332d649f08246ca89
Author: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Mon Jun 29 15:55:10 2009 +0800

    tracing/fastboot: Document the need of initcall_debug
   =20
    To use boot tracer, one should pass initcall_debug as well as
    ftrace=3Dinitcall to the command line.
   =20
    Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
    LKML-Reference: <4A48735E.9050002-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit bab7614d6d1b1fc96ec6c5a7ca34c8641060e659
Author: Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 00:20:52 2009 -0700

    Input: add support for generic GPIO-based matrix keypad
   =20
    Original patch by Marek Vasut, modified by Eric in:
   =20
    1. use delayed work to simplify the debouncing
    2. combine col_polarity/row_polarity into a single active_low field
    3. use a generic bit array based XOR algorithm to detect key
       press/release, which should make the column assertion time
       shorter and code a bit cleaner
    4. remove the ALT_FN handling, which is no way generic, the ALT_FN
       key should be treated as no different from other keys, and
       translation will be done by user space by commands like 'loadkeys'.
    5. explicitly disable row IRQs and flush potential pending work,
       and schedule an immediate scan after resuming as suggested
       by Uli Luckas
    6. incorporate review comments from many others
   =20
    Patch tested on Littleton/PXA310 (though PXA310 has a dedicate keypad
    controller, I have to configure those pins as generic GPIO to use thi=
s
    driver, works quite well, though), and Sharp Zaurus model SL-C7x0
    and SL-C1000.
   =20
    [dtor-JGs/UdohzUI@public.gmane.org: fix error unwinding path, support changing keymap
     from userspace]
    Signed-off-by: Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Trilok Soni <soni.trilok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Uli Luckas <u.luckas-vFjI0mZ6VZs@public.gmane.org>
    Reviewed-by: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
    Reviewed-by: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
    Signed-off-by: Eric Miao <eric.miao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit cb589529f74d69abc111887b45308f333f950ade
Author: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Jun 29 00:00:52 2009 -0700

    Input: arrange keyboards alphabetically
   =20
    Hopefully it will reduce conflicts when merging patches.
   =20
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit da0d03fe6cecde837f113a8a587f5a872d0fade0
Author: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 22:38:56 2009 -0700

    Input: gpio-keys - avoid possibility of sleeping in timer function
   =20
    The gpio_get_value function may sleep, so it should not be called in =
a
    timer function. Move gpio_get_value calls to workqueue.
   =20
    Signed-off-by: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit ca865a77b5949f5c403e0f13de5a5a9cd499a11e
Author: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 22:38:44 2009 -0700

    Input: gpio-keys - revert 'change timer to workqueue'
   =20
    This reverts commit 0b346838c5862bfe911432956a106d602535d030.
   =20
    This commit breaks GPIO debouncing by replacing the original mod_time=
r
    with schedule_delayed_work in the interrupt handler. The latter does =
not
    kick the timer further on GPIO line changes as it should to perform
    debouncing.
   =20
    Signed-off-by: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit 00b8ac409cad653137f087e3ff69c020174cbc15
Author: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date:   Sun Jun 28 22:30:56 2009 -0700

    Input: dm355evm_keys - fix kconfig symbol names
   =20
    The keypad driver for the DM355 EVM got slightly broken as it merged,
    since it moved from input/keyboard to input/misc and its Kconfig
    symbol changed.  This patch copes with the changed Kconfig symbol.
   =20
    Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit c413ec446188ae53276eb60a60311b430448c6b0
Author: Ping Cheng <pingc-JeGq9vS6aD4AvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 22:50:58 2009 -0700

    Input: wacom - add DTF720a support and fix rotation on Intuos3
   =20
    This patch adds DTF720a support and fixes an Intuos3 rotation
    pen out-proximity bug.
   =20
    Signed-off-by: Ping Cheng <pingc-JeGq9vS6aD4AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit 9230ccb1071d2d7e4ecb6314e67203b9f7f08140
Author: Yan Li <yan.i.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Sun Jun 28 22:30:56 2009 -0700

    Input: i8042 - more reset quirks for MSI Wind-clone netbooks
   =20
    When testing Moblin on various netbooks, we've got reports that
    many MSI Wind clones need the i8042 reset quirks for the keyboard
    and/or touchpad's proper function.
   =20
    Signed-off-by: Yan Li <yan.i.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Dmitry Torokhov <dtor-JGs/UdohzUI@public.gmane.org>

commit ec5a36f94e7ca4b1f28ae4dd135cd415a704e772
Author: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Date:   Mon Jun 29 09:57:10 2009 +0300

    SLAB: Fix lockdep annotations
   =20
    Commit 8429db5... ("slab: setup cpu caches later on when interrupts a=
re
    enabled") broke mm/slab.c lockdep annotations:
   =20
      [   11.554715] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
      [   11.555249] [ INFO: possible recursive locking detected ]
      [   11.555560] 2.6.31-rc1 #896
      [   11.555861] ---------------------------------------------
      [   11.556127] udevd/1899 is trying to acquire lock:
      [   11.556436]  (&nc->lock){-.-...}, at: [<ffffffff810c337f>] kmem_=
cache_free+0xcd/0x25b
      [   11.557101]
      [   11.557102] but task is already holding lock:
      [   11.557706]  (&nc->lock){-.-...}, at: [<ffffffff810c3cd0>] kfree=
+0x137/0x292
      [   11.558109]
      [   11.558109] other info that might help us debug this:
      [   11.558720] 2 locks held by udevd/1899:
      [   11.558983]  #0:  (&nc->lock){-.-...}, at: [<ffffffff810c3cd0>] =
kfree+0x137/0x292
      [   11.559734]  #1:  (&parent->list_lock){-.-...}, at: [<ffffffff81=
0c36c7>] __drain_alien_cache+0x3b/0xbd
      [   11.560442]
      [   11.560443] stack backtrace:
      [   11.561009] Pid: 1899, comm: udevd Not tainted 2.6.31-rc1 #896
      [   11.561276] Call Trace:
      [   11.561632]  [<ffffffff81065ed6>] __lock_acquire+0x15ec/0x168f
      [   11.561901]  [<ffffffff81065f60>] ? __lock_acquire+0x1676/0x168f
      [   11.562171]  [<ffffffff81063c52>] ? trace_hardirqs_on_caller+0x1=
13/0x13e
      [   11.562490]  [<ffffffff8150c337>] ? trace_hardirqs_on_thunk+0x3a=
/0x3f
      [   11.562807]  [<ffffffff8106603a>] lock_acquire+0xc1/0xe5
      [   11.563073]  [<ffffffff810c337f>] ? kmem_cache_free+0xcd/0x25b
      [   11.563385]  [<ffffffff8150c8fc>] _spin_lock+0x31/0x66
      [   11.563696]  [<ffffffff810c337f>] ? kmem_cache_free+0xcd/0x25b
      [   11.563964]  [<ffffffff810c337f>] kmem_cache_free+0xcd/0x25b
      [   11.564235]  [<ffffffff8109bf8c>] ? __free_pages+0x1b/0x24
      [   11.564551]  [<ffffffff810c3564>] slab_destroy+0x57/0x5c
      [   11.564860]  [<ffffffff810c3641>] free_block+0xd8/0x123
      [   11.565126]  [<ffffffff810c372e>] __drain_alien_cache+0xa2/0xbd
      [   11.565441]  [<ffffffff810c3ce5>] kfree+0x14c/0x292
      [   11.565752]  [<ffffffff8144a007>] skb_release_data+0xc6/0xcb
      [   11.566020]  [<ffffffff81449cf0>] __kfree_skb+0x19/0x86
      [   11.566286]  [<ffffffff81449d88>] consume_skb+0x2b/0x2d
      [   11.566631]  [<ffffffff8144cbe0>] skb_free_datagram+0x14/0x3a
      [   11.566901]  [<ffffffff81462eef>] netlink_recvmsg+0x164/0x258
      [   11.567170]  [<ffffffff81443461>] sock_recvmsg+0xe5/0xfe
      [   11.567486]  [<ffffffff810ab063>] ? might_fault+0xaf/0xb1
      [   11.567802]  [<ffffffff81053a78>] ? autoremove_wake_function+0x0=
/0x38
      [   11.568073]  [<ffffffff810d84ca>] ? core_sys_select+0x3d/0x2b4
      [   11.568378]  [<ffffffff81065f60>] ? __lock_acquire+0x1676/0x168f
      [   11.568693]  [<ffffffff81442dc1>] ? sockfd_lookup_light+0x1b/0x5=
4
      [   11.568961]  [<ffffffff81444416>] sys_recvfrom+0xa3/0xf8
      [   11.569228]  [<ffffffff81063c8a>] ? trace_hardirqs_on+0xd/0xf
      [   11.569546]  [<ffffffff8100af2b>] system_call_fastpath+0x16/0x1b=
#
   =20
    Fix that up.
   =20
    Closes-bug: http://bugzilla.kernel.org/show_bug.cgi?id=3D13654
    Tested-by: Venkatesh Pallipadi <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>

commit 82d5308127c3e3404ffbf41e503853c68660b18b
Author: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Fri Jun 26 17:07:02 2009 +0800

    trace_export: Repair missed fields
   =20
    Some fields for struct ftrace_graph_ret are missed
    when they are exported to user.
   =20
    Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
    LKML-Reference: <4A448FB6.5000302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit a32c7765e2796395aec49f699bd25c407155e9c5
Author: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date:   Fri Jun 26 16:55:51 2009 +0800

    tracing: Fix stack tracer sysctl handling
   =20
    This made my machine completely frozen:
   =20
      # echo 1 > /proc/sys/kernel/stack_tracer_enabled
      # echo 2 > /proc/sys/kernel/stack_tracer_enabled
   =20
    The cause is register_ftrace_function() was called twice.
   =20
    Also fix ftrace_enabled sysctl, though seems nothing bad happened
    as I tested it.
   =20
    Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
    Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    LKML-Reference: <4A448D17.9010305-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit 7ed9f7e5db58c6e8c2b4b738a75d5dcd8e17aad5
Author: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Thu Jun 25 12:31:37 2009 -0700

    fix RCU-callback-after-kmem_cache_destroy problem in sl[aou]b
   =20
    Jesper noted that kmem_cache_destroy() invokes synchronize_rcu() rath=
er than
    rcu_barrier() in the SLAB_DESTROY_BY_RCU case, which could result in =
RCU
    callbacks accessing a kmem_cache after it had been destroyed.
   =20
    Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Acked-by: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
    Reported-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
    Signed-off-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>

commit 6fdc03709433ccc2005f0f593ae9d9dd04f7b485
Author: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date:   Sat Jun 20 13:23:59 2009 +0200

    firewire: core: do not DMA-map stack addresses
   =20
    The DMA mapping API cannot map on-stack addresses, as explained in
    Documentation/DMA-mapping.txt.  Convert the two cases of on-stack pac=
ket
    payload buffers in firewire-core (payload of lock requests in the bus
    manager work and in iso resource management) to slab-allocated memory.
   =20
    There are a number on-stack buffers for quadlet write or quadlet read
    requests in firewire-core and firewire-sbp2.  These are harmless; the=
y
    are copied to/ from card driver internal DMA buffers since quadlet
    payloads are inlined with packet headers.
   =20
    Signed-off-by: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>

commit f6faac71d502be1c29c81b2f45657662c3b84470
Author: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Tue Jun 23 17:24:40 2009 -0700

    rcu: Mark Hierarchical RCU no longer experimental
   =20
    Removes the warnings about Hierarchical RCU being experimental,
    given that it has gone through almost six months of being the
    default RCU in mainline for the x86 with very little trouble.
   =20
    This makes hierarchical-RCU bootup look less scary.
   =20
    Signed-off-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
    Cc: niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
    Cc: dvhltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
    Cc: dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
    Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
    Cc: lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org
    Cc: kernel-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org
    Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
    Cc: schamp-sJ/iWh9BUns@public.gmane.org
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

commit bc47df0fa705887242c26c7b040e7cf0170ab1f1
Author: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date:   Wed May 20 18:50:34 2009 +0300

    osdblk: Adjust queue limits to lower device's limits
   =20
    call blk_queue_stack_limits() to copy queue limits from
    the underline osd scsi_device. This is absolutely needed
    because osdblk cannot sleep when allocating a lower-request and
    therefore cannot be bouncing.
   =20
    TODO: Dynamic changes of limits to the lower device queue
    will not reflect in the upper driver
   =20
    Signed-off-by: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>

commit 2a13877c5ef3207a2a5c56250742e60808677f90
Author: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Date:   Fri Apr 10 07:50:45 2009 -0400

    osdblk: a Linux block device for OSD objects
   =20
    Submitted driver exports a block device of the form /dev/osdblkX,
    where X is a decimal number.
   =20
    It does that by mounting a stacking block device on top
    of an osd object. For example, if you create a 2G object
    on an OSD device, you can then use this module to present
    that 2G object as a Linux block device.
   =20
    See inside patch for exact documentation.
   =20
    [Sitting at linux-next helped fix proper Kconfig dependency
     for this driver, thanks to Randy Dunlap]
   =20
    Signed-off-by: Jeff Garzik <jgarzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>

commit 42c55aa838bbd274a7ad2be1fd81d423ca63da4e
Author: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date:   Wed Jun 17 16:54:34 2009 +0300

    MAINTAINERS: Add osd maintained files (F:)
   =20
    OSD files are found in three places:
    drivers/scsi/osd/
    include/scsi/osd_*
    fs/exofs/
   =20
    Signed-off-by: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>

commit baaf94cdc7fe1c61e3c660a3b055724fd9d0a034
Author: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date:   Sun Jun 14 16:52:10 2009 +0300

    exofs: Avoid using file_fsync()
   =20
    The use of file_fsync() in exofs_file_sync() is not necessary since i=
t
    does some extra stuff not used by exofs. Open code just the parts tha=
t
    are currently needed.
   =20
    TODO: Farther optimization can be done to sync the sb only on inode
    update of new files, Usually the sb update is not needed in exofs.
   =20
    Signed-off-by: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>

commit 27d2e1491985e95c486d991302e399f5c584b4eb
Author: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date:   Sun Jun 14 17:23:09 2009 +0300

    exofs: Remove IBM copyrights
   =20
    Boaz,
    Congrats on getting all the OSD stuff into 2.6.30!
    I just pulled the git, and saw that the IBM copyrights are still ther=
e.
    Please remove them from all files:
     * Copyright (C) 2005, 2006
     * International Business Machines
   =20
    IBM has revoked all rights on the code - they gave it to me.
   =20
    Thanks!
    Avishay
   =20
    Signed-off-by: Avishay Traeger <avishay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>

commit b76a3f93d01fc93a87cb6eba4e854ffe378b4bac
Author: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date:   Mon Jun 8 19:28:41 2009 +0300

    exofs: Fix bio leak in error handling path (sync read)
   =20
    When failing a read request in the sync path, called from
    write_begin, I forgot to free the allocated bio, fix it.
   =20
    Signed-off-by: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>

commit b0a5b83ee0fce9dbf8ff5fe1f8c9ae7dfafe458c
Author: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date:   Tue Jun 16 16:11:14 2009 +0200

    dma-debug: Put all hash-chain locks into the same lock class
   =20
    Alan Cox reported that lockdep runs out of its stack-trace entries
    with certain configs:
   =20
     BUG: MAX_STACK_TRACE_ENTRIES too low
   =20
    This happens because there are 1024 hash buckets, each with a
    separate lock. Lockdep puts each lock into a separate lock class and
    tracks them independently.
   =20
    But in reality we never take more than one of the buckets, so they
    really belong into a single lock-class. Annotate the has bucket lock
    init accordingly.
   =20
    [ Impact: reduce the lockdep footprint of dma-debug ]
   =20
    Reported-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
    Signed-off-by: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>

commit c79ee4e466dd12347f112e2af306dca35198458f
Author: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>
Date:   Tue Jun 16 12:23:58 2009 +0200

    dma-debug: fix off-by-one error in overlap function
   =20
    This patch fixes a bug in the overlap function which returned true if
    one region ends exactly before the second region begins. This is no
    overlap but the function returned true in that case.
   =20
    Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
    Reported-by: Andrew Randrianasulu <randrik-JGs/UdohzUI@public.gmane.org>
    Signed-off-by: Joerg Roedel <joerg.roedel-5C7GfCeVMHo@public.gmane.org>

commit 62e086be5d2abef8cad854bc5707329ad345f2ec
Author: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sun Jun 14 17:59:34 2009 -0400

    ext4: Move __ext4_journalled_writepage() to avoid forward declaration
   =20
    In addition, fix two unused variable warnings.
   =20
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 43ce1d23b43330634507a049b55c36e91d27282e
Author: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sun Jun 14 17:58:45 2009 -0400

    ext4: Fix mmap/truncate race when blocksize < pagesize && !nodellaoc
   =20
    This patch fixes the mmap/truncate race that was fixed for delayed
    allocation by merging ext4_{journalled,normal,da}_writepage() into
    ext4_writepage().
   =20
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit c364b22c9580a885e0f8c0d0f9710d67dc448958
Author: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sun Jun 14 17:57:10 2009 -0400

    ext4: Fix mmap/truncate race when blocksize < pagesize && delayed all=
ocation
   =20
    It is possible to see buffer_heads which are not mapped in the
    writepage callback in the following scneario (where the fs blocksize
    is 1k and the page size is 4k):
   =20
    1) truncate(f, 1024)
    2) mmap(f, 0, 4096)
    3) a[0] =3D 'a'
    4) truncate(f, 4096)
    5) writepage(...)
   =20
    Now if we get a writepage callback immediately after (4) and before a=
n
    attempt to write at any other offset via mmap address (which implies =
we
    are yet to get a pagefault and do a get_block) what we would have is =
the
    page which is dirty have first block allocated and the other three
    buffer_heads unmapped.
   =20
    In the above case the writepage should go ahead and try to write the
    first blocks and clear the page_dirty flag. Further attempts to write
    to the page will again create a fault and result in allocating blocks
    and marking page dirty.  If we don't write any other offset via mmap
    address we would still have written the first block to the disk and
    rest of the space will be considered as a hole.
   =20
    So to address this, we change all of the places where we look for
    delayed, unmapped, or unwritten buffer heads, and only check for
    delayed or unwritten buffer heads instead.
   =20
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Acked-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit b767e78a179e5ab30fdbff1686d074ac270471eb
Author: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Thu Jun 4 08:06:06 2009 -0400

    ext4: Don't look at buffer_heads outside i_size.
   =20
    Buffer heads outside i_size will be unmapped. So when we
    are doing "walk_page_buffers" limit ourself to i_size.
   =20
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Reviewed-by: Josef Bacik <jbacik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Acked-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>
    ----

commit e6462869e4fd88be5141a356ee0c28d8067340cc
Author: Johann Lombardi <johann-UdXhSnd/wVw@public.gmane.org>
Date:   Sun Jul 5 23:45:11 2009 -0400

    ext4: Fix goal inum check in the inode allocator
   =20
    The goal inode is specificed by inode number which belongs
    to [1; s_inodes_count].
   =20
    Signed-off-by: Johann Lombardi <johann-xsfywfwIY+M@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 5adfee9c17314c1411095c23191c3cb0c2d25f9f
Author: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date:   Wed Jul 8 17:11:24 2009 -0400

    ext4: fix no journal corruption with locale-gen
   =20
    If there is no journal, ext4_should_writeback_data() should return
    TRUE.  This will fix ext4_set_aops() to set ext4_da_ops in the case o=
f
    delayed allocation; otherwise ext4_journaled_aops gets used by
    default, which doesn't handle delayed allocation properly.
   =20
    The advantage of using ext4_should_writeback_data() approach is that
    it should handle nobh better as well.
   =20
    Thanks to Curt Wohlgemuth for investigating this problem, and Aneesh
    Kumar for suggesting this approach.
   =20
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 5887e98b609e96ce61ee0528cf94a2bfdc809dd7
Author: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sun Jul 5 23:12:04 2009 -0400

    ext4: Calculate required journal credits for inserting an extent prop=
erly
   =20
    When we have space in the extent tree leaf node we should be able to
    insert the extent with much less journal credits. The code was doing
    proper calculation but missed a return statement.
   =20
    Reported-by: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit ffacfa7a79d6c00624196b2d13b0a7f72f2b8227
Author: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Date:   Mon Jul 13 16:22:22 2009 -0400

    ext4: Fix truncation of symlinks after failed write
   =20
    Contents of long symlinks is written via standard write methods. So
    when the write fails, we add inode to orphan list. But symlinks don't
    have .truncate method defined so nobody properly removes them from th=
e
    on disk orphan list.
   =20
    Fix this by calling ext4_truncate() directly instead of calling
    vmtruncate() (which is saner anyway since we don't need anything
    vmtruncate() does except from calling .truncate in these paths).  We
    also add inode to orphan list only if ext4_can_truncate() is true
    (currently, it can be false for symlinks when there are no blocks
    allocated) - otherwise orphan list processing will complain and
    ext4_truncate() will not remove inode from on-disk orphan list.
   =20
    Signed-off-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit f91d1d04171026e56c7e343ee3cdcc801dd85cfb
Author: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Date:   Mon Jul 13 16:16:20 2009 -0400

    jbd2: Fix a race between checkpointing code and journal_get_write_acc=
ess()
   =20
    The following race can happen:
   =20
     CPU1                          CPU2
                                   checkpointing code checks the buffer, =
adds
                                     it to an array for writeback
     do_get_write_access()
     ...
     lock_buffer()
     unlock_buffer()
                                   flush_batch() submits the buffer for I=
O
     __jbd2_journal_file_buffer()
   =20
    So a buffer under writeout is returned from
    do_get_write_access(). Since the filesystem code relies on the fact
    that journaled buffers cannot be written out, it does not take the
    buffer lock and so it can modify buffer while it is under
    writeout. That can lead to a filesystem corruption if we crash at the
    right moment.
   =20
    We fix the problem by clearing the buffer dirty bit under buffer_lock
    even if the buffer is on BJ_None list. Actually, we clear the dirty
    bit regardless the list the buffer is in and warn about the fact if
    the buffer is already journalled.
   =20
    Thanks for spotting the problem goes to dingdinghua <dingdinghua85@gm=
ail.com>.
   =20
    Reported-by: dingdinghua <dingdinghua85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 3e03f9ca6a2599db1823bb0ea24e0845219a0e69
Author: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Date:   Sun Jul 5 22:29:27 2009 -0400

    ext4: Use rcu_barrier() on module unload.
   =20
    The ext4 module uses rcu_call() thus it should use rcu_barrier()on
    module unload.
   =20
    The kmem cache ext4_pspace_cachep is sometimes free'ed using
    call_rcu() callbacks.  Thus, we must wait for completion of call_rcu(=
)
    before doing kmem_cache_destroy().
   =20
    Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 726447d803802cd0be8f62d17c4a34421781b938
Author: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jul 13 10:24:17 2009 -0400

    ext4: naturally align struct ext4_allocation_request
   =20
    As Ted noted, the ext4_allocation_request isn't well aligned.  Lookin=
g
    at it with pahole we're wasting space on 64-bit arches:
   =20
    struct ext4_allocation_request {
            struct inode *             inode;              /*     0     8=
 */
            ext4_lblk_t                logical;            /*     8     4=
 */
   =20
            /* XXX 4 bytes hole, try to pack */
   =20
            ext4_fsblk_t               goal;               /*    16     8=
 */
            ext4_lblk_t                lleft;              /*    24     4=
 */
   =20
            /* XXX 4 bytes hole, try to pack */
   =20
            ext4_fsblk_t               pleft;              /*    32     8=
 */
            ext4_lblk_t                lright;             /*    40     4=
 */
   =20
            /* XXX 4 bytes hole, try to pack */
   =20
            ext4_fsblk_t               pright;             /*    48     8=
 */
            unsigned int               len;                /*    56     4=
 */
            unsigned int               flags;              /*    60     4=
 */
            /* --- cacheline 1 boundary (64 bytes) --- */
   =20
            /* size: 64, cachelines: 1, members: 9 */
            /* sum members: 52, holes: 3, sum holes: 12 */
    };
   =20
    Grouping 32-bit members together closes these holes and shrinks the
    structure by 12 bytes. which is important since ext4 can get on the
    hairy edge of stack overruns.
   =20
    Signed-off-by: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 089ceecc1ea4a69ed8bcc5c7c7b96ce487e26b33
Author: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Sun Jul 5 22:17:31 2009 -0400

    ext4: mark several more functions in mballoc.c as noinline
   =20
    Ted noticed a stack-deep callchain through
    writepages->ext4_mb_regular_allocator->ext4_mb_init_cache->submit_bh =
...
   =20
    With all the static functions in mballoc.c, gcc helpfully
    inlines for us, and we get something like this:
   =20
    ext4_mb_regular_allocator	(232 bytes stack)
    	ext4_mb_init_cache	(232 bytes stack)
    		submit_bh	(starts 464 deeper)
   =20
    the 2 ext4 functions here get several others inlined; by telling
    gcc not to inline them, we can save stack space for when we
    head off into submit_bh land and associated block layer callchains.
    The following noinlined functions are only called once, so this
    won't impact any other callchains:
   =20
    ext4_mb_regular_allocator 			(104) (was 232)
    	ext4_mb_find_by_goal			 (56) (noinlined)
    	ext4_mb_init_group			 (24) (noinlined)
    		ext4_mb_init_cache		(136) (was 232)
    			ext4_mb_generate_buddy	 (88) (noinlined)
    			ext4_mb_generate_from_pa (40) (noinlined)
    			submit_bh
    	ext4_mb_simple_scan_group		 (24) (noinlined)
    	ext4_mb_scan_aligned			 (56) (noinlined)
    	ext4_mb_complex_scan_group		 (40) (noinlined)
    	ext4_mb_try_best_found			 (24) (noinlined)
   =20
    now when we head off into submit_bh() we're only 264 bytes deeper
    in stack than when we entered ext4_mb_regular_allocator()
    (vs. 464 bytes before).  Every 200 bytes helps.  :)
   =20
    Signed-off-by: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit f4a01017d678fe4baecf480e79d7c4f4b7ebc772
Author: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date:   Sun Jul 5 22:08:16 2009 -0400

    ext4: Fix potential reclaim deadlock when truncating partial block
   =20
    The ext4_block_truncate_page() function previously called
    grab_cache_page(), which called find_or_create_page() with the
    __GFP_FS flag potentially set.  This could cause a deadlock if the
    system is low on memory and it attempts a memory reclaim, which could
    potentially call back into ext4.  So we need to call
    find_or_create_page() directly, and remove the __GFP_FP flag to avoid
    this potential deadlock.
   =20
    Thanks to Roland Dreier for reporting a lockdep warning which showed
    this problem.
   =20
    [20786.363249] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
    [20786.363257] [ INFO: inconsistent lock state ]
    [20786.363265] 2.6.31-2-generic #14~rbd4gitd960eea9
    [20786.363270] ---------------------------------
    [20786.363276] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} us=
age.
    [20786.363285] http/8397 [HC0[0]:SC0[0]:HE1:SE1] takes:
    [20786.363291]  (jbd2_handle){+.+.?.}, at: [<ffffffff812008bb>] jbd2_=
journal_start+0xdb/0x150
    [20786.363314] {IN-RECLAIM_FS-W} state was registered at:
    [20786.363320]   [<ffffffff8108bef6>] mark_irqflags+0xc6/0x1a0
    [20786.363334]   [<ffffffff8108d347>] __lock_acquire+0x287/0x430
    [20786.363345]   [<ffffffff8108d595>] lock_acquire+0xa5/0x150
    [20786.363355]   [<ffffffff812008da>] jbd2_journal_start+0xfa/0x150
    [20786.363365]   [<ffffffff811d98a8>] ext4_journal_start_sb+0x58/0x90
    [20786.363377]   [<ffffffff811cce85>] ext4_delete_inode+0xc5/0x2c0
    [20786.363389]   [<ffffffff81146fa3>] generic_delete_inode+0xd3/0x1a0
    [20786.363401]   [<ffffffff81147095>] generic_drop_inode+0x25/0x30
    [20786.363411]   [<ffffffff81145ce2>] iput+0x62/0x70
    [20786.363420]   [<ffffffff81142878>] dentry_iput+0x98/0x110
    [20786.363429]   [<ffffffff81142a00>] d_kill+0x50/0x80
    [20786.363438]   [<ffffffff811444c5>] dput+0x95/0x180
    [20786.363447]   [<ffffffff8120de4b>] ecryptfs_d_release+0x2b/0x70
    [20786.363459]   [<ffffffff81142978>] d_free+0x28/0x60
    [20786.363468]   [<ffffffff81142a18>] d_kill+0x68/0x80
    [20786.363477]   [<ffffffff81142ad3>] prune_one_dentry+0xa3/0xc0
    [20786.363487]   [<ffffffff81142d61>] __shrink_dcache_sb+0x271/0x290
    [20786.363497]   [<ffffffff81142e89>] prune_dcache+0x109/0x1b0
    [20786.363506]   [<ffffffff81142f6f>] shrink_dcache_memory+0x3f/0x50
    [20786.363516]   [<ffffffff810f6d3d>] shrink_slab+0x12d/0x190
    [20786.363527]   [<ffffffff810f97d7>] balance_pgdat+0x4d7/0x640
    [20786.363537]   [<ffffffff810f9a57>] kswapd+0x117/0x170
    [20786.363546]   [<ffffffff810773ce>] kthread+0x9e/0xb0
    [20786.363558]   [<ffffffff8101430a>] child_rip+0xa/0x20
    [20786.363569]   [<ffffffffffffffff>] 0xffffffffffffffff
    [20786.363598] irq event stamp: 15997
    [20786.363603] hardirqs last  enabled at (15997): [<ffffffff81125f9d>=
] kmem_cache_alloc+0xfd/0x1a0
    [20786.363617] hardirqs last disabled at (15996): [<ffffffff81125f01>=
] kmem_cache_alloc+0x61/0x1a0
    [20786.363628] softirqs last  enabled at (15966): [<ffffffff810631ea>=
] __do_softirq+0x14a/0x220
    [20786.363641] softirqs last disabled at (15861): [<ffffffff8101440c>=
] call_softirq+0x1c/0x30
    [20786.363651]
    [20786.363653] other info that might help us debug this:
    [20786.363660] 3 locks held by http/8397:
    [20786.363665]  #0:  (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<ffff=
ffff8112ed24>] do_truncate+0x64/0x90
    [20786.363685]  #1:  (&sb->s_type->i_alloc_sem_key#5){+++++.}, at: [<=
ffffffff81147f90>] notify_change+0x250/0x350
    [20786.363707]  #2:  (jbd2_handle){+.+.?.}, at: [<ffffffff812008bb>] =
jbd2_journal_start+0xdb/0x150
    [20786.363724]
    [20786.363726] stack backtrace:
    [20786.363734] Pid: 8397, comm: http Tainted: G         C 2.6.31-2-ge=
neric #14~rbd4gitd960eea9
    [20786.363741] Call Trace:
    [20786.363752]  [<ffffffff8108ad7c>] print_usage_bug+0x18c/0x1a0
    [20786.363763]  [<ffffffff8108b0c0>] ? check_usage_backwards+0x0/0xb0
    [20786.363773]  [<ffffffff8108bad2>] mark_lock_irq+0xf2/0x280
    [20786.363783]  [<ffffffff8108bd97>] mark_lock+0x137/0x1d0
    [20786.363793]  [<ffffffff8108c03c>] mark_held_locks+0x6c/0xa0
    [20786.363803]  [<ffffffff8108c11f>] lockdep_trace_alloc+0xaf/0xe0
    [20786.363813]  [<ffffffff810efbac>] __alloc_pages_nodemask+0x7c/0x18=
0
    [20786.363824]  [<ffffffff810e9411>] ? find_get_page+0x91/0xf0
    [20786.363835]  [<ffffffff8111d3b7>] alloc_pages_current+0x87/0xd0
    [20786.363845]  [<ffffffff810e9827>] __page_cache_alloc+0x67/0x70
    [20786.363856]  [<ffffffff810eb7df>] find_or_create_page+0x4f/0xb0
    [20786.363867]  [<ffffffff811cb3be>] ext4_block_truncate_page+0x3e/0x=
460
    [20786.363876]  [<ffffffff812008da>] ? jbd2_journal_start+0xfa/0x150
    [20786.363885]  [<ffffffff812008bb>] ? jbd2_journal_start+0xdb/0x150
    [20786.363895]  [<ffffffff811c6415>] ? ext4_meta_trans_blocks+0x75/0x=
f0
    [20786.363905]  [<ffffffff811e8d8b>] ext4_ext_truncate+0x1bb/0x1e0
    [20786.363916]  [<ffffffff811072c5>] ? unmap_mapping_range+0x75/0x290
    [20786.363926]  [<ffffffff811ccc28>] ext4_truncate+0x498/0x630
    [20786.363938]  [<ffffffff8129b4ce>] ? _raw_spin_unlock+0x5e/0xb0
    [20786.363947]  [<ffffffff81107306>] ? unmap_mapping_range+0xb6/0x290
    [20786.363957]  [<ffffffff8108c3ad>] ? trace_hardirqs_on+0xd/0x10
    [20786.363966]  [<ffffffff811ffe58>] ? jbd2_journal_stop+0x1f8/0x2e0
    [20786.363976]  [<ffffffff81107690>] vmtruncate+0xb0/0x110
    [20786.363986]  [<ffffffff81147c05>] inode_setattr+0x35/0x170
    [20786.363995]  [<ffffffff811c9906>] ext4_setattr+0x186/0x370
    [20786.364005]  [<ffffffff81147eab>] notify_change+0x16b/0x350
    [20786.364014]  [<ffffffff8112ed30>] do_truncate+0x70/0x90
    [20786.364021]  [<ffffffff8112f48b>] T.657+0xeb/0x110
    [20786.364021]  [<ffffffff8112f4be>] sys_ftruncate+0xe/0x10
    [20786.364021]  [<ffffffff81013132>] system_call_fastpath+0x16/0x1b
   =20
    Reported-by: Roland Dreier <roland-ukP65eMp1S23Y08NHXK2NB2eb7JE58TQ@public.gmane.org>
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit b574480507460b8e31b8d38dd4642219fc3b9a10
Author: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date:   Sat Jun 20 23:34:44 2009 -0400

    jbd2: Remove GFP_ATOMIC kmalloc from inside spinlock critical region
   =20
    Fix jbd2_dev_to_name(), a function used when pretty-printting jbd2 an=
d
    ext4 tracepoints.
   =20
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

commit 627ad9fd0733f0a31a266ff98a4a933eee710f0b
Author: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date:   Sat Jun 20 23:21:41 2009 -0400

    ext4: Fix type warning on 64-bit platforms in tracing events header
   =20
    Signed-off-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============8541072686126819718==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8541072686126819718==--
