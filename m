From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/16] net: Don't implement dev_ifname32 inline
Date: Wed, 12 Sep 2007 02:39:40 -0700 (PDT)
Message-ID: <20070912.023940.115920631.davem@davemloft.net>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:13:04 -0600

> 
> The current implementation of dev_ifname makes maintenance difficult
> because updates to the implementation of the ioctl have to made in two
> places.  So this patch updates dev_ifname32 to do a classic 32/64
> structure conversion and call sys_ioctl like the rest of the
> compat calls do.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
