From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Use list_for_each_entry_continue_reverse in
 setup_net
Date: Sun, 16 Sep 2007 16:49:14 -0700 (PDT)
Message-ID: <20070916.164914.15264075.davem@davemloft.net>
References: <20070914144938.3ba643a5@oldman>
	<m1lkb92tto.fsf@ebiederm.dsl.xmission.com>
	<20070914220714.3a1e87f8@oldman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070914220714.3a1e87f8@oldman>
Sender: netdev-owner@vger.kernel.org
To: shemminger@linux-foundation.org
Cc: ebiederm@xmission.com, xemul@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 14 Sep 2007 22:07:14 +0200

> Could we just make it so dev->init is not allowed to fail? Then it
> can be a void function and the nasty unwind code can go?

Someone (not me :-) need to do an audit to find all current
users of this function and determine if they all can live
without returning errors.

If so, sure let's make the change and simplify things.
