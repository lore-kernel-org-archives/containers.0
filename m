From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/5] memcg: VM overcommit accounting and handling
Date: Tue, 10 Jun 2008 10:43:23 +0530
Message-ID: <484E0D73.6010609@linux.vnet.ibm.com>
References: <1213054383-18137-1-git-send-email-righi.andrea@gmail.com> <20080610091439.04061da9.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755057AbYFJFNx@vger.kernel.org>
In-Reply-To: <20080610091439.04061da9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <righi.andrea@gmail.com>, menage@google.com, kosaki.motohiro@jp.fujitsu.com, xemul@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Tue, 10 Jun 2008 01:32:58 +0200
> Andrea Righi <righi.andrea@gmail.com> wrote:
> 
>> Provide distinct cgroup VM overcommit accounting and handling using the memory
>> resource controller.
>>
> 
> Could you explain the benefits of this even when we have memrlimit controller ?
> (If unsure, see 2.6.26-rc5-mm1 and search memrlimit controller.)
> 
> And this kind of virtual-address-handling things should be implemented on
> memrlimit controller (means not on memory-resource-controller.).
> It seems this patch doesn't need to handle page_group.
> 
> Considering hierarchy, putting several kinds of features on one controller is
> not good, I think. Balbir, how do you think ?
> 

I would tend to agree. With the memrlimit controller, can't we do this in user
space now? Figure out the overcommit value and based on that setup the memrlimit?


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
