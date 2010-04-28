From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Wed, 28 Apr 2010 08:06:06 -0700
Message-ID: <871vdz1ush.fsf@caffeine.danplanet.com>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
	<1272034539-19899-3-git-send-email-danms@us.ibm.com>
	<20100427.171844.77354120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Hi,

DM> If you can create netlink sockets in a remote NS you can also make
DM> changes there, and the whole point is to disallow changes.

DM> So maybe you won't be making changes, but others will think about
DM> using this and doing so.

I would be making changes on restart, because I insert routes.  As has
been pointed out, Eric's setns() patches allow this sort of violation
from userspace even :)

Following that example, I could have the checkpointing task stash the
current nsproxy and temporarily jump to the destination netns to do
the checkpoint.  I'll cook up something to look at...

Thanks Dave!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
