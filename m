From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/4] Sysctl namespace support
Date: Fri, 30 Nov 2007 23:56:27 +1100
Message-ID: <20071130125627.GH26848@gondor.apana.org.au>
References: <4742C73C.3010904@openvz.org> <m1odddc5mf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1odddc5mf.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Serge Hallyn <serue@us.ibm.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, Linux Containers <containers@lists.osdl.org>, Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
List-Id: containers.vger.kernel.org

On Thu, Nov 29, 2007 at 10:40:24AM -0700, Eric W. Biederman wrote:
> 
> Herbert we need this infrastructure most in net-2.6.25 (as not having
> it is a current bottleneck to further development of the network
> namespace) so these patches are against net-2.6.25.

I've applied them all to net-2.6.25 with Andrew's fixes included.
Thanks Eric.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
