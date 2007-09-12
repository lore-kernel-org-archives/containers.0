From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 1/3] fix export symbols
Date: Wed, 12 Sep 2007 14:38:12 +0200
Message-ID: <20070912124414.640551634@mai.toulouse-stg.fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=net-fix-export-symbol.patch
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: ebiederm@xmission.com, containers@lists.osdl.org, netdev@vger.kernel.org, Mark Nelson <markn@au1.ibm.com>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

Add the appropriate EXPORT_SYMBOLS for proc_net_create,
proc_net_fops_create and proc_net_remove to fix errors when
compiling allmodconfig

Signed-off-by: Mark Nelson <markn@au1.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/proc/proc_net.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: net-2.6.24/fs/proc/proc_net.c
===================================================================
--- net-2.6.24.orig/fs/proc/proc_net.c
+++ net-2.6.24/fs/proc/proc_net.c
@@ -31,6 +31,7 @@
 {
 	return create_proc_info_entry(name,mode, net->proc_net, get_info);
 }
+EXPORT_SYMBOL_GPL(proc_net_create);
 
 struct proc_dir_entry *proc_net_fops_create(struct net *net,
 	const char *name, mode_t mode, const struct file_operations *fops)
@@ -42,12 +43,13 @@
 		res->proc_fops = fops;
 	return res;
 }
+EXPORT_SYMBOL_GPL(proc_net_fops_create);
 
 void proc_net_remove(struct net *net, const char *name)
 {
 	remove_proc_entry(name, net->proc_net);
 }
-
+EXPORT_SYMBOL_GPL(proc_net_remove);
 
 static struct proc_dir_entry *proc_net_shadow;
 

-- 
