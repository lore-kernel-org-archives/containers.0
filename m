From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [IPV4] Thresholds in fib_trie.c are used as
 consts, so make them const.
Date: Thu, 13 Dec 2007 09:48:14 -0800 (PST)
Message-ID: <20071213.094814.208890787.davem@davemloft.net>
References: <20071213080618.GA6530@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071213080618.GA6530@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 13 Dec 2007 11:06:18 +0300

> [IPV4] Thresholds in fib_trie.c are used as consts, so make them const.
> 
> There are several thresholds for trie fib hash management. They are used
> in the code as a constants. Make them constants from the compiler point of
> view.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks for fixing this patch up.
