From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [Devel] [PATCH 4/4] net: Make the loopback device per network
 namespace
Date: Thu, 27 Sep 2007 16:14:41 +0400
Message-ID: <46FB9EB1.5070908@sw.ru>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>	<m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com> <m17imdrn8r.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m17imdrn8r.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> This patch makes loopback_dev per network namespace.  Adding
> code to create a different loopback device for each network
> namespace and adding the code to free a loopback device
> when a network namespace exits.
> 
> This patch modifies all users the loopback_dev so they
> access it as init_net.loopback_dev, keeping all of the
> code compiling and working.  A later pass will be needed to
> update the users to use something other than the initial network
> namespace.

A pity that an important bit of explanation is missed. The
initialization of loopback_dev is moved from a chain of devices
(init_module) to a subsystem initialization to keep proper order, i.e.
we must be sure that the initialization order is correct.

Regards,
	Den
