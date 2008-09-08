From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 17/33] netns ct: final init_net tweaks
Date: Mon,  8 Sep 2008 07:02:54 +0400
Message-ID: <1220842990-30500-17-git-send-email-adobriyan__34353.1276601881$1220843696$gmane$org@gmail.com>
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

Add checks for init_net to not create kmem caches twice and so on.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b55944e..52d0663 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1016,7 +1016,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
    supposed to kill the mall. */
 void nf_conntrack_cleanup(struct net *net)
 {
-	rcu_assign_pointer(ip_ct_attach, NULL);
+	if (net_eq(net, &init_net))
+		rcu_assign_pointer(ip_ct_attach, NULL);
 
 	/* This makes sure all current packets have passed through
 	   netfilter framework.  Roll on, two-stage module
@@ -1035,16 +1036,21 @@ void nf_conntrack_cleanup(struct net *net)
 	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
 		schedule();
 
-	rcu_assign_pointer(nf_ct_destroy, NULL);
+	if (net_eq(net, &init_net)) {
+		rcu_assign_pointer(nf_ct_destroy, NULL);
 
-	kmem_cache_destroy(nf_conntrack_cachep);
+		kmem_cache_destroy(nf_conntrack_cachep);
+	}
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 
-	nf_conntrack_acct_fini();
+	if (net_eq(net, &init_net))
+		nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini(net);
-	nf_conntrack_helper_fini();
-	nf_conntrack_proto_fini();
+	if (net_eq(net, &init_net)) {
+		nf_conntrack_helper_fini();
+		nf_conntrack_proto_fini();
+	}
 }
 
 struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced)
@@ -1134,22 +1140,28 @@ int nf_conntrack_init(struct net *net)
 	int max_factor = 8;
 	int ret;
 
-	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
-	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
-	if (!nf_conntrack_htable_size) {
-		nf_conntrack_htable_size
-			= (((num_physpages << PAGE_SHIFT) / 16384)
-			   / sizeof(struct hlist_head));
-		if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
-			nf_conntrack_htable_size = 16384;
-		if (nf_conntrack_htable_size < 32)
-			nf_conntrack_htable_size = 32;
-
-		/* Use a max. factor of four by default to get the same max as
-		 * with the old struct list_heads. When a table size is given
-		 * we use the old value of 8 to avoid reducing the max.
-		 * entries. */
-		max_factor = 4;
+	if (net_eq(net, &init_net)) {
+		/*
+		 * Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
+		 * machine has 512 buckets. >= 1GB machines have 16384 buckets.
+		 */
+		if (!nf_conntrack_htable_size) {
+			nf_conntrack_htable_size
+				= (((num_physpages << PAGE_SHIFT) / 16384)
+						/ sizeof(struct hlist_head));
+			if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
+				nf_conntrack_htable_size = 16384;
+			if (nf_conntrack_htable_size < 32)
+				nf_conntrack_htable_size = 32;
+
+			/*
+			 * Use a max. factor of four by default to get the same
+			 * max as with the old struct list_heads. When a table
+			 * size is given we use the old value of 8 to avoid
+			 * reducing the max. entries.
+			 */
+			max_factor = 4;
+		}
 	}
 	atomic_set(&net->ct.count, 0);
 	ret = nf_conntrack_ecache_init(net);
@@ -1163,59 +1175,66 @@ int nf_conntrack_init(struct net *net)
 	}
 	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
-	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
+	if (net_eq(net, &init_net)) {
+		nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
-	printk("nf_conntrack version %s (%u buckets, %d max)\n",
-	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
-	       nf_conntrack_max);
+		printk("nf_conntrack version %s (%u buckets, %d max)\n",
+			NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
+			nf_conntrack_max);
 
-	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
+		nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
 						0, 0, NULL);
-	if (!nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		goto err_free_hash;
-	}
+		if (!nf_conntrack_cachep) {
+			printk(KERN_ERR "Unable to create nf_conn slab cache\n");
+			goto err_free_hash;
+		}
 
-	ret = nf_conntrack_proto_init();
-	if (ret < 0)
-		goto err_free_conntrack_slab;
+		ret = nf_conntrack_proto_init();
+		if (ret < 0)
+			goto err_free_conntrack_slab;
+	}
 
 	ret = nf_conntrack_expect_init(net);
 	if (ret < 0)
 		goto out_fini_proto;
 
-	ret = nf_conntrack_helper_init();
-	if (ret < 0)
-		goto out_fini_expect;
+	if (net_eq(net, &init_net)) {
+		ret = nf_conntrack_helper_init();
+		if (ret < 0)
+			goto out_fini_expect;
 
-	ret = nf_conntrack_acct_init();
-	if (ret < 0)
-		goto out_fini_helper;
+		ret = nf_conntrack_acct_init();
+		if (ret < 0)
+			goto out_fini_helper;
 
-	/* For use by REJECT target */
-	rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
-	rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
+		/* For use by REJECT target */
+		rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
+		rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
 
-	/* Set up fake conntrack:
-	    - to never be deleted, not in any hashes */
+		/* Set up fake conntrack:
+		   - to never be deleted, not in any hashes */
 #ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net = &init_net;
+		nf_conntrack_untracked.ct_net = &init_net;
 #endif
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
-	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+		atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
+		/*  - and look it like as a confirmed connection */
+		set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+	}
 
 	return ret;
 
 out_fini_helper:
-	nf_conntrack_helper_fini();
+	if (net_eq(net, &init_net))
+		nf_conntrack_helper_fini();
 out_fini_expect:
 	nf_conntrack_expect_fini(net);
 out_fini_proto:
-	nf_conntrack_proto_fini();
+	if (net_eq(net, &init_net))
+		nf_conntrack_proto_fini();
 err_free_conntrack_slab:
-	kmem_cache_destroy(nf_conntrack_cachep);
+	if (net_eq(net, &init_net))
+		kmem_cache_destroy(nf_conntrack_cachep);
 err_free_hash:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 6a09200..be08c87 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -563,12 +563,14 @@ int nf_conntrack_expect_init(struct net *net)
 {
 	int err = -ENOMEM;
 
-	if (!nf_ct_expect_hsize) {
-		nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
-		if (!nf_ct_expect_hsize)
-			nf_ct_expect_hsize = 1;
+	if (net_eq(net, &init_net)) {
+		if (!nf_ct_expect_hsize) {
+			nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
+			if (!nf_ct_expect_hsize)
+				nf_ct_expect_hsize = 1;
+		}
+		nf_ct_expect_max = nf_ct_expect_hsize * 4;
 	}
-	nf_ct_expect_max = nf_ct_expect_hsize * 4;
 
 	net->ct.expect_count = 0;
 	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
@@ -576,11 +578,13 @@ int nf_conntrack_expect_init(struct net *net)
 	if (net->ct.expect_hash == NULL)
 		goto err1;
 
-	nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
+	if (net_eq(net, &init_net)) {
+		nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
 					sizeof(struct nf_conntrack_expect),
 					0, 0, NULL);
-	if (!nf_ct_expect_cachep)
-		goto err2;
+		if (!nf_ct_expect_cachep)
+			goto err2;
+	}
 
 	err = exp_proc_init(net);
 	if (err < 0)
@@ -589,7 +593,8 @@ int nf_conntrack_expect_init(struct net *net)
 	return 0;
 
 err3:
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net_eq(net, &init_net))
+		kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
@@ -600,7 +605,8 @@ err1:
 void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net_eq(net, &init_net))
+		kmem_cache_destroy(nf_ct_expect_cachep);
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
