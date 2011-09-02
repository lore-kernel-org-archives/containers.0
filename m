From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: (unknown)
Date: Fri,  2 Sep 2011 19:56:24 +0000
Message-ID: <1314993400-6910-2-git-send-email-serge__40077.4295362227$1314993455$gmane$org@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Subject: 
In-Reply-To: <1314993400-6910-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-3NddpPZAyC0@public.gmane.org, segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

GIT: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt (v3)
GIT: [PATCH 02/15] user ns: setns: move capable checks into per-ns attach
GIT: [PATCH 03/15] keyctl: check capabilities against key's user_ns
GIT: [PATCH 04/15] user_ns: convert fs/attr.c to targeted capabilities
GIT: [PATCH 05/15] userns: clamp down users of cap_raised
GIT: [PATCH 06/15] user namespace: make each net (net_ns) belong to a
GIT: [PATCH 07/15] user namespace: use net->user_ns for some capable
GIT: [PATCH 08/15] af_netlink.c: make netlink_capable userns-aware
GIT: [PATCH 09/15] user ns: convert ipv6 to targeted capabilities
GIT: [PATCH 10/15] net/core/scm.c: target capable() calls to user_ns
GIT: [PATCH 11/15] userns: make some net-sysfs capable calls targeted
GIT: [PATCH 12/15] user_ns: target af_key capability check
GIT: [PATCH 13/15] userns: net: make many network capable calls targeted
GIT: [PATCH 14/15] net: pass user_ns to cap_netlink_recv()
GIT: [PATCH 15/15] make kernel/signal.c user ns safe (v2)
