From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 1/1][NETNS49] Make af_unix autobind per network namespace
Date: Tue, 02 Oct 2007 17:18:47 +0200
Message-ID: <20071002152618.174798683@mai.toulouse-stg.fr.ibm.com>
References: <20071002151846.827206013@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=net-ns-make-af-unix-autobind-per-namespace.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

This patch change the static ordernum variable to be relative to the
network namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 include/net/net_namespace.h |    1 +
 net/unix/af_unix.c          |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6-netns/include/net/net_namespace.h
===================================================================
--- linux-2.6-netns.orig/include/net/net_namespace.h
+++ linux-2.6-netns/include/net/net_namespace.h
@@ -60,6 +60,7 @@ struct net {
 	/* AF_UNIX */
 	int			sysctl_unix_max_dgram_qlen;
 	void			*unix_sysctl;
+	u32                     ordernum;
 
 	/* XFRM */
 	u32			sysctl_xfrm_aevent_etime;
Index: linux-2.6-netns/net/unix/af_unix.c
===================================================================
--- linux-2.6-netns.orig/net/unix/af_unix.c
+++ linux-2.6-netns/net/unix/af_unix.c
@@ -681,8 +681,8 @@ static int unix_autobind(struct socket *
 	struct sock *sk = sock->sk;
 	struct net *net = sk->sk_net;
 	struct unix_sock *u = unix_sk(sk);
-	static u32 ordernum = 1;
 	struct unix_address * addr;
+	u32 ordernum = net->ordernum;
 	int err;
 
 	mutex_lock(&u->readlock);
@@ -720,6 +720,7 @@ retry:
 	u->addr = addr;
 	__unix_insert_socket(&unix_socket_table[addr->hash], sk);
 	spin_unlock(&unix_table_lock);
+	net->ordernum = ordernum;
 	err = 0;
 
 out:	mutex_unlock(&u->readlock);
@@ -2164,6 +2165,8 @@ static int unix_net_init(struct net *net
 	int error = -ENOMEM;
 
 	net->sysctl_unix_max_dgram_qlen = 10;
+	net->ordernum = 1;
+
 #ifdef CONFIG_PROC_FS
 	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops))
 		goto out;

-- 
