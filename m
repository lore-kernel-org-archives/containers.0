From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 2.6.24-rc3-mm1] IPC: make struct ipc_ids static in ipc_namespace
Date: Fri, 23 Nov 2007 11:02:47 +0300
Message-ID: <47468927.3040304@openvz.org>
References: <20071122155448.3193c856.pierre.peiffer@bull.net> <474680B5.7020104@fr.ibm.com> <47468347.5090303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755314AbXKWIF7@vger.kernel.org>
In-Reply-To: <47468347.5090303@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>, Pierre Peiffer <pierre.peiffer@bull.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Cedric Le Goater wrote:
>> Pierre Peiffer wrote:

[snip]

>> Pavel, what do you think of it ? 
> 
> Looks sane, good catch, Pierre.
> 
> But I'd find out whether these three ipc_ids intersect any 
> cache-line. In other words I'd mark the struct ipc_ids as
> ____cacheline_aligned and checked for any differences.

BTW! It might be also useful to keep ipc_ids closer to their
sysctl parameters.

>> Acked-by: Cedric Le Goater <clg@fr.ibm.com>
>>
>> Thanks,
> 
> Thanks,
> Pavel
> 
>> C.

[snip]
