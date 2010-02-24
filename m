From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 0/4][user-cr]: First try at integrating LXC and USER-CR
Date: Wed, 24 Feb 2010 00:34:52 -0800
Message-ID: <20100224083452.GB18758@us.ibm.com>
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
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


Following two sets of patches is an early attempt to integrate LXC and
USER-CR. 

Overview:

Have USER-CR export the core checkpoint and restart functionality into a
library (/lib/libcheckpoint.a and <usercr.h>) and have LXC link with this
library.

TODO: 

	1. For now, libcheckpoint.a implements only the restart functionality
	   and so only lxc_restart command is implemented. Implementing the
	   checkpoint functionality and lxc_checkpoint command can be done
	   similarly and is hopefully easier than the restart functionality.

	2. The restart() functionality in user-cr makes extensive use of global
	   variables and debug code. The API must be extended to properly
	   include these variables/debug code in the API.

	   Similarly, the 'struct restart_args' may need to be sanitized for
	   use in a formal API.

	3. lxc_restart command  restarts entire containers only (specifically
	   it simulates the --pidns --pids --mount-pty arguments to
	   /bin/restart).

	4. Link lxc_restart and lxc_checkpoint with the shared library
	   liblxc.so (currently links statically)

	5. ...


STATUS:
	I was able to checkpoint/restart a simple '/bin/sleep 1000' LXC
	container, except for a cgroup naming issue after restart (see below).

STEPS:

1. [USER-CR] Build/install /lib/libcheckpoint.a, /usr/include/usercr.h
   
   1.1 Apply the attached [user-cr] patches to the user-cr git tree
       (I tested with following commit as base)

	commit 67cfee9329670ab28eb1a52e94745252b614718f
	Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
	Date:   Mon Feb 22 18:00:06 2010 -0500

   1.2 Build/install user-cr binaries/libraries/includes

   	$ make all

	$ make install

	This should install /lib/libcheckpoint.a and /usr/include/usercr.h

2. [LXC] Build lxc_restart using USER-CR API (usercr.h, libcheckpoint.a)

   2.1 Apply attached [lxc] patches to Daniel Lezcano's lxc.git tree (0.6.5)

   2.2 Build lxc_restart (this uses static linking for now)

   	$ make -f Makefile2 lxc_restart

3. Create and checkpoint a simple LXC container

	$ lxc-execute --name foo --rcfile lxc-macvlan.conf -- /bin/sleep 1000

	$ lxc-freeze --name foo

	TODO: 
		lxc_checkpoint --name foo should checkpoint the container,
		For now, use "lxc-ps --name foo" to find pid of lxc-init and
		checkpoint using:

		$ /bin/checkpoint --output=/tmp/sleep.ckpt <pid-of-lxc-init>

	$ lxc-unfreeze --name foo

	$ lxc-stop --name foo

4. Restart a checkpointed LXC container

	$ ./lxc_restart --statefile /tmp/sleep.ckpt --name bar

   	# Test some common lxc commands after restart

	$ lxc-ps --name "bar/1"
	CONTAINER    PID TTY          TIME CMD
	bar/1       8511 ?        00:00:00 lxc-init
	bar/1       8512 ?        00:00:00 sleep

	$ lxc-freeze --name "bar/1"

	$ grep State /proc/8511/status 
	State:	D (disk sleep)

	$ grep State /proc/8512/status 
	State:	D (disk sleep)

	NOTE: 	For some reason, the container name after restart is "bar/1"
		instead of "bar".  Due to this, when the lxc_restart is
		exiting, I get a "-EBUSY - failed to remove "/cgroup/bar"
		error.  I need to fix this still.
