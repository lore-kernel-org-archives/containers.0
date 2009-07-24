From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] veth: don't free priv->status until dev->destructor
 (v2)
Date: Fri, 24 Jul 2009 12:46:14 -0700
Message-ID: <20090724124614.6acc5054@nehalam>
References: <20090626162418.GA24828@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090626162418.GA24828@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, Sachin Sant <sachinp@in.ibm.com>, netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, matthltc@us.ibm.com, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Fri, 26 Jun 2009 11:24:18 -0500
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> Based on the commit msg on ae0e8e82205c903978a79ebf5e31c670b61fa5b4, it looks

>  	ether_setup(dev);
> @@ -306,7 +320,7 @@ static void veth_setup(struct net_device *dev)
>  	dev->netdev_ops = &veth_netdev_ops;
>  	dev->ethtool_ops = &veth_ethtool_ops;
>  	dev->features |= NETIF_F_LLTX;
> -	dev->destructor = free_netdev;
> +	dev->destructor = veth_dev_free;
>

This is still going to oops if sysfs statistics referenced
after module unload because module is unloaded (code is gone)
and veth_dev_free no longer exists.

I'll respin the original patch (using free_netdev) and fix
the statistics complaint.
