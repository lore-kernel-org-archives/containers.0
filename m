From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [PATCH 5/12 net-2.6.25] [NETNS]: Re-export init_net via EXPORT_SYMBOL.
Date: Tue, 22 Jan 2008 20:19:11 +0300
Message-ID: <4796258F.7050507@gmail.com>
References: <479612BE.8030409@openvz.org> <1201017566-16985-5-git-send-email-den@openvz.org> <47962228.3000302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47962228.3000302@trash.net>
Sender: netdev-owner@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Patrick McHardy wrote:
> Denis V. Lunev wrote:
>> init_net is used added as a parameter to a lot of old API calls, f.e.
>> ip_dev_find. These calls were exported as EXPORT_SYMBOL. So, export
>> init_net
>> as EXPORT_SYMBOL to keep networking API consistent.
> 
> 
> I think this should go in 2.6.24 if still possible so people
> don't have to find workarounds that will be obsolete one
> version later.
> 
yep, sure :) should I send this one separate for 2.4?
