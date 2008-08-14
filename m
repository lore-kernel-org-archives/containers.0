From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Thu, 14 Aug 2008 16:29:13 -0400
Message-ID: <48A49599.40307@hp.com>
References: <48A4871D.1030708@hp.com> <1218745207.16589.77.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1218745207.16589.77.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@parallels.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> On Thu, 2008-08-14 at 15:27 -0400, Brian Haley wrote:
>> Change dev_net() to handle a NULL argument - return &init_net instead.
>>
>> -Brian
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>> ---
>>
> the code is designed keeping in mind that there are no checks for
> 	net != NULL
> in any place. They are too expensive. We need to invent other way :(

Ok, I'll fix the other callers to pass *net, I was just trying to be 
overly safe in dev_net() to avoid a crash.

-Brian
