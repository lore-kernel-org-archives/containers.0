From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] multiple namespaces in the all dst_ifdown
 routines
Date: Fri, 07 Dec 2007 00:39:14 -0800 (PST)
Message-ID: <20071207.003914.143266434.davem@davemloft.net>
References: <20071206121746.GA17899@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071206121746.GA17899@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 15:17:46 +0300

> move dst entries to a namespace loopback to catch refcounting leaks.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
