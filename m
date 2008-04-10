From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/14 (3 subsets)] Make tuns and vlans devices work per-net.
Date: Thu, 10 Apr 2008 18:57:24 +0400
Message-ID: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: Linux Netdev List <netdev@vger.kernel.org>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

Hi, guys.

I've recently sent a TUN devices virtualization, but it was rejected
by Dave, since the struct net is becoming a dumping ground.

I agree with him - we really need some way to register on-net data
dynamically. That's my view of such a thing and two examples of how
to use it (TUN and VLAN devices virtualization).

If this will be found good, I'll send these sets to David, hoping he
will accept them :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
