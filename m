From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [IPV6] Always pass a valid nl_info to
 inet6_rt_notify.
Date: Thu, 13 Dec 2007 09:45:35 -0800 (PST)
Message-ID: <20071213.094535.04530080.davem@davemloft.net>
References: <20071213135854.GA9691@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071213135854.GA9691@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 13 Dec 2007 16:58:54 +0300

> [IPV6] Always pass a valid nl_info to inet6_rt_notify.
> 
> This makes the code in the inet6_rt_notify more straightforward and provides
> groud for namespace passing.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks!
