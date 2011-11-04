From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: user namespaces: fix some uid/privilege leaks
Date: Fri,  4 Nov 2011 22:24:36 +0000
Message-ID: <1320445482-8459-1-git-send-email-serge@hallyn.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: richard-/L3Ra7n9ekc@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

The previous submission of these patches, and review comments, can be
seen in the thread starting here: https://lkml.org/lkml/2011/10/18/463 .
Since then, patches 
0001-pid_ns-ensure-pid-is-not-freed-during-kill_pid_info_.patch
and
0002-user-namespace-usb-make-usb-urbs-user-namespace-awar.patch
have gone upstream, and I've reverted
0009-make-net-core-scm.c-uid-comparisons-user-namespace-a.patch
because it relaxes checks, and right now we want to focus on
fixing leaks.

The set includes:

0001-user-namespace-make-signal.c-respect-user-namespaces.patch
	This convers the uid for the task sending a signal to the
	user namespace of the receiver.  It is somewhat analogous
	to what is done with the sender's pid.
	Waiting on feedback from Oleg, but I believe this patch is
	ready.

0002-User-namespace-don-t-allow-sysctl-in-non-init-user-n.patch
	This prevents root in a child user namespace from man-handling
	sysctls.  With this patch, a task in a child user namespace
	will only get the world access rights to sysctls.

0003-user-namespace-clamp-down-users-of-cap_raised.patch
	This clamps down on cases where privilege to your own user
	namespace were checked for access to the initial user namespace.

0004-Add-Documentation-namespaces-user_namespace.txt-v3.patch
	Documentation.

0005-user-namespace-make-each-net-net_ns-belong-to-a-user.patch
	This adds a struct user_namespace pointer to the net_ns for use
	by later patches.

0006-protect-cap_netlink_recv-from-user-namespaces.patch
	Now that net_ns is owned by a user_ns, cap_netlink_recv() can
	target privilege checks to the user_ns owning the resource.  The
	current check against current_cap() is unsafe.
