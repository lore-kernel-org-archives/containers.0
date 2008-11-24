From: Greg KH <greg@kroah.com>
Subject: Re: [patch 1/1][RFC]Handle uevent per namespace
Date: Mon, 24 Nov 2008 07:31:38 -0800
Message-ID: <20081124153138.GA16742@kroah.com>
References: <492A86FA.5080804@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <492A86FA.5080804@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Netdev List <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, Linux Containers <containers@lists.osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

On Mon, Nov 24, 2008 at 11:50:34AM +0100, Daniel Lezcano wrote:
>

> Subject: Handle uevent per namespace
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> At present when a network device is destroyed, inside a network
> namespace, and this device has the same name as one network device
> belonging to the initial network namespace (eg. eth0), the udev daemon
> will disable the interface in the initial network namespace.
> 
> IMHO, udev should not receive this event. The uevents should be per
> namespace or at least do not send events when not for the initial
> network namespace.

IMHO, network namespaces are a mess and not something that you should be
doing at all :)

> The following patch is a RFC for making uevent namespace aware. I don't
> know this part of the kernel code, so I am pretty sure t is not the 
> right way to do that :) 

Like Kay said, please don't change the kobject core for this, try just
filtering in the network core the events that you handle there.

good luck,

greg k-h
