From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: 2.6.38 containers bug: Infinite loop in
	/proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 02:01:20 -0700 (PDT)
Message-ID: <20110330.020120.02272125.davem__8339.76391372762$1301475755$gmane$org@davemloft.net>
References: <4D92E9DC.3070405@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D92E9DC.3070405-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Wed, 30 Mar 2011 03:29:16 -0500

> In the host context a find on /proc completes, but inside an lxc
> container a find on /proc never completes, due to the endless loop in
> the title.  (It's not a symlink, it seems to be a cross linked directory.)
> 
> This is vanilla 2.6.38, I can attach my .config if you think it'd help.
>  (The container's the lxc debian sid template but that's probably not
> relevant.)

Please CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org when a bug might be related to
networking, as is obviously the case here.

This bug should be fixed by the following patch:

--------------------
commit 9d2a8fa96a44ba242de3a6f56acaef7a40a97b97
Author: Eric W. Biederman <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Date:   Mon Mar 21 18:23:34 2011 -0700

    net ipv6: Fix duplicate /proc/sys/net/ipv6/neigh directory entries.
    
    When I was fixing issues with unregisgtering tables under /proc/sys/net/ipv6/neigh
    by adding a mount point it appears I missed a critical ordering issue, in the
    ipv6 initialization.  I had not realized that ipv6_sysctl_register is called
    at the very end of the ipv6 initialization and in particular after we call
    neigh_sysctl_register from ndisc_init.
    
    "neigh" needs to be initialized in ipv6_static_sysctl_register which is
    the first ipv6 table to initialized, and definitely before ndisc_init.
    This removes the weirdness of duplicate tables while still providing a
    "neigh" mount point which prevents races in sysctl unregistering.
    
    This was initially reported at https://bugzilla.kernel.org/show_bug.cgi?id=31232
    Reported-by: sunkan-Q0DX0+l8+Is@public.gmane.org
    Signed-off-by: Eric W. Biederman <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7cb65ef..6dcf5e7 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -17,6 +17,16 @@
 
 static struct ctl_table empty[1];
 
+static ctl_table ipv6_static_skeleton[] = {
+	{
+		.procname	= "neigh",
+		.maxlen		= 0,
+		.mode		= 0555,
+		.child		= empty,
+	},
+	{ }
+};
+
 static ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "route",
@@ -37,12 +47,6 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "neigh",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= empty,
-	},
 	{ }
 };
 
@@ -160,7 +164,7 @@ static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
+	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, ipv6_static_skeleton);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
