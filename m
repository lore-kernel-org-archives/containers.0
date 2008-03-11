From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] memcgoup: allow memory.failcnt to be reset
Date: Tue, 11 Mar 2008 15:44:49 +0530
Message-ID: <47D65B99.3070208@linux.vnet.ibm.com>
References: <47D65A3E.100@cn.fujitsu.com> <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751138AbYCKKPS@vger.kernel.org>
In-Reply-To: <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Tue, 11 Mar 2008 19:09:02 +0900
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> Allow memory.failcnt to be reset to 0:
>>
>>         echo 0 > memory.failcnt
>>
>> And '0' is the only valid value.
>>
> Can't this be generic resource counter function ?
> 

I was about to suggest a generic cgroup option, since we do reset values even
for the cpu accounting subsystem.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
