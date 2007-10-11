From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] cleanup 3rd argument in netlink_sendskb
Date: Wed, 10 Oct 2007 21:14:09 -0700 (PDT)
Message-ID: <20071010.211409.97289459.davem@davemloft.net>
References: <20071005144623.GA7085@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071005144623.GA7085@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, devel@openvz.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 5 Oct 2007 18:46:23 +0400

> netlink_sendskb does not use third argument. Clean it and save a couple of
> bytes.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied.
