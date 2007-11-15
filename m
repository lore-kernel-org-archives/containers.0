From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 01/10][NETNS][IP6_FIB] make mindless changes
Date: Thu, 15 Nov 2007 15:01:44 +0100
Message-ID: <20071115140514.573386893@mai.toulouse-stg.fr.ibm.com>
References: <20071115140143.597214582@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=ip6-fib-dynamic-make-mindless-changes.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This patch changes all references to the static global variables
fib6_main_tbl and fib6_local_tbl by a pointer. That provides the
minimal changes to dynamically allocate these tables for the network
namespaces. 

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/ip6_fib.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

Index: linux-2.6-netns/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_fib.c
+++ linux-2.6-netns/net/ipv6/ip6_fib.c
@@ -166,7 +166,7 @@ static __inline__ void rt6_release(struc
 		dst_free(&rt->u.dst);
 }
 
-static struct fib6_table fib6_main_tbl = {
+static struct fib6_table __fib6_main_tbl = {
 	.tb6_id		= RT6_TABLE_MAIN,
 	.tb6_root	= {
 		.leaf		= &ip6_null_entry,
@@ -174,6 +174,8 @@ static struct fib6_table fib6_main_tbl =
 	},
 };
 
+static struct fib6_table *fib6_main_tbl = &__fib6_main_tbl;
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 #define FIB_TABLE_HASHSZ 256
 #else
@@ -201,7 +203,7 @@ static void fib6_link_table(struct fib6_
 }
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-static struct fib6_table fib6_local_tbl = {
+static struct fib6_table __fib6_local_tbl = {
 	.tb6_id		= RT6_TABLE_LOCAL,
 	.tb6_root 	= {
 		.leaf		= &ip6_null_entry,
@@ -209,6 +211,8 @@ static struct fib6_table fib6_local_tbl 
 	},
 };
 
+static struct fib6_table *fib6_local_tbl = &__fib6_local_tbl;
+
 static struct fib6_table *fib6_alloc_table(u32 id)
 {
 	struct fib6_table *table;
@@ -263,8 +267,8 @@ struct fib6_table *fib6_get_table(u32 id
 
 static void __init fib6_tables_init(void)
 {
-	fib6_link_table(&fib6_main_tbl);
-	fib6_link_table(&fib6_local_tbl);
+	fib6_link_table(fib6_main_tbl);
+	fib6_link_table(fib6_local_tbl);
 }
 
 #else
@@ -276,18 +280,18 @@ struct fib6_table *fib6_new_table(u32 id
 
 struct fib6_table *fib6_get_table(u32 id)
 {
-	return &fib6_main_tbl;
+	return fib6_main_tbl;
 }
 
 struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
 				   pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(&fib6_main_tbl, fl, flags);
+	return (struct dst_entry *) lookup(fib6_main_tbl, fl, flags);
 }
 
 static void __init fib6_tables_init(void)
 {
-	fib6_link_table(&fib6_main_tbl);
+	fib6_link_table(fib6_main_tbl);
 }
 
 #endif

-- 
