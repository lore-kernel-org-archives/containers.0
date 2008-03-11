From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] memcg: put a restriction on writing memory.force_empty
Date: Tue, 11 Mar 2008 15:45:06 +0530
Message-ID: <47D65BAA.60908@linux.vnet.ibm.com>
References: <47D65A36.4020008@cn.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756706AbYCKKPi@vger.kernel.org>
In-Reply-To: <47D65A36.4020008@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> We can write whatever to memory.force_empty:
> 
>         echo 999 > memory.force_empty
>         echo wow > memory.force_empty
> 
> This is odd, so let's make '1' to be the only valid value.

I suspect as long as there is no unreasonable side-effect, writing 999 or wow
should be OK.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
