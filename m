From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for
 include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 00:47:42 -0700 (PDT)
Message-ID: <20080326.004742.92048899.davem@davemloft.net>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1206517259-29152-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, xemul@openvz.org, yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 26 Mar 2008 10:40:58 +0300

> Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
> ([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
> breaks compilation with CONFIG_NET_NS set.
> 
> Fix the typo.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.

Too bad allmodconfig doesn't enable things which are y/n only.
