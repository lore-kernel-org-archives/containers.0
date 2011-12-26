From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/6] memcg: fix unused variable warning
Date: Mon, 26 Dec 2011 15:50:08 +0900
Message-ID: <20111226155008.9ab21c6f.kamezawa.hiroyu__14780.4408487447$1324882291$gmane$org@jp.fujitsu.com>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
	<20111226152531.e0335ec4.kamezawa.hiroyu@jp.fujitsu.com>
	<20111226063652.GA13273@shutemov.name>
	<20111226154252.d3621532.kamezawa.hiroyu@jp.fujitsu.com>
	<20111226064734.GA13355@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111226064734.GA13355-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 26 Dec 2011 08:47:34 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> On Mon, Dec 26, 2011 at 03:42:52PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 26 Dec 2011 08:36:52 +0200
> > "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> > 
> > > On Mon, Dec 26, 2011 at 03:25:31PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Sat, 24 Dec 2011 05:00:14 +0200
> > > > "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> > > > 
> > > > > From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > > > > 
> > > > > mm/memcontrol.c: In function ‘memcg_check_events’:
> > > > > mm/memcontrol.c:784:22: warning: unused variable ‘do_numainfo’ [-Wunused-variable]
> > > > > 
> > > > > Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > > > 
> > > > Hmm ? Doesn't this fix cause a new Warning ?
> > > > 
> > > > mm/memcontrol.c: In function ?memcg_check_events?:
> > > > mm/memcontrol.c:789: warning: ISO C90 forbids mixed declarations and code
> > > 
> > > I don't see how. The result code is:
> > > 
> > > 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
> > > 						MEM_CGROUP_TARGET_THRESH))) {
> > > 		bool do_softlimit;
> > > 
> > > #if MAX_NUMNODES > 1
> > > 		bool do_numainfo;
> > > 		do_numainfo = mem_cgroup_event_ratelimit(memcg,
> > > 						MEM_CGROUP_TARGET_NUMAINFO);
> > > #endif
> > > 		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> > > 						MEM_CGROUP_TARGET_SOFTLIMIT);
> > > 		preempt_enable();
> > > 
> > > 		mem_cgroup_threshold(memcg);
> > > 
> > 
> > Ah. please see linux-next and rebase onto that.
> 
> The patchset is on top of next-20111222. Have I missed something?
> 
Ah, ok. my mistake. Sorry.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
