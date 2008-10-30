From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: dynamically allocated dst_ops
Date: Thu, 30 Oct 2008 07:26:22 +0300
Message-ID: <20081030042622.GA21196@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
To: netdev@vger.kernel.org, containers@lists.osdl.org
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

They are bogus and should be implanted into struct net directly.
In garbage collector hook, just use container_of() (once) to get struct net.
->dst_net is useless after that.

I'm going to use this trick for xfrm.

And if someone has ideas on how to overcome header difficulties, please,
submit a patch.
