From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/14] user namespaces v2: continue targetting capabilities
Date: Tue, 26 Jul 2011 18:58:23 +0000
Message-ID: <1311706717-7398-1-git-send-email-serge__45702.2503404461$1311706889$gmane$org@hallyn.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

here is a set of patches to continue targetting capabilities
where appropriate.  This set goes about as far as is possible
without making the VFS user namespace aware, meaning that the
VFS can provide a namespaced view of userids, i.e init_user_ns
sees file owner 500, while child user ns sees file owner 0 or
1000.  (There are a few other things, like siginfos, which can
be addressed before we address the VFS).

With this set applied, you can create and configure veth netdevs
if your user namespace owns your network namespace (and you are
privileged), but not otherwise.

Some simple testcases can be found at
https://code.launchpad.net/~serge-hallyn/+junk/usernstests with
packages at https://launchpad.net/~serge-hallyn/+archive/userns-natty

Feedback very much appreciated.

Changes since v1:
    documentation: incorporate feedback on user_namespaces.txt
    netlink_capable: use sock_net() instead of ifdefs
