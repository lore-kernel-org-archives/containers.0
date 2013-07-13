From: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Single process controlling all cgroups sounds like looking in right
	direction but wrong solution.
Date: Sat, 13 Jul 2013 18:53:14 +1000
Message-ID: <CANA3KFV6LmfKYUo305Fo2Yv_0kJGSSa7OjnGi8BMb+0Ys9e8NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

NUMA is where the fun starts.   If I wish to adjust a group of processes
bound only to a NUMA group of cpus.   It should not be required to disrupt
other cpus.

Init system controlling the cgroups is also sounding trouble.   Why we
don't want to write like 1 000 000 different interfaces to talk to cgroups.

Items like chromuim browser might wish to use cgroups in future to lets say
contain flash.

Best solution to the problems  not a library or in the init system its a
form of userspace driver.

The userspace driver has the permissions to alter and change cgroups and
possible no right todo anything else in final form.

Why not part of the init binary.   Lets say you have 1000 processors.
And for some reason you are running something that tweaking cgroups a
lot.   You don't want to stall all 1000 processes if it not required.
Single process could cause this.   What ever in in change of the cgroups
has to be massively multi threaded.    Also has to be changeable based on
NUMA requirements of the system at times.   You don't want to have to be
editing the core of init system or reboot the system just to change the
cgroup management system to be more compatible with current hardware.  This
is again why userspace driver.  You can stop the driver and start another
one if required.   While still maintaining the rule of only 1 active at any
1 time.  If someone can load a kernel driver any how the can cause hell.

Single process is not going to work because this will require stopping all
cpus.   What is required is single processes/theads.

Going the userspace driver solution emulation of the old cgroup system
could be pushed into userspace.   So removing old code from the core and
allow rejecting of hazard changes to be applied to the old method without
having to update kernel every time.

If there is an requirement to change the interface in future its less
problem.

If kbus (kernel dbus) was already done I would be tempted to place this as
a default feature on the kbus.   This would not be dependant on any
particular init system.

Since kbus is not ready creating a text device to receive messages for now
would be a suitable solution in my eyes.

Peter Dolding
