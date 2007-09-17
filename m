From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback
 device
Date: Mon, 17 Sep 2007 10:13:14 -0700
Message-ID: <20070917101314.5d1673da@freepuppy.rosehill.hemminger.net>
References: <20070917134509.222896190@mai.toulouse-stg.fr.ibm.com>
	<20070917135133.466924283@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070917135133.466924283@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: dlezcano@fr.ibm.com
Cc: davem@davemloft.net, netdev@vger.kernel.org, containers@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>, Kirill Korotaev <dev@sw.ru>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

On Mon, 17 Sep 2007 15:45:11 +0200
dlezcano@fr.ibm.com wrote:

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Doing this makes loopback.c a better example of how to do a
> simple network device, and it removes the special case
> single static allocation of a struct net_device, hopefully
> making maintenance easier.
> 

What is before/after code and data size, does it make code smaller?

>  
> -module_init(loopback_init);
> +fs_initcall(loopback_init);
>  
> +struct net_device *loopback_dev;
>  EXPORT_SYMBOL(loopback_dev);





-- 
Stephen Hemminger <shemminger@linux-foundation.org>
