From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/16] net: Add a network namespace parameter to tasks
Date: Wed, 12 Sep 2007 02:55:54 -0700 (PDT)
Message-ID: <20070912.025554.08333086.davem@davemloft.net>
References: <m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:17:03 -0600

> 
> This is the network namespace from which all which all sockets
> and anything else under user control ultimately get their network
> namespace parameters.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24
