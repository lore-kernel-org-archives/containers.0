From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] Remove ip_fib_local_table and ip_fib_main_table
 defines
Date: Fri, 07 Dec 2007 00:46:21 -0800 (PST)
Message-ID: <20071207.004621.13302830.davem@davemloft.net>
References: <20071206145825.GA22435@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071206145825.GA22435@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org, ebiederm@xmission.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 17:58:25 +0300

> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> There are only 2 users and it doesn't hurt to call fib_get_table
> instead, and it makes it easier to make the fib network namespace
> aware.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
