From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] net: Make AF_UNIX per network namespace safe.
Date: Sat, 29 Sep 2007 17:47:56 +0200
Message-ID: <46FE73AC.40807@trash.net>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>	<m1d4w29t98.fsf_-_@ebiederm.dsl.xmission.com>	<m17ima9t52.fsf_-_@ebiederm.dsl.xmission.com> <m11wci9t3e.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m11wci9t3e.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Because of the global nature of garbage collection, and because of the
> cost of per namespace hash tables unix_socket_table has been kept
> global.  With a filter added on lookups so we don't see sockets from
> the wrong namespace.
> 
> Currently I don't fold the namesapce into the hash so multiple
> namespaces using the same socket name will be guaranteed a hash
> collision.


That doesn't sound like a good thing :) Is there a reason for
not avoiding the collisions?
