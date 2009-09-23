From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 68/80] Add common socket helpers to unify the security
	hooks
Date: Wed, 23 Sep 2009 19:51:48 -0400
Message-ID: <1253749920-18673-69-git-send-email-orenl__26605.3306092092$1253754348$gmane$org@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This moves the meat out of the bind(), getsockname(), and getpeername() syscalls
into helper functions that performs security_socket_bind() and then the
sock->ops->call().  This allows a unification of this behavior between the
syscalls and the pending socket restart logic.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/net/sock.h |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/socket.c       |   29 ++++++-----------------------
 2 files changed, 54 insertions(+), 23 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 950409d..12530bf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1578,6 +1578,54 @@ extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
+/* bind() helper shared between any callers needing to perform a bind on
+ * behalf of userspace (syscall and restart) with the security hooks.
+ */
+static inline int sock_bind(struct socket *sock,
+			    struct sockaddr *addr,
+			    int addr_len)
+{
+	int err;
+
+	err = security_socket_bind(sock, addr, addr_len);
+	if (err)
+		return err;
+	else
+		return sock->ops->bind(sock, addr, addr_len);
+}
+
+/* getname() helper shared between any callers needing to perform a getname on
+ * behalf of userspace (syscall and restart) with the security hooks.
+ */
+static inline int sock_getname(struct socket *sock,
+			       struct sockaddr *addr,
+			       int *addr_len)
+{
+	int err;
+
+	err = security_socket_getsockname(sock);
+	if (err)
+		return err;
+	else
+		return sock->ops->getname(sock, addr, addr_len, 0);
+}
+
+/* getpeer() helper shared between any callers needing to perform a getpeer on
+ * behalf of userspace (syscall and restart) with the security hooks.
+ */
+static inline int sock_getpeer(struct socket *sock,
+			       struct sockaddr *addr,
+			       int *addr_len)
+{
+	int err;
+
+	err = security_socket_getpeername(sock);
+	if (err)
+		return err;
+	else
+		return sock->ops->getname(sock, addr, addr_len, 1);
+}
+
 /* 
  *	Enable debug/info messages 
  */
diff --git a/net/socket.c b/net/socket.c
index 6d47165..63c4498 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1414,15 +1414,10 @@ SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __user *, umyaddr, int, addrlen)
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock) {
 		err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
-		if (err >= 0) {
-			err = security_socket_bind(sock,
-						   (struct sockaddr *)&address,
-						   addrlen);
-			if (!err)
-				err = sock->ops->bind(sock,
-						      (struct sockaddr *)
-						      &address, addrlen);
-		}
+		if (err >= 0)
+			err = sock_bind(sock,
+					(struct sockaddr *)&address,
+					addrlen);
 		fput_light(sock->file, fput_needed);
 	}
 	return err;
@@ -1610,11 +1605,7 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
 	if (!sock)
 		goto out;
 
-	err = security_socket_getsockname(sock);
-	if (err)
-		goto out_put;
-
-	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0);
+	err = sock_getname(sock, (struct sockaddr *)&address, &len);
 	if (err)
 		goto out_put;
 	err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr, usockaddr_len);
@@ -1639,15 +1630,7 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock != NULL) {
-		err = security_socket_getpeername(sock);
-		if (err) {
-			fput_light(sock->file, fput_needed);
-			return err;
-		}
-
-		err =
-		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
-				       1);
+		err = sock_getpeer(sock, (struct sockaddr *)&address, &len);
 		if (!err)
 			err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr,
 						usockaddr_len);
-- 
1.6.0.4
