From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Date: Tue, 11 Mar 2008 18:03:20 +0900
Message-ID: <47D64AD8.5020909@mxp.nes.nec.co.jp>
References: <47D16004.7050204@openvz.org>	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>	<47D63FBC.1010805@openvz.org>
	<20080311173225.937935eb.kamezawa.hiroyu@jp.fujitsu.com>
	<47D6451A.7090807@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D6451A.7090807-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi.

> No. The mem_counter_N_limit is the limit for all the memory, that the
> Nth group consumes. This includes the RSS, page cache and swap for this
> group and all the child groups. Since RSS and page cache are accounted
> together, this limit tracks the sum of (memory + swap) values over the
> subtree started at the given group.
> 
It seems a bit confusing for me, because current memcg manages
only RSS and page cache, not swap.


>>>> IMO, a parent's usage is just sum of all childs'.
>>>> And, historically, memory overcommit is done agaist "memory usage + swap".
>>>>
>>>> How about this ?
>>>>  <mem_counter_top, swap_counter_top>
>>>> 	<mem_counter_sub, swap_counter_sub>
>>>> 	<mem_counter_sub, swap_counter_sub>
>>>> 	<mem_counter_sub, swap_counter_sub>
>>>>
>>>>    mem_counter_top.usage == sum of all mem_coutner_sub.usage
>>>>    swap_counter_sub.usage = sum of all swap_counter_sub.usage

I prefer Kamezawa-san's idea.


Thanks,
Daisuke Nishimura.
