From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH v2 0/2] cgroups: implement moving a threadgroup's
	threads atomically with cgroup.procs
Date: Sat, 29 May 2010 21:30:02 -0400
Message-ID: <20100530013002.GA762@ghc01.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

This patch series is a revision of http://lkml.org/lkml/2010/1/3/51 and
http://lkml.org/lkml/2010/1/3/52 .

The rwsem in the fork path has been moved to signal_struct to simplify
the locking code in the cgroup_attach_proc side. This depends on Oleg's
recentish changes to signal_struct's lifetime rules (which don't seem to
appear when I check out mmotm with git clone, so I wasn't able to do any
more than basic testing).

There is still a race with exec in the case where the threadgroup leader
changes. To solve this, this implementation checks if the race occurred
after all previous set-up has been done and all necessary locks are
held, and if so, returns -EAGAIN which is handled by the calling
function by looping until a different value is returned.

-- bblum

---
 Documentation/cgroups/cgroups.txt |    9
 include/linux/cgroup.h            |   15 -
 include/linux/init_task.h         |    9
 include/linux/sched.h             |   10
 kernel/cgroup.c                   |  435 +++++++++++++++++++++++++++++++++-----
 kernel/fork.c                     |   10
 6 files changed, 431 insertions(+), 57 deletions(-)
