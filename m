From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback
 registration
Date: Tue, 13 Nov 2007 10:52:29 +0900 (JST)
Message-ID: <20071113.105229.57026325.yoshfuji@linux-ipv6.org>
References: <m1ejev4dap.fsf@ebiederm.dsl.xmission.com>
	<473886E2.3020703@fr.ibm.com>
	<m16407450i.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m16407450i.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: dlezcano@fr.ibm.com, den@sw.ru, davem@davemloft.net, netdev@vger.kernel.org, xemul@openvz.org, containers@lists.osdl.org, benjamin.thery@bull.net, yoshfuji@linux-ipv6.org
List-Id: containers.vger.kernel.org

In article <m16407450i.fsf@ebiederm.dsl.xmission.com> (at Mon, 12 Nov 2007 12:50:53 -0700), ebiederm@xmission.com (Eric W. Biederman) says:

> My opinion is that both your analysis is slightly off (as to the cause
> of your problems) and that your approach to fix your problem is wrong
> because you don't untangle the knot you keep it.
:
> I have register_pernet_subsys and register_per_net_device to ensure
> that when we create a new network namespace all of the subsystems are
> initialized before the network devices are initialize.  So ipv6 should
> be ready before we initialize the new loopback device comes into
> existence.

User may not load ipv6.ko at boot, and then do "modprobe ipv6".
Do you take this into account?

--yoshfuji
