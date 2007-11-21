From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] Isolate the UTS namespace's domainname and hostname back
Date: Wed, 21 Nov 2007 12:14:35 +0100
Message-ID: <4744131B.1020908@fr.ibm.com>
References: <4744113B.5010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761494AbXKULOs@vger.kernel.org>
In-Reply-To: <4744113B.5010309@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> The commit
> 
> commit 7d69a1f4a72b18876c99c697692b78339d491568
> Author: Cedric Le Goater <clg@fr.ibm.com>
> Date:   Sun Jul 15 23:40:58 2007 -0700
> 
>     remove CONFIG_UTS_NS and CONFIG_IPC_NS
> 
> accidentally removed the code, that prevented the uts->hostname
> and uts->domainname values from being overwritten from another
> namespace. In other words, setting hostname/domainname via sysfs 
> (echo xxx > /proc/sys/kernel/(host|domain)name) cased the new
> value to be set in init UTS namespace only.
> 
> Return the isolation back.

yep. sorry about that. I was going to send the same patch in a 
minute. 

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Cedric Le Goater <clg@fr.ibm.com>

Thanks,

C.
