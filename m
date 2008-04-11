From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/14][RTNL]: Introduce the rtnl_kill_links call.
Date: Fri, 11 Apr 2008 14:48:39 +0200
Message-ID: <47FF5E27.3020209@trash.net>
References: <47FE2AD4.9080609@openvz.org> <47FE2E01.6030000@openvz.org> <37533.192.168.101.12.1207865395.squirrel@intranet> <47FF1ADB.1090805@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47FF1ADB.1090805@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Daniel Hokka Zakrisson <daniel@hozac.com>, Linux Netdev List <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Denis Lunev <den@openvz.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
>>>  	for_each_net(net) {
>>> -restart:
>>> -		for_each_netdev_safe(net, dev, n) {
>>> -			if (dev->rtnl_link_ops == ops) {
>>> -				ops->dellink(dev);
>>> -				goto restart;
>>> -			}
>>> -		}
>>> +		__rtnl_kill_links(net, ops);
>> This was _safe, and now it's not. Is that intentional?
> 
> Yup - we goto restart in case we del some link, so there's no need
> in _safe iteration. 
> 
> This goto was added by Partick (commit 68365458 [NET]: rtnl_link: 
> fix use-after-free) and I suspect he simply forgot to remove the 
> _safe iterator (I put him in Cc to correct me if I'm wrong).


No, that was an oversight, it should be safe to remove.
