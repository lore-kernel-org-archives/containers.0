From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 17/33] netns ct: final init_net tweaks
Date: Sat, 27 Sep 2008 04:00:00 +0400
Message-ID: <20080927000000.GB10489__1391.67862148515$1222473587$gmane$org@x200.localdomain>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-17-git-send-email-adobriyan@gmail.com>
	<48C623CA.9060803@trash.net>
	<20080909073245.GA7307@x200.localdomain>
	<48C62B1C.7070104@trash.net>
	<20080913104515.GA7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080913104515.GA7440-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Sep 13, 2008 at 02:45:15PM +0400, Alexey Dobriyan wrote:
> On Tue, Sep 09, 2008 at 09:51:56AM +0200, Patrick McHardy wrote:
> > Alexey Dobriyan wrote:
> >> On Tue, Sep 09, 2008 at 09:20:42AM +0200, Patrick McHardy wrote:
> >>> Having multiple of these net_eq checks per function (14 total) is
> >>> not a very nice way to do this.
> >>
> >> Yep, I was just afraid of some subtle ordering rules and to keep
> >> potential init_net breakage to minimum.
> >
> > Me too, but I still prefer to do it properly once.
> >
> >>> How about splitting the code into a netns and a global part instead?
> >>
> >> Prebably they aren't strict at all.
> >
> > Not particulary. For cleanup a three stage approach with
> >
> > 1. init_net deactivation (ip_ct_attach = NULL)
> > 2. generic netns cleanup
> > 3. init_net specific final cleanup (slab cache, nf_conntrack_cachep,
> >    accounting, helpers, protocols, ...)
> >
> > should work fine.
> >
> > The initialization should be OK with just a init_net part
> > and a generic netns part.
> 
> Ugh, I'm still finding the least ugly way to put init_net checks, and
> it's better to do it at the very end.
> 
> So, slight reordering.
> 
> See per-netns statistics, nf_conntrack_count, nf_conntrack_checksum,
> nf_conntrack_log_invalid and accounting.
> 
> The rest (SIP, H323, GRE, PPTP, per-netns NAT) remains the same and can
> be applied independently of init_net checks.

Ping!

I've just sent patch which adds init_net checks in somewhat nicer way.

Please, review and apply the rest.
