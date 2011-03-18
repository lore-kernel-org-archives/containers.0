From: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/3] memcg: mark init_section_page_cgroup() properly
Date: Fri, 18 Mar 2011 21:54:13 +0900
Message-ID: <1300452855-10194-1-git-send-email-namhyung__31755.661746911$1300453008$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The commit ca371c0d7e23 ("memcg: fix page_cgroup fatal error
in FLATMEM") removes call to alloc_bootmem() in the function
so that it can be marked as __meminit to reduce memory usage
when MEMORY_HOTPLUG=n.

Signed-off-by: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 mm/page_cgroup.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5bffada7cde1..2d1a0fa01d7b 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -105,8 +105,7 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return section->page_cgroup + pfn;
 }
 
-/* __alloc_bootmem...() is protected by !slab_available() */
-static int __init_refok init_section_page_cgroup(unsigned long pfn)
+static int __meminit init_section_page_cgroup(unsigned long pfn)
 {
 	struct mem_section *section = __pfn_to_section(pfn);
 	struct page_cgroup *base, *pc;
-- 
1.7.4
