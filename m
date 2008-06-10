From: Andrea Righi <righi.andrea@gmail.com>
Subject: Re: [RFC PATCH 0/5] memcg: VM overcommit accounting and handling
Date: Tue, 10 Jun 2008 10:30:29 +0200 (MEST)
Message-ID: <484E3BA4.3000606@gmail.com>
References: <1213054383-18137-1-git-send-email-righi.andrea@gmail.com> <20080610091439.04061da9.kamezawa.hiroyu@jp.fujitsu.com> <484E0D73.6010609@linux.vnet.ibm.com> <484E32B9.4020606@openvz.org>
Reply-To: righi.andrea@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758636AbYFJIax@vger.kernel.org>
In-Reply-To: <484E32B9.4020606@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: menage@google.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Balbir Singh wrote:
>> KAMEZAWA Hiroyuki wrote:
>>> On Tue, 10 Jun 2008 01:32:58 +0200
>>> Andrea Righi <righi.andrea@gmail.com> wrote:
>>>
>>>> Provide distinct cgroup VM overcommit accounting and handling using the memory
>>>> resource controller.
>>>>
>>> Could you explain the benefits of this even when we have memrlimit controller ?
>>> (If unsure, see 2.6.26-rc5-mm1 and search memrlimit controller.)
>>>
>>> And this kind of virtual-address-handling things should be implemented on
>>> memrlimit controller (means not on memory-resource-controller.).
>>> It seems this patch doesn't need to handle page_group.
>>>
>>> Considering hierarchy, putting several kinds of features on one controller is
>>> not good, I think. Balbir, how do you think ?
>>>
>> I would tend to agree. With the memrlimit controller, can't we do this in user
>> space now? Figure out the overcommit value and based on that setup the memrlimit?
> 
> I also agree with Balbir and Kamezawa. Separate controller for VM (i.e. vma-s
> lengths) is more preferable, rather than yet another fancy feature on top of 
> the existing rss one.
> 

Yep! it seems I totally miss the memrlimit controller. I was trying to
implement pretty the same functionalities, using a different approach.
However, I agree that a separate controller seems to be a better
solution.

Thank you all for pointing in the right direction. I'll test memrlimit
controller and give a feedback.

-Andrea
