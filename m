From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Wed, 02 Apr 2008 23:46:19 +0400
Message-ID: <1207165579.7118.4.camel@iris.sw.ru>
References: <1206978361.10660.31.camel@iris.sw.ru>
	 <20080402.001048.267915281.davem@davemloft.net>
	 <1207130474.17626.2.camel@iris.sw.ru>
	 <20080402.114229.131377251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080402.114229.131377251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, 2008-04-02 at 11:42 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Wed, 02 Apr 2008 14:01:14 +0400
> 
> > On Wed, 2008-04-02 at 00:10 -0700, David Miller wrote:
> > > From: "Denis V. Lunev" <den@openvz.org>
> > > Date: Mon, 31 Mar 2008 19:46:01 +0400
> > > 
> > > > Hello, Dave!
> > > > 
> > > > Recently I have seen several issues post to the netdev@ blaming
> > > > inclusion of the net_namespace.h from seq_file. This set fixes this
> > > > problem after two small cleanups.
> > > 
> > > All applied, thanks Denis.
> > > 
> > > I'll push to net-2.6.26 after some build sanity checks.
> > 
> > Dave, could you pls conside this addition. This should fix problem
> > reported by the Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> recently.
> 
> Then this invalidates enourmous amounts of CONFIG_NET tests
> we've put into the headers over the past few days. 
> 
> All of them were explicitly to avoid having to provide the
> init_net symbol when CONFIG_NET is not set.

OK. do you suggest to insert another CONFIG_NET check into if_pppox
header or separate fs/compat_ioctl.c into two files:
- for net ioctls
- for the rest?

Regards,
	Den

