From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-2.6.26] [NETNS]: Compilation warnings under
 CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 00:48:40 -0700 (PDT)
Message-ID: <20080326.004840.24485682.davem@davemloft.net>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
	<1206517259-29152-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1206517259-29152-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, xemul@openvz.org, yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 26 Mar 2008 10:40:59 +0300

> Recent commits from YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> have been introduced a several compilation warnings
> 'assignment discards qualifiers from pointer target type'
> due to extra const modifier in the inline call parameters of
> {dev|sock|twsk}_net_set.
> 
> Drop it.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Also applied, thanks a lot.
