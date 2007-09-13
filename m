From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix race when opening a proc file while a network
 namespace is exiting.
Date: Thu, 13 Sep 2007 00:19:55 -0700 (PDT)
Message-ID: <20070913.001955.85390949.davem@davemloft.net>
References: <m14phzam2l.fsf@ebiederm.dsl.xmission.com>
	<20070912224653.GK9830@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070912224653.GK9830@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2007 15:46:53 -0700

> Looks much better!
> 
> Acked-by: Paul E. McKenney <paulmck@us.ibm.com>

Applied, thanks everyone.
