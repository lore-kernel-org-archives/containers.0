From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 1 Dec 2007 11:17:36 -0800
Message-ID: <20071201111736.297dd99a@freepuppy.rosehill>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47515D39.9030900@rtr.ca>
Sender: netdev-owner@vger.kernel.org
To: Mark Lord <lkml@rtr.ca>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>, Tejun Heo <htejun@gmail.com>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Herbert Xu <herbert@gondor.apana.org.au>, David Miller <davem@davemloft.net>, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Sat, 01 Dec 2007 08:10:17 -0500
Mark Lord <lkml@rtr.ca> wrote:

> > Now that we have network namespace support merged it is time to
> > revisit the sysfs support so we can remove the dependency on !SYSFS.
> ...
> 
> Now that the namespace updates are part of 2.6.24,
> there is a major inconsistency in network EXPORT_SYMBOLs.
> 
> It used to be that an external network module could get away without
> having to add a MODULE_LICENSE("GPL*") line to the source.
> 
> In support of that, common networking functions (still) use EXPORT_SYMBOL()
> rather than the more restrictive EXPORT_SYMBOL_GPL().
> 
> Eg.  register_netdev(), sk_alloc(), __dev_get_by_name().
> 
> But now, none of those three are actually usable by default,
> because they all require "init_net", which is EXPORT_SYMBOL_GPL().
> 

Then init_net needs to be not GPL limited. Sorry, we need to allow
non GPL network drivers.  There is a fine line between keeping the
binary seething masses from accessing random kernel functions, and allowing
reasonable (but still non GPL) things like ndiswrapper to use network
device interface.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
