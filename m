From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/16] net: Add a network namespace parameter to struct
 sock
Date: Wed, 12 Sep 2007 02:58:50 -0700 (PDT)
Message-ID: <20070912.025850.28798873.davem@davemloft.net>
References: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsv0vony.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1wsv0vony.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:21:37 -0600

> 
> Sockets need to get a reference to their network namespace,
> or possibly a simple hold if someone registers on the network
> namespace notifier and will free the sockets when the namespace
> is going to be destroyed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks.
