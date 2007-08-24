From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [Devel] [PATCH 1/1] Dynamically allocate the loopback device
Date: Fri, 24 Aug 2007 19:55:47 +0400
Message-ID: <46CEFF83.3040003@gmail.com>
References: <11879698031215-git-send-email-dlezcano@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <11879698031215-git-send-email-dlezcano@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: dlezcano@fr.ibm.com
Cc: davem@davemloft.net, shemminger@linux-foundation.org, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

dlezcano@fr.ibm.com wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Doing this makes loopback.c a better example of how to do a
> simple network device, and it removes the special case
> single static allocation of a struct net_device, hopefully
> making maintenance easier.
> 
> Applies against net-2.6.24
> 
> Tested on i386, x86_64
> Compiled on ia64, sparc

I think that a small note, that initialization order is changed will be
good to record. After this, loopback MUST be allocated before any other
networking subsystem initialization. And this is an important change.

Regards,
    Den
