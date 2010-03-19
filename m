From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 0/5][lxc]: Link with USERCR
Date: Thu, 18 Mar 2010 23:39:12 -0700
Message-ID: <20100319063912.GA25732@us.ibm.com>
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
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


Link lxc_checkpoint, lxc_restart with USERCR[2]

Following set of patches, when applied to LXC 0.6.5 and built with
USERCR, enable lxc_checkpoint and lxc_restart of some simple containers.

TODO:
	- For simplicity, this patchset currently links *statically* with
	  USERCR. We should eventually build checkpoint.o and restart.o in
	  USERCR as shared objects and link lxc_checkpoint/lxc_restart with
	  these shared objects and liblxc.so. (This also required rebuilding
	  lxc-execute statically, so lxc_checkpoint can communicate with
	  lxc-execute to get the root-pid of container).

	- Determine if lxc_checkpoint needs a --container option (see
	  TODOs in src/lxc/checkpoint.c)

	- This patchset was tested using lxc-macvlan.conf. But for the VNC
	  server testing I ran into a problem with lxc-macvlan.conf. I
	  switched to 'lxc-no-netns.conf' and was able to C/R the VNC server.
	  I have not debugged the problem with VNC and lxc-macvlan.conf.

	- 'global_send_sigint' is still a global variable in USERCR. We need
	  to define a better interface to expose its functionality to callers
	  of app_restart().

	- Choose better names and API for USERCR :-)

Changelog[v2]: 
	(Based on feedback from Oren Laadan, Serge Hallyn, Daniel Lezcano
	and Cedric Le Goater)

	- Rather than drop --directory option to lxc_checkpoint/lxc_restart
	  add a new option (--image).

	- Integrate lxc_checkpoint to work with USERCR

	- USERCR renamed usercr.h to "app-checkpoint.h"

	- USERCR does not create/install libcheckpoint.a and usercr.h for now.
	  So link directly with app-checkpoint.h, restart.o and checkpoint.o

	- USERCR renames the interfaces to app_checkpoint() and app_restart()
	  'struct app_checkpoint_args' 'struct app_restart_args'.
	  
USAGE:

1. Build USERCR

	$ cd /root

	$ git-clone git://git.ncl.cs.columbia.edu/pub/git/user-cr.git user-cr

	$ git-checkout ckpt-v20 
	
	# Apply patches in the following set:

	# https://lists.linux-foundation.org/pipermail/containers/2010-March/023793.html

	$ cd /root/user-cr

	$ make 

		This should create restart.o and checkpoint.o

2. Build/install lxc_checkpoint and lxc_restart

	# Do normal LXC build/install of 0.6.5.

	# Then replace 'lxc-execute', 'lxc-checkpoint', 'lxc-restart' with
	# new version. i.e Apply attached patches and:

	$ cd src/lxc

	$ USERCR=/root/user-cr \
		make -f Makefile2 lxc_checkpoint lxc_restart lxc_execute

	$ cp lxc_checkpoint lxc_restart lxc-execute  /usr/local/bin

3. Checkpoint/restart a simple LXC container

	$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 1000

	$ lxc-freeze --name foo

	$ lxc-checkpoint --name foo --image /root/lxc-foo.ckpt

	$ lxc-unfreeze --name foo

	$ lxc-stop --name foo

	$ lxc-restart --name foo --image /root/lxc-foo.ckpt

4. Checkpoint/restart other LXC containers such as:

	- a file-io session (see run-fileio1 in cr-tests[1])

	- process-tree (see run-ptree1 in cr-tests[1])

	- A vi session inside a VNC Server using "twm". i.e

		$ cat /root/.vnc/xstartup
		#!/bin/sh

		xsetroot -solid grey
		vncconfig -iconic &
		xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
		twm &

		$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- \
			/usr/bin/vncserver :1

		$ vncviewer :1

			# Open a vi session

		$ lxc-freeze --name foo 

			etc

[1]: cr-tests:	git://git.sr71.net/~hallyn/cr_tests.git
[2]: USERCR: git://git.ncl.cs.columbia.edu/pub/git/user-cr.git

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
