From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/38] netns 2/2: extract net_create()
Date: Fri, 22 May 2009 08:55:04 +0400
Message-ID: <1242968132-1044-10-git-send-email-adobriyan__2342.6789012321$1242968950$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

net_create() will be used by C/R to create fresh netns on restart.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/core/net_namespace.c |   44 ++++++++++++++++++++------------------------
 1 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 4488010..6b3edc9 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -115,38 +115,34 @@ static void net_free(struct net *net)
 	kmem_cache_free(net_cachep, net);
 }
 
-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+static struct net *net_create(void)
 {
-	struct net *new_net = NULL;
-	int err;
-
-	if (!(flags & CLONE_NEWNET))
-		return get_net(old_net);
-
-	err = -ENOMEM;
-	new_net = net_alloc();
-	if (!new_net)
-		goto out_err;
+	struct net *net;
+	int rv;
 
+	net = net_alloc();
+	if (!net)
+		return ERR_PTR(-ENOMEM);
 	mutex_lock(&net_mutex);
-	err = setup_net(new_net);
-	if (!err) {
+	rv = setup_net(net);
+	if (rv == 0) {
 		rtnl_lock();
-		list_add_tail(&new_net->list, &net_namespace_list);
+		list_add_tail(&net->list, &net_namespace_list);
 		rtnl_unlock();
 	}
 	mutex_unlock(&net_mutex);
+	if (rv < 0) {
+		net_free(net);
+		return ERR_PTR(rv);
+	}
+	return net;
+}
 
-	if (err)
-		goto out_free;
-out:
-	return new_net;
-
-out_free:
-	net_free(new_net);
-out_err:
-	new_net = ERR_PTR(err);
-	goto out;
+struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+{
+	if (!(flags & CLONE_NEWNET))
+		return get_net(old_net);
+	return net_create();
 }
 
 static void cleanup_net(struct work_struct *work)
-- 
1.5.6.5
