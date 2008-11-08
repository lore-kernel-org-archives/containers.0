From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: Guaranetee the proper ordering of the
 loopback device.
Date: Fri, 07 Nov 2008 22:53:52 -0800 (PST)
Message-ID: <20081107.225352.193700609.davem@davemloft.net>
References: <m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
	<20081105.160047.174722021.davem@davemloft.net>
	<m14p2l0zyu.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m14p2l0zyu.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org, xemul@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Nov 2008 05:02:33 -0800

> Dave can you please drop this one for the moment.
> 
> I cleaned up my patch after the basic testing was over and the
> result is a kernel that won't boot.  So if we can prevent this
> patch from spreading and breaking a git-bisect that would be great.
> 
> I will follow up in a moment with a properly tested version.
> My apologies.

I'm putting a revert changeset in there, then your two new patches on
top.

I'm not screwing up my GIT tree for everyone who pulls from me just
because you can't be bothered to test the actual changes you send me.
