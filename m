From: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] inetpeer: add namespace support for inetpeer
Date: Tue, 5 Jun 2012 07:52:08 +0200
Message-ID: <20120605055208.GA27795__22445.1925758787$1338876862$gmane$org@secunet.com>
References: <1338863012-4902-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1338867619.2760.1980.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1338867619.2760.1980.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 05, 2012 at 05:40:19AM +0200, Eric Dumazet wrote:
> On Tue, 2012-06-05 at 10:23 +0800, Gao feng wrote:
> >  
> > +static int __net_init inetpeer_net_init(struct net *net)
> > +{
> > +
> > +	net->ipv4.peers = kmemdup(&v4_peers,
> > +				  sizeof(v4_peers),
> > +				  GFP_KERNEL);
> 
> kzalloc(), and init ->root to peer_avl_empty_rcu
> 
> > +	if (net->ipv4.peers == NULL)
> > +		return -1;

...and return -ENOMEM if memory allocation fails.
