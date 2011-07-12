From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 12/14] user_ns: target af_key capability check
Date: Tue, 12 Jul 2011 23:30:50 +0000
Message-ID: <1310513452-13397-13-git-send-email-serge__1051.1731882163$1310513957$gmane$org@hallyn.com>
References: <1310513452-13397-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1310513452-13397-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

This presumes that it really is complete wrt network namespaces.  Looking
at the code it appears to be.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/key/af_key.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 8f92cf8..414f409 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -141,7 +141,7 @@ static int pfkey_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
-- 
1.7.4.1
