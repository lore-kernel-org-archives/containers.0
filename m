From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 2/6] netns brnetfilter: cleanup during table unregister
Date: Fri, 22 Aug 2008 02:21:26 +0400
Message-ID: <20080821222126.GP31136__8904.02436857603$1219357601$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
List-Id: containers.vger.kernel.org

So far it wasn't needed, because modules were pinned just right to prevent ebtables from
unloading when cleanup was necessary.

ebt_unregster_table() is called during netns stop now, so...

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/bridge/netfilter/ebtables.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1262,6 +1262,8 @@ void ebt_unregister_table(struct ebt_table *table)
 	mutex_lock(&ebt_mutex);
 	list_del(&table->list);
 	mutex_unlock(&ebt_mutex);
+	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
+			  ebt_cleanup_entry, NULL);
 	vfree(table->private->entries);
 	if (table->private->chainstack) {
 		for_each_possible_cpu(i)
-- 
1.5.6.3
