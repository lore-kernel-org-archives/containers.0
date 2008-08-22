From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 22 Aug 2008 15:30:28 +0400
Message-ID: <20080822113028.GB2321__27280.7861598723$1219404711$gmane$org@x200.localdomain>
References: <20080821220432.GT31136@x200.localdomain>
	<alpine.LNX.1.10.0808211903000.20596@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808211903000.20596-vVwEwcwQeYFPkBl3ERsXe1l1cybopEuJUBSOeVevoDU@public.gmane.org>
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

On Thu, Aug 21, 2008 at 07:06:37PM -0400, Jan Engelhardt wrote:
> On Thursday 2008-08-21 18:04, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
> 
> >Make untracked conntrack per-netns.
> 
> Why? It does not store any useful information per se, it is
> merely used to add a third type of ct, iow:
> 
> (a) ct==NULL
> (b) ct!=NULL
> (c) ct==&untracked
> 
> mmap(2)'s return value for example has something similar:
> 
> (a) mmap(...)==NULL
> (b) mmap(...)==MMAP_FAILED
> (c) otherwise
> 
> The untracked ct is a singleton, and should stay one, unless
> there are further reasons not to do so.

We wait for untracked ct refcount to drop to 1 back:

	/* wait until all references to nf_conntrack_untracked are dropped */
	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
		schedule();

Consequently it should be one per netns, otherwise netns A can prevent
netns B from stopping.
