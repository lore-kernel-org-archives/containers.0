From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/7] netns ebtables: more cleanup during
	ebt_unregister_table()
Date: Tue, 28 Oct 2008 23:59:48 +0300
Message-ID: <20081028205948.GE15660@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
To: kaber@trash.net
Cc: netfilter@vger.kernel.org, containers@osdl.org
List-Id: containers.vger.kernel.org

Now that ebt_unregister_table() can be called during netns stop, and module
pinning scheme can't prevent netns stop, do table cleanup by hand.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bridge/netfilter/ebtables.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1209,6 +1209,10 @@ void ebt_unregister_table(struct ebt_table *table)
 	mutex_lock(&ebt_mutex);
 	list_del(&table->list);
 	mutex_unlock(&ebt_mutex);
+	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
+			  ebt_cleanup_entry, NULL);
+	if (table->private->nentries)
+		module_put(table->me);
 	vfree(table->private->entries);
 	if (table->private->chainstack) {
 		for_each_possible_cpu(i)
