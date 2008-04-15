From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 3/14][TUN]: Introduce the tun_net structure.
Date: Tue, 15 Apr 2008 14:31:45 +0400
Message-ID: <48048411.5030506@openvz.org>
References: <47FE2AD4.9080609@openvz.org>	<47FE2CF0.6080100@openvz.org> <20080415.004417.172551569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080415.004417.172551569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com, den@openvz.org, containers@lists.osdl.org, benjamin.thery@bull.net
List-Id: containers.vger.kernel.org

David Miller wrote:
> Pavel, please respin these patches since I applied the updated
> version of patches 1 and 2 which added the generic netns bits.

Thank you, David! I will do it today.

Are you willing to look at vlans and ip tunnels (ipip, gre, sit) as 
well? This will be 6 sets ~7 patches each.

> Thanks!
> 

