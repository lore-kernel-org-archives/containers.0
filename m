From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: lxc-start: Device or resource busy - failed to remove previous cgroup
Date: Sun, 3 Jan 2010 19:10:58 -0600
Message-ID: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I'm starting to get is quite regularly, but not every time:

lxc-start: Device or resource busy - failed to remove previous cgroup
'/cgroup/CONTAINER_NAME'

lxc version: 0.6.3

Cgroup memory controller: disabled (everything else is enabled)

Linux version 2.6.30-bpo.1-amd64 (Debian 2.6.30-6~bpo50+1)
(nobse-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #1 SMP Mon
Aug 17 08:42:50 UTC 2009

This only seems to be happening when the primary started in the
container exits before all child processes have exited.

I've not seem this happen with lxc-stop, only when quitting a "pseudo"
init process.

I've tried destroying and recreating the container, un=mounting and
remounting the given container, none work in that situation. Rebooting
the root-node does correct the problem.

If this is known to have been fixed in 0.6.4 then I'll upgrade to that.


Dwight Schauer
