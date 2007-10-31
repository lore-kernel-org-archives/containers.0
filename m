From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][ for -mm] memory cgroup enhancements take3 [1/9] fix
 try_to_free_mem_cgroup_pages() numa handling
Date: Wed, 31 Oct 2007 14:36:56 +0900
Message-ID: <20071031143656.b004c164.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071030201206.86a510e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20071030201431.56f6b242.kamezawa.hiroyu@jp.fujitsu.com>
	<1193765494.24087.282.camel@localhost>
	<472777B0.3020405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <472777B0.3020405-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 30 Oct 2007 23:58:00 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> Dave Hansen wrote:
> > On Tue, 2007-10-30 at 20:14 +0900, KAMEZAWA Hiroyuki wrote:
> >> -       for_each_online_node(node) {
> >> -               zones =
> >> NODE_DATA(node)->node_zonelists[target_zone].zones;
> >> -               if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
> >> +       zones = NODE_DATA(node)->node_zonelists[target_zone].zones;
> >> +       if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
> >>                         return 1;
> >> -       }
> >>         return 0;
> >>  }
> >>  #endif 
> > 
> > Am I reading the diff wrong, or is that return indented too far?
> > 
> > -- Dave
> 
> Good catch! It is indeed indented one additional tab away from where it
> should be.

Thanks, I'll check my tree.

-Kame
