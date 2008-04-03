From: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC PATCH 0/4] Container Freezer: Reuse Suspend Freezer
Date: Thu, 03 Apr 2008 14:03:16 -0700
Message-ID: <20080403210316.397506379@us.ibm.com>
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
To: Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

NOTE: Due to problems with my MTA configuration two earlier attempts reached linux-pm
but not linux-kernel. Please cc linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org on replies.

This patchset is a prototype using the container infrastructure and
the swsusp freezer to freeze a group of tasks. I've merely taken Cedric's
patches, forward-ported them to 2.6.25-rc8-mm1 and done a small amount of
testing.

2 files are defined by the freezer subsystem in the container
filesystem :

   * "freezer.freeze"

     writing 1 will freeze all tasks and 0 unfreeze
     reading will return the status of the freezer
 
   * "freezer.kill"

     writing <n> will send signal number <n> to all tasks

* Usage :

   # mkdir /containers/freezer
   # mount -t container -ofreezer freezer  /containers/freezer
   # mkdir /containers/freezer/0
   # echo $some_pid > /containers/freezer/0/tasks

to get status of the freezer subsystem :

   # cat /containers/freezer/0/freezer.freeze
   RUNNING

to freeze all tasks in the container :

   # echo 1 > /containers/freezer/0/freezer.freeze
   # cat /containers/freezer/0/freezer.freeze
   FREEZING
   # cat /containers/freezer/0/freezer.freeze
   FROZEN

to unfreeze all tasks in the container :

   # echo 1 > /containers/freezer/0/freezer.freeze
   # cat /containers/freezer/0/freezer.freeze
   RUNNING

to kill all tasks in the container :

   # echo 9 > /containers/freezer/0/freezer.kill

* Caveats: 

  - the FROZEN status is calculated and changed when the container
    file "freezer.freeze" is read.
  - frozen containers will be unfrozen when a system is resumed after 
    a suspend. This is addressed by the last patch.

* Series

  Applies to 2.6.25-rc8-mm1

  The first patches make the freezer available to all architectures
  before implementing the freezer subsystem.

[RFC PATCH 1/4] Add TIF_FREEZE flag to all architectures
[RFC PATCH 2/4] Make refrigerator always available
[RFC PATCH 3/4] Implement freezer cgroup subsystem
[RFC PATCH 4/4] Skip frozen cgroups during power management resume

  Each patch compiles, boots, and survives basic LTP containers and controllers 
  	tests.
  
Comments are welcome.

Cheers,
	-Matt Helsley

-- 
