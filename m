From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] Memory controller hierarchy support (v1)
Date: Sun, 20 Apr 2008 13:13:57 +0530
Message-ID: <480AF43D.1090405@linux.vnet.ibm.com>
References: <20080419053551.10501.44302.sendpatchset@localhost.localdomain> <4809CDB7.3000105@openvz.org>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754417AbYDTHrl@vger.kernel.org>
In-Reply-To: <4809CDB7.3000105@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Paul Menage <menage@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> 
> Are you going to split this patch? As is it looks rather huge :)
> 

Sure

>> TODO's/Open Questions
>>
>> 1. We need to hold cgroup_mutex while walking through the children
>>    in reclaim. We need to figure out the best way to do so. Should
>>    cgroups provide a helper function/macro for it?
>> 2. Do not allow children to have a limit greater than their parents.
>> 3. Allow the user to select if hierarchial support is required
>> 4. Fine tune reclaim from children logic
>>
> 
> I though about it recently. Can we have a cgroup file, which will
> control whether to attach a res_counter to the parent? This will
> address the YEMEMOTO's question about the performance.
> 

It's one of the TODOS

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
