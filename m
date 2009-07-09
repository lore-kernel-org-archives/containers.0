From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v7-rc1,
	created. 768ee7c3a407b31f8b7202ce5395163dfe79893e
Date: Thu, 9 Jul 2009 08:42:22 -0400
Message-ID: <200907091242.n69CgM7Q030390@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v7-rc1 has been created
        at  768ee7c3a407b31f8b7202ce5395163dfe79893e (commit)

- Log -----------------------------------------------------------------
commit 768ee7c3a407b31f8b7202ce5395163dfe79893e
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Thu Jul 9 08:33:17 2009 -0400

    mktree: cleanup collect of coordinator/root task
    
    Fix the logic that collects the coordinator and/or root task
    and report their exit status.
    
    This mainly fixes bad behavior when 'mktree' itself is a container
    init (e.g. started with nsexec), in which case it collects not only
    the coordinator but all orphan zombies resulting from the restart.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit d6212fcfdacfa431d4981ede025e1fb0ad86153e
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jul 6 17:27:03 2009 -0500

    mktree: s390: don't hard-code clone-with-pids syscall
    
    Use __NR_clone_with_pids (from asm/unistd.h) as an immediate
    value instead.
    
    Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 5e55d1ed5e1855c7d4109326c0c9ab45a59f7a10
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jul 1 22:55:52 2009 -0400

    mktree.c: options --pids and --pidns imply each other by default
    
    To restart into current pidns with pids restored, use:
       $ mktree --pids --no-pidns ....
    
    Also fix a glitch by negating the test before the call to prctl()
    such that it works as advertised in the preceeding comment.

commit aa3d206329307fa928ea059d64c70c85c2b7e5b5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jul 1 06:00:27 2009 -0400

    test/sigpending.c: add test case for pending signals

commit 7933c3e71de3abd48adb848de5d70e369ccdcacc
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Sat Jun 27 12:27:04 2009 -0700

    Use __WALL option in waitpid()
    
    The coordinator creates the children with clone(), so pass the __WALL
    option to waitpid(). Otherwise the waitpid() will fail, and bring the
    container down even as the application is restarting successfully :-)
    
    For instance, if the original app is executed as:
      $ ns_exec -cpuimP pid.ptree1 -- ./ptree1 -n 2 -d 1 -w sleep
    
    Then ns_exec creates the app in new container, with p->exit_signal 0
    for the container-init. Restart correctly restores the exit_signal to
    0. Because of that, we need the coordinator to use __WALL.
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: use __WALL in all waitpid() of coordinator]

commit 50dfc2f4ab2856bfa2b3580df2eb65bad71f2561
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Jun 28 00:52:51 2009 -0400

    mktree.c: rework the parent-child cleanup/collect logic
    
    Misc fixes to the coodinator <=> root-task logic and, in the pidns
    (where root-task isn't init) to the mktree <=> coordinator logic:
    
    * The ret value of getpid() is cached by libc, but we bypass libc with
     a direct call to clone_with_pids(). Instead use syscall(__NR_pid) to
     always get a fresh ret value.
    
    * Register SIGINT and SIGCHLD handler after forking root-task (and
     coordinator), instead of before. Parent then probes that the newborn
     exists before proceeding.
    
    * Newborn children use prctl(PR_SET_PDEATHSIG...) after they verify
     that the parent is indeed there.
    
    * More complete treatment of waitpid() ret value in sigchld_handler().
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 8b62a1157458e058c588e61707f94fa0d0893dd9
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Jun 26 02:11:18 2009 -0400

    ckptinfo.c: add option to show position (per object) in stream

commit 9751413013c1d35dfeb35e3f9241dcc07099c1a4
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Jun 26 01:43:11 2009 -0400

    mktree.c: make feeder task a thread instead of child
    
    When mktree is also the coordinator task and also a container init,
    e.g. when started with 'ns' and with '--no-pidns', the feeder process
    would be re-parented to it and produce a SIGCHLD when it terminated.
    In turn, this would interrupt coordinator's wait-for-completion of
    the restart.
    
    Converting the feeder task to a thread (but without using SIGCHLD in
    the flags) eliminates this problem.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c5f5c204676233fcc55f771e9e251ed0054e02e4
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Thu Jun 25 03:51:13 2009 -0400

    ckptinfo.c: auto-generate conversion of CKPT_..._.... to string
    
    Introduce ckptinfo.py that expects checkpoint_hdr.h files (both
    generic and arch-dependent) and produces C code to convert the
    hdr/obj/file/vma constants to a descriptive string.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a19d5941bcd9b9dc2e2813d824372d642714db6d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 24 12:32:19 2009 -0400

    ckptinfo.c: more information on objref objects

commit a011424ca7c7e702cabaed4e09b0e153af9d6586
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 24 12:31:35 2009 -0400

    mktree.c: adjust changes in checkpoint header format

commit 24f69887a07b355b93ec51b7df80e719c783f90b
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jun 15 14:08:21 2009 -0500

    mktree: use clone_with_pid on s390
    
    Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: don't define __NR_clone_with_pids]

commit 597ac659e839ddaa4f3d978ac7bce862b4d74ace
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 17 05:08:02 2009 -0400

    mktree.c: improve cleanup on failure without '--pids'

commit 77481bbd1620b4b79aff8dfe0feeb3f892e81e93
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 17 00:58:22 2009 -0400

    mktree.c: ensure that all tasks are ready for coordinator
    
    The (recent) restart logic requires that all restarting tasks be
    already alive when the coordinator starts to read the checkpoint image
    file (i.e. prior to calling prepare_descendants() in the kernel).
    
    This has already been the case for the "no --pids" case, because the
    feeder would first wait to hear from all restarting tasks about their
    new pids, and only then push actual data to the kernel.
    
    Now, for the '--pids' case, piggy-back on this mechanism to create the
    same end effect, so when coordinator starts to process data from the
    file descriptor, the hierarchy is properly prepared.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 8b63138cfe4a8918a2e1cccb83e9bde1b0eb1400
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jun 16 07:12:08 2009 -0400

    mktree.c: adjust to restart logic, remove CLONE_RESTART flag
    
    The kernel restart logic has changed: the coordinator now sets the
    t->restart_tsk pointer on the descendants, instead of using a new
    clone flag to pass it through inheritance.
    
    By ridding the need for clone_with_pids() (except for --pids case)
    we now again have a convenient fallback - clone - when the former
    isn't available.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 8a242a6cb5a96280b57e0cc420556918553c2f56
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sat Jun 13 18:59:36 2009 -0400

    test/zombie.c: add test case for zombie processes

commit 834557f604173e49940755b9e7bc992033551305
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 10 14:03:58 2009 -0400

    mktree.c: give compile error if clone_with_pids() not found
    
    This is necessary because the restart logic changes and now requires
    that syscall.

commit 950f5711600d69b18271909dc9ed16ff799400c0
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jun 9 21:25:22 2009 -0400

    mktree.c: add --debug, --verbose, --pidns-intr=SIG switches
    
    --debug: controls debug output
    
    --verbose: controls verbosity (status report)
    
    --pidns-intr=SIG: signal to send to root task (when --pidns) if we
    (mktree) get a SIGINT, e.g. via ctrl-c

commit 12f83a6f46384516e98bed3019b56812bba8533d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jun 9 18:47:07 2009 -0400

    mktree.c: now works with --pidns (new pid namespace)
    
    In particular, for --pidns mktree checks the pid of the root_task.
    
    If the pid is 1, proceed as before for a new namespace, and fork
    the root_task with CLONE_NEWPID.
    
    If the pid isn't 1, then fork a coordinator task into a new pidns
    so that it becomes the init task there, and don't use CLONE_NEWPID
    for the root task.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit b5d5c4694f95b5bb041246c0fbb97033662c5fb9
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Jun 8 19:37:09 2009 -0400

    Makefile: add target 'install'

commit 7c5a747b60dde3e75d1f9f8e09de1f1e0e88b525
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Jun 8 19:31:01 2009 -0400

    mktree.c: allow compile (and run) whithout CLONE_NEWPID defined

commit 8fc8b640f8674d6de553cded539d24e08fac6f34
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Jun 8 03:51:51 2009 -0400

    mktree.c: add support for pid-ns and clone_with_pids()
    
    Add three new options to 'mktree':
      --pidns: do the restart in a new pid namespace
      --no-pidns: do the restart in current pid namespace (default)
      --pids: in case of --no-pidns, try to restore pids nevertheless.
    
    If @pidns, coordinator task uses CLONE_NEWPID when forking the
    root task. Current only one pidns level is supported.
    
    If @pids (or @pidns), tasks are created with clone_with_pids()
    and original pids are restored.
    
    For now, 'struct target_pid_set' is defined explicitly in the
    source (should be defined in kernel header, though).
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit f9ad6e5f0f591ef6e9d751b11e989abc78f08e42
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 3 20:56:29 2009 -0400

    ckpt.c: include <linux/checkpoint.h> (instead of checkpoint_types.h)

commit 955ac3d5f77c339c58e19bb5f86da80696277df2
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 3 12:26:15 2009 -0400

    rstr: use flag RESTART_TASKSELF for restart(2)

commit b037c3a34dd0f5706b52720368f2ca7890507745
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jun 3 12:25:44 2009 -0400

    ckptinfo: remove stale use of CKPT_HDR_THREAD_TLS

commit a2588254c54c11781de3f0c933af11ad28c6f861
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jun 2 18:41:20 2009 -0400

    mktree: use a coordinator task during restart
    
    Kernel code was updated to expect a coordinator task when multiple
    tasks are restarted (commit b0ddfc4784a543fdb98662d975963468e13ad3fa)
    
    This patch adapts mktree.c to that scheme. In particular, the main
    task is the coordinator. It now forks the feeder task and then also
    forks the root restarting task.
    
    One benfit is that error reporting makes sense now: the user will
    see a suitable error message instead of the segfault of the init
    task.
    
    Also, it's now easier to add the "CLONE_NEWPID" when creating the
    init task to put the restarting processes in a new namespace.
    
    Added switch to 'mktree':  --wait (-w) to wait for restart (root)
    task to exit, --show-status to show its exit status, --copy-status
    to imitate its exit status, and --no-wait (-W) to not wait for it.
    
    Catch SIGINT and pass it to the restart task if in --wait mode.
    
    Catch SIGCHLD (until restart succeeds) to detect errors.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 84d41dc494936c2df054fd652b3ea5de777d75a4
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jun 2 17:17:13 2009 -0400

    self.c: include linux/checkpoint.h instead of linux/checkpoint_types.h

commit 3af016061c79c54876714a718238bccd2e438528
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun May 31 14:18:45 2009 -0400

    self.c: use flag CHECKPOINT_SUBTREE in call to checkpoint(2)

commit a43c6bef1dfb893284d4dc458af9bf93f8ead21f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed May 27 13:40:19 2009 -0400

    test/ipcmsq.c: trivial fix

commit a016172a0b8c4913df553fba050b31d81e78e1cd
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed May 27 13:37:54 2009 -0400

    ckptinfo: update header names to match recent kernel version
    
    CKPT_HDR_FD_TABLE --> CKPT_HDR_FILE_TABLE
    CKPT_HDR_FD_ENT --> CKPT_HDR_FILE_DESC
    CKPT_HDR_FNAME --> CKPT_HDR_FILE_NAME

commit a6de98cc847195e9cd10100747ba90689d11cadb
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed May 20 10:08:19 2009 -0400

    ckptinfo: convert hdr type to a meaningful string
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 9caa4d725e13b7c02cd2ed773a82d874e23293ef
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed May 20 01:14:40 2009 -0400

    ckpt: suppress output unless verbose mode
    
    And if in verbose mode, output to stderr so that output
    does not mix with checkpoint image (written to stdout).
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 59b13cea2deacb51f8ef1089206d23eb7622a22c
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue May 19 19:34:19 2009 -0400

    mktree: adjust ckpt_{read/write}_tree() for latest kernel code
    
    Recent commit (85e92fe0ebae7fcee647da6aeb7d1c637906aa58) in kerenl c/r
    modified the format such that all checkpoint objects be preceeded with
    a 'struct ckpt_hdr'. Adjust ckpt_read_tree() and ckpt_write_tree() to
    play by the new rules.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 44fbe41d49e0b29758f18f01259348176d5c6bc1
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon May 18 10:15:02 2009 -0400

    test/pipes.c: also test a pipe with empty buffer
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit caeaa30ecd929fa73fc31f39ffb6c6fede12f9ce
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed May 13 21:29:32 2009 -0500

    mktree: long is bigger on 64-bit (v2)
    
    mktree's hash function assumes that long is 32 bits.  Fix.
    
    This version takes Nathan's suggestion of using sizeof(key)
    instead of sizeof(long).
    
    Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit ff8bf06be34f826bbb0e21079e581b176f459813
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Apr 28 06:40:52 2009 -0400

    mktree.c: set errno to report EINVAL upon a header type mismatch

commit ed39a49c27d441782113b51ed935a383e00fdd10
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Apr 28 05:35:38 2009 -0400

    ckpt.c: take a new switch -c/--container for whole-container checkpoint
    
    By default (without this switch) the flags for checkpoint(2) will have
    CHECKPOINT_SUBTREE, meaning that a partial-container checkpoint will be
    taken. If the switch is set, then the flag isn't set.

commit af0592106c75ac06404e4b950cb0cc4649cec8b1
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Apr 27 01:19:03 2009 -0400

    Add sysvipc sempahore test

commit 8c30846a573f8a36be1ff01ab703070e7f508504
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Apr 27 01:18:32 2009 -0400

    mktree.c: adapt to recent changes in image format

commit d40488e63db525489d51200aa18d0c264381b16e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Apr 14 02:44:06 2009 -0400

    mktree: set 'session->phantom' when adding a placeholder task
    
    Placeholder tasks are used to generate session ids of tasks that
    have died prior to the checkpoint. There is at most one placeholder
    per session, pointed to by ->phantom.
    
    Also, Sukadev Bhattiprolu observed that a task with ppid==1 and a
    session id like the container-init can be viewed either as an orphan
    task or as a child of containter-init. To avoid an unnecessary
    placeholder in this case, switch the order of the orphan and the
    same-sid-as-parent tests.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 01fe7523a743f80fb4f9c34eaabf96a69c33b40c
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Apr 14 02:39:59 2009 -0400

    Move test programs into own directory
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 1eda10788d01e81cdd90c9939d33a417f1d2b743
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Thu Apr 9 10:46:10 2009 -0700

    Add a multi-process IPC test
    
    This test forks off several children in various states to ensure that
    the IPC namespace information is properly restored after restart.
    Automatically validates the results and returns a pass/fail status
    indication for automated runs.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit c5e62e41ad078fd8379a1f20d54a2e5c0621bdaf
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Apr 7 08:20:06 2009 -0400

    mktree: adapt to the change 'tasks_nr' -> 'nr_tasks' in kernel

commit 7b06b70fd66754a4e1c1e3fd3bb336986ebee67c
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Apr 7 08:17:09 2009 -0400

    add test for ipc message queues: tst_ipcmsq

commit 6cd1f63423a5a824f36a377ef74175e5db798b53
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Apr 5 18:47:14 2009 -0400

    mktree: remap sid/pgid that point out of subtrees to subtree init
    
    When restarting a subtree (that was checkpointed out-of-container), there
    may be processes that carry a sid/pgid that don't belong to the subtree
    (e.g. from an acenstore further above). In this case, remaps these to the
    sid/pgid of the subtree init.

commit d2251c8a2099499485a9e280488c29103edc5c62
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Apr 1 10:18:04 2009 -0400

    Inroduce DumpForest algorithm to build creator-child-relationship tree
    
    Support restart of multiple processes from userspace, in the presence
    of threads, dead (zombie) tasks and clones with CLONE_PARENT, and while
    preserving the session-id.
    
    The algorithm was described in the paper "Transparent Checkpoint/Restart
    of Multiple Processes on Commodity Operating Systems" in USENIX 2007
    (http://www.usenix.org/events/usenix07/tech/full_papers/laadan/laadan_html/paper.html).
    
    We distinguish between a process parent and its creator: the differ for
    threads and for clone with CLONE_PARENT. For each task the algorithm
    assigns a creator, and for each creator the algorihtm assigns the list
    of children to create. In the next patch this will be used as a set of
    instructions to create the processes
    
    The output is a tree that describes these relationships. The tasks are
    stores in a large array and the tree structure is imposed on this array.
    The size array is three times the number of tasks, to accommodate for
    new place-holder tasks that the algorithm may add on demand.
    
    To provide fast lookup of a task in the array/tree given its pid, there
    is also a simple hash table implementation that translates a pid to the
    pointer to the task.
    
    If restarting a non-container (that is, a subtree of processes from some
    namespace), then the "root" process is not init. The code is careful to
    compare with the subtree root instead. On the other hand, we can't have
    zombie processes.

commit 91e2648efcc60dee8ede2b60f35e27c8dd76473f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Mar 25 23:08:03 2009 -0400

    add test for ipc shmem: tst_ipcshm

commit 070e833ffc150fde1f20c10a0307265297a4bc69
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Mar 22 11:16:24 2009 -0400

    adjust code to read/save length of individual uts-> fields in head

commit 6685ed37ba49181d9de81a47a241d23eb372c6f2
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Fri Mar 20 10:47:12 2009 -0400

    Introduce tests: tst_pipes2 and tst_shmem

commit de626971e73cce030186d16fed375add054a9f0f
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Fri Mar 20 10:29:09 2009 -0400

    Rename test programs to have meaningful names

commit 64eeb18a9ab504029bc492cfd03429275d23fadd
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Fri Mar 20 10:27:15 2009 -0400

    Fix bug in cr_adjust_id() if tasks switch their pids on restart
    
    Make a copy of the original array to fix a nifty bug where two
    tasks in original image with pids, e.g., 3 and 5, restart with
    pids swapped (5 and 3), for instance -
    
    	original pid array:    [][][3][][5][]...
    	first, swap B with A:  [][][3][][3][]...
    	then, swap A with B:   [][][5][][5][]...
    	but correct should be: [][][5][][3][]...

commit b48cde69b3a3cd8910608cd1d9cd6b6c52dfb5c6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Thu Mar 19 14:42:13 2009 -0400

    Adjust mktree.c to changes in cr_hdr_head format
    
    The ->release, ->machine, ->version were removed, and instead written
    as buffers following the structures.

commit 5e105d3d2b41ece4f2d92faf25e5c5c338447027
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Thu Mar 19 14:40:12 2009 -0400

    Make kernel source path configurable
    
    Add an optional argument to the user-cs Makefile called KERNELPATH that
    allows one to specify the path for kernel sources to use for the build.
    
    Signed-off-by: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 934a779e15474aa345c606048394823f00cf9ebc
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jan 27 16:20:16 2009 -0500

    Introduce test3 (large memory allocations) and test4 (pipes)

commit 8c1235aec3d3265b8ca20827867abe6873752b42
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Nov 10 05:09:09 2008 -0500

    Makefile to be more user friendly

commit fefa1cddb6210d751c9c94faf4afd25ebef60245
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Nov 10 05:05:50 2008 -0500

    Add some documentation

commit 8fac424d135970108452007f7a8ddbbecef6973c
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Nov 10 03:57:36 2008 -0500

    mktree: read (and write) cr_hdr_head_arch

commit d07ee202cf2fd7ccb78d179b2f99ff6efc8eb1db
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Nov 9 17:53:26 2008 -0500

    Always use feeder (and checkpoint image has one header, one tree)
    
    Kernel checkpoint for multiple process no longer saves two copies of
    the header and the tree; Therefore, restarting processes in user space
    requires using a feeder anyway.

commit 689981cf7d65239727ec4379d9e0976546c3bbb5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sat Nov 8 19:40:07 2008 -0500

    no-pids: use child as feeder to avoid orphaning the group
    
    In 'no-pids' mode, use the child process for the feeder, so that
    the original task (mktree) remains the process group leader and
    isn't orphaned.
    
    The feeder task is made reparented to init(1) so the original
    task need not collect it (if restart succeeds, of course it won't !)
    
    Add documentation and do some code cleanups.

commit a5c75e48a56b90dd29fb8fa0976aba98e1594b6d
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Nov 3 01:37:51 2008 -0500

    Add switch to choose operation with or without original pids

commit 0b451e0e8b2dbcb93432ea433e46cc4a2f90a3ab
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Nov 3 00:04:05 2008 -0500

    Transfrom pids_arr to actual pids before calling sys_restart
    
    Allow 'mktree' to restart a tree of processes without the need to
    clone-with-pid by modifying the pids_arr structure prior to the
    actual restart.
    
    We use a "helper task" that forks the init (that forks the others),
    and expects to receive via a pipe the translations old ==> new pids.
    The task also reads the checkpoint in and write the (modified) data
    out to the stdin of the restarting process.
    
    Of course, this assumes that the application can tolerate the change
    of pids after a restart.

commit 5816520817665bf82a6c6a14d468ce46ce08126b
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Nov 2 21:40:25 2008 -0500

    Add ckpt,rstr,self,test1,test2

commit 3d17677bd6139f27d8c4f5be573e76c899fee9f5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Nov 2 18:24:40 2008 -0500

    Allow 'mktree' to execute even not as container init
    
    By not requiring that a task's pid be identical to the expected
    pid from the pids_arr information. This allows to run (and test)
    the restart even not inside a container. In particular, one can
    also drop the requirement of restoring pids.. and voila :)

commit 6b1eee10075c23cf24e06aa6eb91783c7392abcf
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Oct 31 20:21:35 2008 -0400

    Initial commit: mktree.c and its Makefile

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
