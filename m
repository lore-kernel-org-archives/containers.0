From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/16] appletalk: In notifier handlers convert the void
 pointer to a netdevice
Date: Wed, 12 Sep 2007 02:27:56 -0700 (PDT)
Message-ID: <20070912.022756.59666467.davem@davemloft.net>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:09:36 -0600

> 
> This slightly improves code safetly and clarity.
> 
> Later network namespace patches touch this code so this is a
> preliminary cleanup.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24
