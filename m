From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: reduce size of per-cpu-stat to be appropriate
 size.
Date: Fri, 14 Nov 2008 13:33:49 +0530
Message-ID: <491D30E5.7080608@linux.vnet.ibm.com>
References: <20081113164201.GV29067@bolzano.suse.de>	<20081113191837.18ed2ade.akpm@linux-foundation.org>	<491CF609.3050203@cn.fujitsu.com>	<20081114132840.98d38f12.kamezawa.hiroyu@jp.fujitsu.com>	<20081114144926.d91f36fd.kamezawa.hiroyu@jp.fujitsu.com>	<491D2C21.5000600@linux.vnet.ibm.com> <20081114164812.a0d70ef5.kamezawa.hiroyu@jp.fujitsu.com> <491D2E6C.1000009@cn.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753461AbYKNIEo@vger.kernel.org>
In-Reply-To: <491D2E6C.1000009@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
>>>> +static int mem_cgroup_size(void)
>>> inline this function?
>>>
>> necessary ? 
>>
> 
> Not so necessary IMO. It's called when a cgroup is created and removed, that
> is mkdir and rmdir, where performance is not critical.
> 

I think most new compilers can automatically inline such functions, but a hint
for the older ones is always a good practice.

-- 
	Balbir
