From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/5] Container Freezer v6: Reuse Suspend Freezer
Date: Mon, 11 Aug 2008 16:53:23 -0700
Message-ID: <20080811235323.872291138__46103.5229768187$1218499258$gmane$org@us.ibm.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch series introduces a cgroup subsystem that utilizes the swsusp
freezer to freeze a group of tasks. It's immediately useful for batch job
management scripts. It should also be useful in the future for implementing
container checkpoint/restart.

The freezer subsystem in the container filesystem defines a cgroup file named
freezer.state. Reading freezer.state will return the current state of the
cgroup.  Writing "FROZEN" to the state file will freeze all tasks in the
cgroup. Subsequently writing "RUNNING" will unfreeze the tasks in the cgroup. 

* Examples of usage :

   # mkdir /containers/freezer
   # mount -t cgroup -ofreezer freezer  /containers
   # mkdir /containers/0
   # echo $some_pid > /containers/0/tasks

to get status of the freezer subsystem :

   # cat /containers/0/freezer.state
   RUNNING

to freeze all tasks in the container :

   # echo FROZEN > /containers/0/freezer.state
   # cat /containers/0/freezer.state
   FREEZING
   # cat /containers/0/freezer.state
   FROZEN

to unfreeze all tasks in the container :

   # echo RUNNING > /containers/0/freezer.state
   # cat /containers/0/freezer.state
   RUNNING

Andrew, please consider these patches for -mm.

Cheers,
	-Matt Helsley

Changes since v5:
v6:
	Merged the patch using the cgroups write_string() method since Linus
		has merged the patch supporting it.
	Moved header file modifications to in patch 1 to
		arch/$ARCH/include/asm/thread_info.h where appropriate.
	Moved cgroup_freezer.h contents into cgroups_freezer.c and freezer.h
	Added CONFIG_FREEZER to help conditionally build the freezer code.
		This required some simplifications of the second patch.
	Fix a lock ordering problem with the freezer->lock reacquire code
		Required order: freezer->lock, css_set_lock, task->alloc_lock
		Reacquiring: css_set_lock, task->alloc_lock, freezer->lock
		Solution: change freezer_fork() to not require any ordering
			between task->alloc_lock and freezer->lock
v5:
	Split out write_string as a separate patch for easier merging
		with trees lacking certain cgroup patches at the time.
	Checked use of task alloc lock for races with swsusp freeze/thaw --
		looks safe because there are explicit barriers to handle
		freeze/thaw races for individual tasks, we explicitly
		handle partial group freezing, and partial group thawing
		should be resolved without changing swsusp's loop.
	Updated the patches to Linus' git tree as of approximately
		7/31/2008.
	Added Pavel and Serge's Acked-by lines to Acked patches

v4 (Almost all of these changes are confined to patch 3):
	Reworked the series to use task_lock() instead of RCU.
	Reworked the series to use write_string() and read_seq_string()
		cgroup methods.
	Fixed the race Paul Menage identified.
	Fixed up check_if_frozen() to do more than just test the FROZEN
		flag. In some cases tasks could be stopped (T) and marked
		FREEZING. When that happens we can safely assume that it
		will be frozen immediately upon waking up in the kernel.
		Waiting for it to get marked with PF_FROZEN in order to
		transition to the FROZEN state would block unnecessarily.
	Removed freezer_ prefix from static functions in cgroup_freezer.c.
	Simplified STATE_ switch.
	Updated the locking comments.

v3:
	Ported to 2.6.26-rc5-mm2 with Rafael's freezer patches
	Tested on 24 combinations of 3 architectures (x86, x86_64, ppc64)
		with 8 different kernel configs varying power management
		and cgroup config variables. Each patch builds and boots
		in these 24 combinations.
	Passes functional testing.

v2 (roughly patches 3 and 5):
	Moved the "kill" file into a separate cgroup subsystem (signal) and
		it's own patch.
	Changed the name of the file from freezer.freeze to freezer.state.
	Switched from taking 1 and 0 as input to the strings "FROZEN" and 
		"RUNNING", respectively. This helps keep the interface
		human-usable if/when we need to more states.
	Checked that stopped or interrupted is "frozen enough"
		Since try_to_freeze() is called upon wakeup of these tasks
		this should be fine. This idea comes from recent changes to
		the freezer.
	Checked that if (task == current) whilst freezing cgroup we're ok
	Fixed bug where -EBUSY would always be returned when freezing
	Added code to handle userspace retries for any remaining -EBUSY

-- 
