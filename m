From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [net-2.6.24][NETNS][patch 1/3] fix export symbols
Date: Wed, 12 Sep 2007 14:57:33 +0200
Message-ID: <46E7E23D.1050201@fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com> <20070912124414.640551634@mai.toulouse-stg.fr.ibm.com> <20070912.055307.23027518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070912.055307.23027518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: ebiederm@xmission.com, containers@lists.osdl.org, netdev@vger.kernel.org, markn@au1.ibm.com, benjamin.thery@bull.net
List-Id: containers.vger.kernel.org

David Miller wrote:
> From: dlezcano@fr.ibm.com
> Date: Wed, 12 Sep 2007 14:38:12 +0200
> 
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> Add the appropriate EXPORT_SYMBOLS for proc_net_create,
>> proc_net_fops_create and proc_net_remove to fix errors when
>> compiling allmodconfig
>>
>> Signed-off-by: Mark Nelson <markn@au1.ibm.com>
>> Acked-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> Applied to net-2.6.24, thanks.
> 
> Why aren't you signing off on these patches?  Please
> do so in the future.
> 
> Because "From: " usually means you are the patch author, and I can't
> tell who wrote these patches, you or these other people listed in the
> signoff area.
> 

Sorry for that, I will take care of that next time. Thanks.
