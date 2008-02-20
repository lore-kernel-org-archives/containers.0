From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NETNS]: Namespace leak in pneigh_lookup.
Date: Wed, 20 Feb 2008 00:26:27 -0800 (PST)
Message-ID: <20080220.002627.118759776.davem@davemloft.net>
References: <1203426758-27813-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1203426758-27813-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 19 Feb 2008 16:12:38 +0300

> release_net is missed on the error path in pneigh_lookup.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks a lot.
