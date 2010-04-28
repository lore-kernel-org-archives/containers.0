From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Tue, 27 Apr 2010 17:18:44 -0700 (PDT)
Message-ID: <20100427.171844.77354120.davem@davemloft.net>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
	<1272034539-19899-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1272034539-19899-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: danms@us.ibm.com
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Dan Smith <danms@us.ibm.com>
Date: Fri, 23 Apr 2010 07:55:37 -0700

> This helper allows kernel routines to create a socket in a given netns,
> instead of forcing it to the initial or current one.
> 
> I know this seems like it's violating the netns boundary.  The intended
> use (as in the following patches) is specifically when talking to RTNETLINK
> in another netns for the purposes of creating or examining resources there.
> It is expected that this will be used for that sort of transient socket
> creation only.  In other words:

If you can create netlink sockets in a remote NS you can also make
changes there, and the whole point is to disallow changes.

So maybe you won't be making changes, but others will think about
using this and doing so.

At a high level, I think this is a really bad idea, so I won't be
applying this, sorry.
