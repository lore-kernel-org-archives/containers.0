From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Wed, 28 Apr 2010 07:44:54 -0400
Message-ID: <1272455094.14068.15.camel@bigi>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
	 <1272034539-19899-3-git-send-email-danms@us.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1272034539-19899-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org


On Fri, 2010-04-23 at 07:55 -0700, Dan Smith wrote:
> This helper allows kernel routines to create a socket in a given netns,
> instead of forcing it to the initial or current one.
> 
> I know this seems like it's violating the netns boundary.  The intended
> use (as in the following patches) is specifically when talking to RTNETLINK
> in another netns for the purposes of creating or examining resources there.
> It is expected that this will be used for that sort of transient socket
> creation only.  In other words:
> 
>   s = sock_create_kern_net(AF_NETLINK, ..., other_netns, ...);
>   rtnl_talk(s);
>   close(s);
> 

CCing Eric B. and Daniel with whom i have had this discussion before.

So ... how does user space know what "other_netns" is?

Also note Eric's recent patches introduced another way of opening a
socket in a different namespace - are you using those in the abstraction
to find what netns is?

cheers,
jamal

