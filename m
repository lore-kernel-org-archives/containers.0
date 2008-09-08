From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 03/33] nf_conntrack_gre: nf_ct_gre_keymap_flush() fixlet
Date: Mon,  8 Sep 2008 07:02:40 +0400
Message-ID: <1220842990-30500-3-git-send-email-adobriyan__41710.9049427838$1220843385$gmane$org@gmail.com>
References: <48C01046.2070704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C01046.2070704-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

It does "kfree(list_head)" which looks wrong because entity that was
allocated is definitely not list_head.

However, this all works because list_head is first item in
struct nf_ct_gre_keymap .

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 2752b74..c5a7822 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -45,12 +45,12 @@ static LIST_HEAD(gre_keymap_list);
 
 void nf_ct_gre_keymap_flush(void)
 {
-	struct list_head *pos, *n;
+	struct nf_ct_gre_keymap *km, *tmp;
 
 	write_lock_bh(&nf_ct_gre_lock);
-	list_for_each_safe(pos, n, &gre_keymap_list) {
-		list_del(pos);
-		kfree(pos);
+	list_for_each_entry_safe(km, tmp, &gre_keymap_list, list) {
+		list_del(&km->list);
+		kfree(km);
 	}
 	write_unlock_bh(&nf_ct_gre_lock);
 }
