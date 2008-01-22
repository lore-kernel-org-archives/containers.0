From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6 net-2.6.25] Provide correct namespace on IPv4
 packet input path.
Date: Mon, 21 Jan 2008 17:35:19 -0800 (PST)
Message-ID: <20080121.173519.222926081.davem@davemloft.net>
References: <4794B10E.7010703@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4794B10E.7010703@sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@sw.ru
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@sw.ru>
Date: Mon, 21 Jan 2008 17:49:50 +0300

> This patchset sequentially adds namespace parameter to fib_lookup and
> inetdev_by_index. After that it is possible to pass network namespace
> from input packet to routing engine.
> 
> Output path is much more intrusive and will be sent separately.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

All 6 patches applied, thanks.
