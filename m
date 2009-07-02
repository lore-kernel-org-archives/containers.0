From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [user-cr][git]user-cr branch, ckpt-v16-tmp,
	created. a948c4dfa170040ec5bbdcda398e881ed3b65256
Date: Wed, 1 Jul 2009 21:19:40 -0400
Message-ID: <200907020119.n621JeCp007558@gorgona.ncl.cs.columbia.edu>
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
the project "user-cr".

The branch, ckpt-v16-tmp has been created
        at  a948c4dfa170040ec5bbdcda398e881ed3b65256 (commit)

- Log -----------------------------------------------------------------
commit a948c4dfa170040ec5bbdcda398e881ed3b65256
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

-----------------------------------------------------------------------


hooks/post-receive
--
user-cr
