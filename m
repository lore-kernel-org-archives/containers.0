From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 2/2][RFC] Factor sys_socket and sys_socketat
Date: Fri, 31 Oct 2008 22:56:04 +0100
Message-ID: <20081031215903.669547269@fr.ibm.com>
References: <20081031215602.655672481@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=factor-out-socket-and-socketat-code.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org, andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The common code between sys_socket and sys_socketat has been
grouped into the socket_create function. The both functions make
use of it.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 net/socket.c |   41 ++++++++---------------------------------
 1 file changed, 8 insertions(+), 33 deletions(-)

Index: net-next-2.6/net/socket.c
===================================================================
--- net-next-2.6.orig/net/socket.c
+++ net-next-2.6/net/socket.c
@@ -1216,7 +1216,7 @@ int sock_create_kern(int family, int typ
 	return __sock_create(&init_net, family, type, protocol, res, 1);
 }
 
-asmlinkage long sys_socket(int family, int type, int protocol)
+static int socket_create(struct net *net, int family, int type, int protocol)
 {
 	int retval;
 	struct socket *sock;
@@ -1236,7 +1236,7 @@ asmlinkage long sys_socket(int family, i
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
 		flags = (flags & ~SOCK_NONBLOCK) | O_NONBLOCK;
 
-	retval = sock_create(family, type, protocol, &sock);
+	retval = __sock_create(net, family, type, protocol, &sock, 0);
 	if (retval < 0)
 		goto out;
 
@@ -1253,49 +1253,24 @@ out_release:
 	return retval;
 }
 
+asmlinkage long sys_socket(int family, int type, int protocol)
+{
+	return socket_create(current->nsproxy->net_ns, family, type, protocol);
+}
+
 asmlinkage long sys_socketat(int fd, int family, int type, int protocol)
 {
 	int retval, fput_needed;
 	struct socket *sock;
-	struct socket *sockat;
-	struct net *net;
-	int flags;
-
-	/* Check the SOCK_* constants for consistency.  */
-	BUILD_BUG_ON(SOCK_CLOEXEC != O_CLOEXEC);
-	BUILD_BUG_ON((SOCK_MAX | SOCK_TYPE_MASK) != SOCK_TYPE_MASK);
-	BUILD_BUG_ON(SOCK_CLOEXEC & SOCK_TYPE_MASK);
-	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);
-
-	flags = type & ~SOCK_TYPE_MASK;
-	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
-		return -EINVAL;
-	type &= SOCK_TYPE_MASK;
-
-	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
-		flags = (flags & ~SOCK_NONBLOCK) | O_NONBLOCK;
 
 	sock = sockfd_lookup_light(fd, &retval, &fput_needed);
 	if (!sock)
 		goto out;
 
-	net = sock_net(sock->sk);
-
-	retval = __sock_create(net, family, type, protocol, &sockat, 0);
-	if (retval)
-		goto out_fput;
-
-	retval = sock_map_fd(sock, flags & (O_CLOEXEC | O_NONBLOCK));
-	if (retval < 0)
-		goto out_release;
-out_fput:
+	retval = socket_create(sock_net(sock->sk), family, type, protocol);
 	fput_light(sock->file, fput_needed);
 out:
 	return retval;
-
-out_release:
-	sock_release(sockat);
-	goto out;
 }
 
 /*

-- 
