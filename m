From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Checkpoint and Restart of INET routing information
Date: Wed, 28 Apr 2010 16:24:44 +0200
Message-ID: <4BD8452C.7040305@free.fr>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Dan Smith wrote:
> This set extends the existing network socket, device, and namespace support
> in the checkpoint tree to cover routing information.  It does so by making
> heavy use of RTNETLINK to dump and insert routes much like userspace would.
> Because the task doing the checkpointing or restarting needs to examine
> or setup resources for tasks in network namespaces other than its own, an
> additional kernel socket setup call is added.  It provides us the ability
> to talk to RTNETLINK in a foreign netns.
>
> The support added in this set allows me to configure various inet4 and inet6
> routes in a container and have them saved and restored successfully during
> a checkpoint/restart process.
>   

Why do you need to do that from the kernel ? Same remark for ipv4/6 
addresses.
What prevents you to do 'ip route show'  and use these informations to 
restore the routes later ?
Will we end up by moving all the network userspace tools in the kernel ? :)

If you use the Eric's setns patchset, you will be able to do that easily 
from userspace, no ?


