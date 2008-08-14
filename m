From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] netns: Add network namespace argument in rt6_fill_node()
 and ipv6_dev_get_saddr()
Date: Thu, 14 Aug 2008 16:16:56 -0400
Message-ID: <48A492B8.8010109@hp.com>
References: <48A48722.3050509@hp.com> <48A48FC9.4020805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <48A48FC9.4020805@hp.com>
Sender: netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, containers <containers@lists.osdl.org>, linux-sctp@vger.kernel.org
List-Id: containers.vger.kernel.org

Hi Vlad,

Vlad Yasevich wrote:
> Hi Brian
> 
> Brian Haley wrote:
>> ---
>>
>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>> index 483a01d..e0945d4 100644
>> --- a/net/sctp/ipv6.c
>> +++ b/net/sctp/ipv6.c
>> @@ -319,7 +319,8 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
>>  			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
>>  
>>  	if (!asoc) {
>> -		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
>> +		ipv6_dev_get_saddr(NULL,
>> +				   dst ? ip6_dst_idev(dst)->dev : NULL,
>>  				   &daddr->v6.sin6_addr,
>>  				   inet6_sk(&sk->inet.sk)->srcprefs,
>>  				   &saddr->v6.sin6_addr);
> 
> 
> I think this needs to use sock_net(sctp_opt2s(sk)) instead of NULL.

Thanks Vlad, I didn't see that.  I noticed the xfrm code could pass 
non-NULL has well, I'll respin.

-Brian
