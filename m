From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/6] netns brnetfilter: per-netns ebtables
Date: Mon, 13 Oct 2008 11:35:01 +0400
Message-ID: <20081013073501.GB4254__10533.2052488395$1223883279$gmane$org@x200.localdomain>
References: <20080821221943.GO31136@x200.localdomain>
	<20081013070347.GA3813@elte.hu> <20081013070940.GA6340@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081013070940.GA6340-X9Un+BFzKDI@public.gmane.org>
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
Cc: kaber-ghPcaIaJnjo@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Oct 13, 2008 at 09:09:40AM +0200, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:
> 
> > 
> > * adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > 
> > > * make registered ebtables list per-netns
> > > * for that, duplicate table at the very beginning of register,
> > >   we can't add one table to multiple lists.
> > > * propagate netns from userspace socket down to iterators over list,
> > > * register individual modules only in init_net for a minute.
> > > 
> > > Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > 
> > -tip testing found this build failure, config attached:
> > 
> > ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> > ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> > ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> > ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> > ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> > ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> > make[1]: *** [__modpost] Error 1
> > make: *** [modules] Error 2
> 
> i had a quick look and i think the problem is that CONFIG_BRIDGE=m so 
> the ebt_unregister_table symbol is not available to modules properly. 
> But i've not dug down deep.

Ouch, how they managed to get there?

Anyway, ebtables were rewritten to work via xtables, so these patches
are most certainly obsolete, better drop and forget. I should post new
version soon.
