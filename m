From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: Dynamically allocate the per cpu counters for
 the loopback device.
Date: Thu, 27 Sep 2007 11:52:00 -0700 (PDT)
Message-ID: <20070927.115200.56183114.davem@davemloft.net>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<20070926.220901.51682476.davem@davemloft.net>
	<m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Sep 2007 01:48:00 -0600

> I'm not doing get_cpu/put_cpu so does the comment make sense
> in relationship to per_cpu_ptr?

It is possible.  But someone would need to go check for
sure.
