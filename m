From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 02 Dec 2007 00:24:10 +0100
Message-ID: <4751ED1A.6020400@gmail.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>	<20071201192341.6750fbdb@the-village.bc.nu>	<20071201113815.5df0960a@freepuppy.rosehill>	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com> <4751C238.6010609@rtr.ca>	<20071201122926.5c887588@laptopd505.fenrus.org>	<4751DC3C.1050606@rtr.ca> <m1tzn23t6k.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1tzn23t6k.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Mark Lord <lkml@rtr.ca>, Arjan van de Ven <arjan@infradead.org>, Stephen Hemminger <shemminger@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>, Tejun Heo <htejun@gmail.com>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Herbert Xu <herbert@gondor.apana.org.au>, David Miller <davem@davemloft.net>, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: containers.vger.kernel.org

On 12/02/2007 12:13 AM, Eric W. Biederman wrote:
> Mark Lord <lkml@rtr.ca> writes:
>> Fine.  But all of them want to call sk_alloc(),
> 
> network drivers should be calling sk_alloc less then they should
> call dev_get_by_XXXX.  Only protocols call sk_alloc.
> 
>> and many want to do register_netdev().
> 
> I haven't even touched register_netdev.
> 
>> So what should they be using there ?
> 
> What are you having problems with?
> 
> It is hard to answer specific questions without a context.

VMware vmnet.
