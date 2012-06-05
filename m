From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
	inetpeer
Date: Tue, 05 Jun 2012 10:57:06 +0200
Message-ID: <1338886626.2760.2109.camel__44399.9079674997$1338886644$gmane$org@edumazet-glaptop>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338882737-11914-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2012-06-05 at 15:52 +0800, Gao feng wrote:

> +static void __net_exit inetpeer_net_exit(struct net *net)
> +{
> +	inetpeer_invalidate_tree(net, AF_INET);
> +	kfree(net->ipv4.peers);
> +
> +	inetpeer_invalidate_tree(net, AF_INET6);
> +	kfree(net->ipv6.peers);
> +}
> +

Are we 1000% sure no code ever run in inetpeer land after this call ?

I would add
	net->ipv4.peers = NULL;
	net->ipv6.peers = NULL;

to catch NULL deref instead of strange errors, just in case.

By the way, I think we have a bug in inetpeer_gc_worker()

Steffen ?

We have no rcu grace period to make sure the following is safe :

if (!atomic_read(&p->refcnt)) {
	list_del(&p->gc_list);
	kmem_cache_free(peer_cachep, p);
}

I'll post a fix like :

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d4d61b6..07731b5 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -137,7 +137,7 @@ static void inetpeer_gc_worker(struct work_struct *work)
 
 		n = list_entry(p->gc_list.next, struct inet_peer, gc_list);
 
-		if (!atomic_read(&p->refcnt)) {
+		if (atomic_cmpxchg(&p->refcnt, 0, -1) == 0) {
 			list_del(&p->gc_list);
 			kmem_cache_free(peer_cachep, p);
 		}
