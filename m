From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] C/R: Add loopback checkpoint support (v2)
Date: Fri, 26 Feb 2010 04:09:20 -0800 (PST)
Message-ID: <20100226.040920.169783982.davem@davemloft.net>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-5-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1267130595-23637-5-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: danms@us.ibm.com
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org, ebiederm@xmission.com, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Dan Smith <danms@us.ibm.com>
Date: Thu, 25 Feb 2010 12:43:13 -0800

> Adds a small ndo_checkpoint() handler for loopback devices to write the
> name and addresses like other interfaces.
> 
> Changes in v2:
>  - Add CONFIG_CHECKPOINT around the handler
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
