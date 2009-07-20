From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] veth: don't free priv->status until dev->destructor
 (v2)
Date: Mon, 20 Jul 2009 14:25:42 -0700
Message-ID: <20090720142542.4fb12c12@nehalam>
References: <20090626162418.GA24828@us.ibm.com>
	<20090715.085012.223420354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090715.085012.223420354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
To: serue@us.ibm.com
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org, sachinp@in.ibm.com, netdev@vger.kernel.org, matthltc@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, 15 Jul 2009 08:50:12 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Serge E. Hallyn" <serue@us.ibm.com>
> Date: Fri, 26 Jun 2009 11:24:18 -0500
> 
> > I haven't been able to reproduce the original oops though (been
> > trying to cat the stats sysfs files while rmmoding veth, to no
> > avail, and haven't found an original bug report or testcase), so
> > can't verify whether this patch prevents the original oops.
> 
> If you 'cat' it you're unlikely to trigger the oops.
> 
> You have to hold the sysfs files open, and then elsewhere do the
> rmmod, wait, and then continue with some access to those open sysfs
> file descriptors (f.e. do some reads).
> 
> I'd also need this patch to be against current sources as they'll
> never apply since I did the revert quite some time ago.
> 
> Thanks.


My usual way of doing this is:

#  (sleep 30; cat /sys/class/net/ethX/statistics/tx_bytes) &
# rmmod the_buggy_driver

wait...


-- 
