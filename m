From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Adding bridge interface to non-default network namespace crashes
 kernel
Date: Tue, 08 Sep 2009 10:40:44 +0200
Message-ID: <4AA6188C.1070806@free.fr>
References: <200909071807.54511.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <200909071807.54511.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
To: Atis Elsts <atis@mikrotik.com>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Atis Elsts wrote:
> Trying to add bridge interface from userspace program, after moving the 
> program to a new network namespace, causes kernel to crash. I am using latest 
> kernel version from git (2.6.31-rc9).
> The bug is easy to reproduce - just compile and run the attached C program.
>
> I see that bridge interface has NETIF_F_NETNS_LOCAL flag, but as I understand, 
> this flag simply means that a device cannot be *moved* across network 
> namespaces, not that it cannot be *created* in other namespaces.
>   
Yep, very easy to reproduce :/
The sysfs has not been disabled for the bridge. I will try to fix it as 
soon as I can.

Thanks
  -- Daniel
