From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and
 devices (v3)
Date: Wed, 10 Feb 2010 14:34:48 -0600
Message-ID: <20100210203448.GD23301@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
 <1265750713-15749-3-git-send-email-danms@us.ibm.com>
 <87ljf1gemh.fsf@caffeine.danplanet.com>
 <20100210192019.GA18879@us.ibm.com>
 <87hbpohor5.fsf@caffeine.danplanet.com>
 <20100210202509.GA23301@us.ibm.com>
 <87d40chlyx.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87d40chlyx.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> SH> I think that's be better.  Right now if we checkpoint a container
> SH> with macvlan restart will be bogus, right?  We're trying to avoid
> SH> any cases where we can't tell, at checkpoint, that restart won't
> SH> be right.
> 
> Depends on your definition of bogus, and the situation, but okay.
> 
> SH> What I was asking is should do_veth_message() be in drivers/net/veth.c?
> 
> Well, we could add another ndo_* function to the net device, I guess,
> but I'd be afraid we'd hit some cases where that wasn't sufficient.
> Maybe it would be best to generalize that bit after I've added macvlan
> (,etc) support so we have a good idea of what else would be needed?

Yeah, I think you're right.

thanks,
-serge
