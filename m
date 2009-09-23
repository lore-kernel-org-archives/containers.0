From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 69/80] c/r: introduce checkpoint/restore methods to struct
	proto_ops
Date: Wed, 23 Sep 2009 19:51:49 -0400
Message-ID: <1253749920-18673-70-git-send-email-orenl__29155.7038472549$1253756295$gmane$org@librato.com>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This adds new 'proto_ops' function for checkpointing and restoring
sockets. This allows the checkpoint/restart code to compile nicely
when, e.g., AF_UNIX sockets are selected as a module.

It also adds a function 'collecting' a socket for leak-detection
during full-container checkpoint. This is useful for those sockets
that hold references to other "collectable" objects. Two examples are
AF_UNIX buffers which reference the socket of origin, and sockets that
have file descriptors in-transit.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/net.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4fc2ffd..b99f350 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -147,6 +147,9 @@ struct sockaddr;
 struct msghdr;
 struct module;
 
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+
 struct proto_ops {
 	int		family;
 	struct module	*owner;
@@ -191,6 +194,12 @@ struct proto_ops {
 				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
+	int		(*checkpoint)(struct ckpt_ctx *ctx,
+				      struct socket *sock);
+	int		(*collect)(struct ckpt_ctx *ctx,
+				   struct socket *sock);
+	int		(*restore)(struct ckpt_ctx *ctx, struct socket *sock,
+				   struct ckpt_hdr_socket *h);
 };
 
 struct net_proto_family {
-- 
1.6.0.4
