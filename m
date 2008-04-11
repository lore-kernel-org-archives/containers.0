From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/14 (3 subsets)] Make tuns and vlans devices work
 per-net.
Date: Fri, 11 Apr 2008 11:11:31 -0700 (PDT)
Message-ID: <20080411.111131.132418112.davem@davemloft.net>
References: <47FE2AD4.9080609@openvz.org>
	<47FF86FE.7030209@fr.ibm.com>
	<47FF8A65.7030605@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47FF8A65.7030605@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: xemul@openvz.org
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org, den@openvz.org, containers@lists.osdl.org, benjamin.thery@bull.net
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 11 Apr 2008 19:57:25 +0400

> I think, that core kernel code and protocols should/may use the struct 
> net, while modules are better to work via generic pointers. However, if
> the generic pointers cause noticeable performance degradation, then we
> may ask Dave to bear with on-net members :)

This sounds fine.
