From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: reduce size of per-cpu-stat to be appropriate
 size.
Date: Fri, 14 Nov 2008 13:27:27 +0530
Message-ID: <491D2F67.1070302@linux.vnet.ibm.com>
References: <20081113164201.GV29067@bolzano.suse.de> <20081113191837.18ed2ade.akpm@linux-foundation.org> <491CF609.3050203@cn.fujitsu.com> <20081114132840.98d38f12.kamezawa.hiroyu@jp.fujitsu.com> <20081114144926.d91f36fd.kamezawa.hiroyu@jp.fujitsu.com> <491D2C21.5000600@linux.vnet.ibm.com> <20081114164812.a0d70ef5.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755520AbYKNH6W@vger.kernel.org>
In-Reply-To: <20081114164812.a0d70ef5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Fri, 14 Nov 2008 13:13:29 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> +static int mem_cgroup_size(void)
>> inline this function?
>>
> necessary ? 

Not really, but might be good for older compilers.

-- 
	Balbir
