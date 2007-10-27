From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Fix get_net_ns_by_pid
Date: Fri, 26 Oct 2007 22:56:23 -0700 (PDT)
Message-ID: <20071026.225623.129837501.davem@davemloft.net>
References: <m1ve8twj2y.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1ve8twj2y.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, dlunev@gmail.com, benjamin.thery@bull.net, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 26 Oct 2007 17:29:41 -0600

> 
> The pid namespace patches changed the semantics of
> find_task_by_pid without breaking the compile resulting
> in get_net_ns_by_pid doing the wrong thing.
> 
> So switch to using the intended find_task_by_vpid.
> 
> Combined with Denis' earlier patch to make netlink traffic
> fully synchronous the inadvertent race I introduced with
> accessing current is actually removed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks.
