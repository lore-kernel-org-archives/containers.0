From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fib_rules ordering fixes.
Date: Fri, 07 Nov 2008 22:54:01 -0800 (PST)
Message-ID: <20081107.225401.213983613.davem@davemloft.net>
References: <20081105.160047.174722021.davem@davemloft.net>
	<m14p2l0zyu.fsf@frodo.ebiederm.org>
	<m1y6zwzx4r.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1y6zwzx4r.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org, xemul@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Nov 2008 07:34:28 -0800

> 
> We need to setup the network namespace state before we register
> the notifier.  Otherwise if a network device is already registered
> we get a nasty NULL pointer dereference.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Applied.
