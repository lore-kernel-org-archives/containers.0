From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Sat, 16 Aug 2008 23:30:09 +0200
Message-ID: <48A746E1.90703@fr.ibm.com>
References: <48A4871D.1030708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <48A4871D.1030708@hp.com>
Sender: netdev-owner@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Cc: David Miller <davem@davemloft.net>, containers <containers@lists.osdl.org>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Brian Haley wrote:
> Change dev_net() to handle a NULL argument - return &init_net instead.
> 
> -Brian
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Did you fall into the case where the argument was NULL ?

If it is the case, I think it is not the proper way to handle that. 
IMHO, this is the symptom the code which calls this function has a 
problem with the network namespace and it should be changed to be 
correct. eg, the code is assuming the network device is never null and 
so the network namespace can be retrieved from it, a correct fix may be 
to pass the network namespace as parameter of the function.

Returning &init_net if the network device is null will gracefully avoid 
the kernel oopsing but will lead to some inconsistent behaviour and 
confusion with what is happening with the namespace.

IMO, we should be radical and let the kernel oopsing, giving us only one 
action which is to fix asap the bug correctly.

Thanks.
   -- Daniel
