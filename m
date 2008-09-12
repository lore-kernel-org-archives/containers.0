From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][RFC] memory.min_usage again
Date: Fri, 12 Sep 2008 18:46:30 +0900
Message-ID: <20080912184630.35773102.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071204040934.44AF41D0BA3@siro.lan>
	<20080910084443.8F7D85ACE@siro.lan>
	<48C7E87F.2080706@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C7E87F.2080706-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 10 Sep 2008 08:32:15 -0700
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> YAMAMOTO Takashi wrote:
> > hi,
> > 
> >> hi,
> >>
> >> here's a patch to implement memory.min_usage,
> >> which controls the minimum memory usage for a cgroup.
> >>
> >> it works similarly to mlock;
> >> global memory reclamation doesn't reclaim memory from
> >> cgroups whose memory usage is below the value.
> >> setting it too high is a dangerous operation.
> >>
> 
> Looking through the code I am a little worried, what if every cgroup is below
> minimum value and the system is under memory pressure, do we OOM, while we could
> have easily reclaimed?
> 
> I would prefer to see some heuristics around such a feature, mostly around the
> priority that do_try_to_free_pages() to determine how desperate we are for
> reclaiming memory.
> 
Taking "priority" of memory reclaim path into account is good.

==
static unsigned long shrink_inactive_list(unsigned long max_scan,
                        struct zone *zone, struct scan_control *sc,
                        int priority, int file)
==
How about ignore min_usage if "priority < DEF_PRIORITY - 2" ?


Thanks,
-Kame
