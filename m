From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: dynamically allocated dst_ops
Date: Fri, 31 Oct 2008 14:34:02 +0100
Message-ID: <490B094A.1080900@fr.ibm.com>
References: <20081030042622.GA21196@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20081030042622.GA21196@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, benjamin.thery@bull.net
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> They are bogus and should be implanted into struct net directly.

Why they are bogus ?

> In garbage collector hook, just use container_of() (once) to get struct net.
> ->dst_net is useless after that.

Yep, that looks like a better solution.

> I'm going to use this trick for xfrm.
> 
> And if someone has ideas on how to overcome header difficulties, please,
> submit a patch.

