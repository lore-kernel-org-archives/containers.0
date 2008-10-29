From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netns ebtables: part 1
Date: Wed, 29 Oct 2008 09:53:40 +0100
Message-ID: <49082494.6060209@trash.net>
References: <20081028205835.GC15660@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20081028205835.GC15660@x200.localdomain>
Sender: netfilter-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netfilter@vger.kernel.org, containers@osdl.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> * propagate netns from userspace, register table in passed netns
> * remporarily register every ebt_table in init_net
> 
> P. S.: one needs to add ".netns_ok = 1" to igmp_protocol to test with
> ebtables(8) in netns.

The containers list address bounces and the netfilter address is
the user list. Please resend with the proper addresses so other
developers get a chance to review the patches. Thanks.
