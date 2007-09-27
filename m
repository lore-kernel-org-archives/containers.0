From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net ipv4: When possible test for IFF_LOOPBACK and
 not dev == loopback_dev
Date: Wed, 26 Sep 2007 22:10:18 -0700 (PDT)
Message-ID: <20070926.221018.18301963.davem@davemloft.net>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
	<m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 17:58:21 -0600

> 
> Now that multiple loopback devices are becoming possible it makes
> the code a little cleaner and more maintainable to test if a deivice
> is th a loopback device by testing dev->flags & IFF_LOOPBACK instead
> of dev == loopback_dev.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
