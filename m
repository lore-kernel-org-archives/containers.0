From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/14 (3 subsets)] Make tuns and vlans devices work per-net.
Date: Fri, 11 Apr 2008 17:42:54 +0200
Message-ID: <47FF86FE.7030209@fr.ibm.com>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Linux Netdev List <netdev@vger.kernel.org>, Denis Lunev <den@openvz.org>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Hi, guys.
> 
> I've recently sent a TUN devices virtualization, but it was rejected
> by Dave, since the struct net is becoming a dumping ground.
> 
> I agree with him - we really need some way to register on-net data
> dynamically. That's my view of such a thing and two examples of how
> to use it (TUN and VLAN devices virtualization).
> 
> If this will be found good, I'll send these sets to David, hoping he
> will accept them :)

Pavel,

seems to be a smart solution :)

I am just afraid with the performances when the network resources are to 
be accessed in the fast path like a routing table (that seems not to be 
the case for tun and vlan). Shall we assume the fast path should always 
go to struct net and non critical path can go to net_generic ?

   -- Daniel
