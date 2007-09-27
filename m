From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 3/4] net ipv4: When possible test for IFF_LOOPBACK and
 not dev == loopback_dev
Date: Thu, 27 Sep 2007 12:34:36 +0200
Message-ID: <46FB873C.6060200@fr.ibm.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com> <m1ir5xrngu.fsf@ebiederm.dsl.xmission.com> <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org, urs@isnogud.escape.de
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Now that multiple loopback devices are becoming possible it makes
> the code a little cleaner and more maintainable to test if a deivice
> is th a loopback device by testing dev->flags & IFF_LOOPBACK instead
> of dev == loopback_dev.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>


Urs Thuermann posted the patch:

	[PATCH 5/7] CAN: Add virtual CAN netdevice driver

This network driver set its flag to IFF_LOOPBACK for testing.
Is it possible this can be a collision with your patch ?

