From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/5] net: Make rtnetlink infrastructure network namespace aware
Date: Sat, 29 Sep 2007 10:51:14 -0600
Message-ID: <m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>
	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
	<46FE72E3.3000402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <46FE72E3.3000402@trash.net> (Patrick McHardy's message of "Sat,
	29 Sep 2007 17:44:35 +0200")
Sender: netdev-owner@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> I'm wondering why this receive queue processing on unlock is still
> necessary today, we don't do trylock in rtnetlink_rcv anymore, so
> all senders will simply wait until the lock is released and then
> process the queue.

Good question, I should probably look.  I was lazy and didn't go back
and audit why we were doing this.  I just coded a routine that I was
certain would work.  It does appear that we are processing the queue
with sk_data_read when we add a message, so this may be completely
unnecessary.  I will go back and look.  If we can remove this bit
things should be simpler.

Eric

