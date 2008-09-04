From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 07/38] netns ct: add ->ct_net -- pointer from conntrack
	to netns
Date: Thu, 04 Sep 2008 18:18:22 +0200
Message-ID: <48C00A4E.5060103__252.046835567121$1220545293$gmane$org@trash.net>
References: <20080821215934.GG31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821215934.GG31136-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
> Conntrack (struct nf_conn) gets pointer to netns: ->ct_net -- netns in which
> it was created. It comes from netdevice.
> 
> ->ct_net is write-once field.
> 
> Every conntrack in system has ->ct_net initialized, no exceptions.
> 
> ->ct_net doesn't pin netns: conntracks are recycled after timeouts and
> pinning background traffic will prevent netns from even starting shutdown
> sequence.
> 
> Right now every conntrack is created in init_net.

Applied and fixed up another overly long line.

> +		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);

This will probably cause clashes later, please don't
do that.
