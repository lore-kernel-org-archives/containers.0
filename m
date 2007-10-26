From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove __net_initdata attribute
Date: Fri, 26 Oct 2007 04:41:13 -0700 (PDT)
Message-ID: <20071026.044113.195730366.davem@davemloft.net>
References: <20071026095652.GA8788@iris.sw.ru>
	<4721CF60.5060600@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4721CF60.5060600@sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@sw.ru
Cc: den@openvz.org, devel@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org, benjamin.thery@bull.net, clg@fr.ibm.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@sw.ru>
Date: Fri, 26 Oct 2007 15:28:32 +0400

> Dave, I am sorry, plz disregard the patch :(
> 
> - if the file is a part of the kernel, __exit (and pernet_unregister)
>   will never called and should be dropped
> - if the file is a part of a module, __init is NOT dropped on the
>   module loading stage
> 
> So, we can still make embedded people happy :) Thanks Pavel to pointing
> me this out.

Ok, I reverted it.
