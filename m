From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1][IPV6] resend: remove duplicate call to
 proc_net_remove
Date: Tue, 30 Oct 2007 15:39:42 -0700 (PDT)
Message-ID: <20071030.153942.58465937.davem@davemloft.net>
References: <20071030162344.297260466@mai.toulouse-stg.fr.ibm.com>
	<20071030162450.257974469@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071030162450.257974469@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: dlezcano@fr.ibm.com
Cc: ebiederm@xmission.com, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 30 Oct 2007 17:23:45 +0100

> The file /proc/net/if_inet6 is removed twice.
> First time in:
>         inet6_exit
>              ->addrconf_cleanup
> And followed a few lines after by:
>         inet6_exit
>              -> if6_proc_exit
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks Daniel.
