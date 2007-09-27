From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] proper comment for loopback initialization order
Date: Thu, 27 Sep 2007 12:03:45 -0700 (PDT)
Message-ID: <20070927.120345.112249695.davem@davemloft.net>
References: <20070927122527.GA10972@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070927122527.GA10972@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: dev@openvz.org, devel@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 27 Sep 2007 16:25:27 +0400

> Subject: [PATCH] proper comment for loopback initialization order
> From: "Denis V. Lunev" <den@openvz.org>
> To: davem@davemloft.net
> Cc: dev@openvz.org, devel@openvz.org, netdev@vger.kernel.org,
> 	containers@lists.osdl.org
> Date: Thu, 27 Sep 2007 16:25:27 +0400
> Sender:  <den@sw.ru>
> User-Agent: Mutt/1.5.16 (2007-06-09)
> 
> Loopback device is special. It should be initialized at the very
> beginning.  Initialization order has been changed by
> Eric W. Biederman <ebiederm@xmission.com> and this change is non-obvious
> and important enough to add proper comment.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, but I had to fix the coding style of your comment,
please do it like this in the future:

/* Loopback is special. It should be initialized before any other network
 * device and network subsystem.
 */

Thanks.
