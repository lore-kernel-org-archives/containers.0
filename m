From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS] resend:  fix net released by rcu callback
Date: Tue, 30 Oct 2007 14:47:34 -0600
Message-ID: <m1odegl47t.fsf@ebiederm.dsl.xmission.com>
References: <20071030162139.954791193@mai.toulouse-stg.fr.ibm.com>
	<20071030162305.458123510@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071030162305.458123510@mai.toulouse-stg.fr.ibm.com> (Daniel
	Lezcano's message of "Tue, 30 Oct 2007 17:21:40 +0100")
Sender: netdev-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Cc: davem@davemloft.net, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> When a network namespace reference is held by a network subsystem,
> and when this reference is decremented in a rcu update callback, we
> must ensure that there is no more outstanding rcu update before 
> trying to free the network namespace.
>
> In the normal case, the rcu_barrier is called when the network namespace
> is exiting in the cleanup_net function.
>
> But when a network namespace creation fails, and the subsystems are
> undone (like the cleanup), the rcu_barrier is missing.
>
> This patch adds the missing rcu_barrier.

Looks sane.  Did you have any specific failures related to this or was
this something that was just caught in review?

Eric
