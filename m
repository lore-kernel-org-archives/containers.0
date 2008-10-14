From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [bug, -git] ERROR:
	"ebt_unregister_table"	[net/bridge/netfilter/ebtable_nat.ko] undefined
Date: Tue, 14 Oct 2008 13:51:19 +0200
Message-ID: <48F487B7.3070004__19147.294216282$1223985873$gmane$org@trash.net>
References: <20080821221943.GO31136@x200.localdomain>
	<20081013070347.GA3813@elte.hu> <20081013070940.GA6340@elte.hu>
	<20081013073501.GB4254@x200.localdomain>
	<20081014103005.GA19420@elte.hu> <48F47BB9.9090902@trash.net>
	<20081014114806.GA20480@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081014114806.GA20480-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: kaber-ghPcaIaJnjo@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Ingo Molnar wrote:
> * Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> wrote:
> 
>> Ingo Molnar wrote:
>>> i think you misunderstood my report. This is about latest upstream -git 
>>> being broken:
>>>
>>> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
>>> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
>>> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
>>> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
>>> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
>>> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
>>> make[1]: *** [__modpost] Error 1
>>> make: *** [modules] Error 2
>>>
>> Does this patch fix it?
> 
> yeah, the module build now succeeds fine with that config, thanks 
> Patrick!
> 
> Tested-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

Thanks Ingo, I'll send it upstream tonight.
