From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [IPV4] Reduce whitespaces in fib_rules.h.
Date: Thu, 13 Dec 2007 06:50:45 -0800 (PST)
Message-ID: <20071213.065045.189743239.davem@davemloft.net>
References: <20071213141842.GA9939@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071213141842.GA9939@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 13 Dec 2007 17:18:42 +0300

> There are to many spaces between type and function name in the declaration
> of fib rules manipulation routines. Eat them and save a couple of lines.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

This is just noise and serves nothing other than to invite potential
patch conflicts which makes development harder.

If you happened to be changing these for other reasons, I'd say OK,
but not like this.
