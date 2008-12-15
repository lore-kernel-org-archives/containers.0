From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC patch 0/2] posix mqueue namespace (v11)
Date: Mon, 15 Dec 2008 17:37:47 -0600
Message-ID: <20081215233747.GA27553@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

(Ok I don't know what the actual version number is - it's
high but 11 is probably safe)

Cedric and Nadia took several approaches to making posix
message queues per-namespace.  I ended up mamking some
deep changes so am not retaining their Signed-off-by:s
on this version, but this is definately very much based
on work by both of them.

Patch 2 hopefully explains my approach.  Briefly,

	1. sysv and posix ipc are both under CLONE_NEWIPC
	2. the mqueue sb is per-ipc-namespace

So to create a new ipc namespace, you would

	unshare(CLONE_NEWIPC|CLONE_NEWNS);
	umount /dev/mqueue
	mount -t mqueue mqueue /dev/mqueue

It's perfectly valid to do vfs operations on files
in another ipc_namespace's /dev/mqueue, but any use
of mq_open(3) and friends will act in your own ipc_ns.

thanks,
-serge
