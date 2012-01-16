From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [RESEND, PATCH 4/6] memcg: fix broken boolean expression
Date: Mon, 16 Jan 2012 13:54:16 +0200
Message-ID: <20120116115416.GA25687__7764.91884976185$1326714851$gmane$org@shutemov.name>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
	<1325883472-5614-4-git-send-email-kirill@shutemov.name>
	<20120109140404.GG3588@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120109140404.GG3588-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 09, 2012 at 03:04:04PM +0100, Johannes Weiner wrote:
> On Fri, Jan 06, 2012 at 10:57:50PM +0200, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > 
> > action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> 
> I think you don't need to actually CC stable via email.  If you
> include that tag, they will pick it up once the patch hits mainline.

I don't think it's a problem for stable@.

> 
> The changelog is too terse, doubly so for a patch that should go into
> stable.  How is the code supposed to work?  What are the consequences
> of the bug?

Is it enough?

---

From fe1c2f2dc1abf63cce12017e2d9031cf67f0a161 Mon Sep 17 00:00:00 2001
From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Date: Sat, 24 Dec 2011 04:12:53 +0200
Subject: [PATCH 4/6] memcg: fix broken boolean expression

action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.

We should return at the point if CPU doesn't go away. Otherwise drain
all counters and stocks from the CPU.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
---
 mm/memcontrol.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4ed6737..513ae04 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2095,9 +2095,11 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
 		return NOTIFY_OK;
 	}
 
-	if ((action != CPU_DEAD) || action != CPU_DEAD_FROZEN)
+	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
 
+	/* CPU goes away */
+
 	for_each_mem_cgroup(iter)
 		mem_cgroup_drain_pcp_counter(iter, cpu);
 
-- 
1.7.8.3

-- 
 Kirill A. Shutemov
