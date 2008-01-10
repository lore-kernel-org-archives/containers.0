From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [ATM] Simplify /proc/net/atm/arp opening
Date: Thu, 10 Jan 2008 03:52:44 -0800 (PST)
Message-ID: <20080110.035244.250316041.davem@davemloft.net>
References: <20080110113044.GA16213@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080110113044.GA16213@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: dlezcano@fr.ibm.com, xemul@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 10 Jan 2008 14:30:44 +0300

> The iterator state->ns.neigh_sub_iter initialization is moved from
> arp_seq_open to clip_seq_start for convinience. This should not be a problem
> as the iterator will be used only after the seq_start callback.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.

