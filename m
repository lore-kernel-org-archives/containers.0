From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Sun, 24 Aug 2008 14:43:13 +0400
Message-ID: <20080824104313.GA3010__20833.4057279446$1219574725$gmane$org@x200.localdomain>
References: <20080821220432.GT31136@x200.localdomain>
	<alpine.LNX.1.10.0808211903000.20596@fbirervta.pbzchgretzou.qr>
	<20080822113028.GB2321@x200.localdomain>
	<alpine.LNX.1.10.0808232034380.8996@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808232034380.8996-vVwEwcwQeYFPkBl3ERsXe1l1cybopEuJUBSOeVevoDU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Aug 23, 2008 at 08:35:07PM -0400, Jan Engelhardt wrote:
> 
> On Friday 2008-08-22 07:30, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
> >
> >We wait for untracked ct refcount to drop to 1 back:
> >
> >	/* wait until all references to nf_conntrack_untracked are dropped */
> >	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
> >		schedule();
> >
> >Consequently it should be one per netns, otherwise netns A can prevent
> >netns B from stopping.
> >
> 
> But nf_conntrack_cleanup is not per netns, is it?

That's because nf_conntrack_cleanup() is _code_.

If netns A actively uses NOTRACK, untracked ct refcount will be bumped.
And netns B which haven't used NOTRACK at all will wait for netns A to
stop using NOTRACK potentially indefinitely.

> At least I do not think it should be.
