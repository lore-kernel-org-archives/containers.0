From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] cgroup: support checking of subsystem dependencies
Date: Thu, 19 Jun 2008 08:40:24 +0800
Message-ID: <4859AAF8.9060909@cn.fujitsu.com>
References: <4858C0ED.2080905@cn.fujitsu.com> <20080619091714.320fdaa6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757990AbYFSAmT@vger.kernel.org>
In-Reply-To: <20080619091714.320fdaa6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Jackson <pj@sgi.com>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jun 2008 16:01:49 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> This allows one subsystem to require that it only be mounted when some
>> other subsystems are also present in the proposed hierarchy.
>>
>> For example if subsystem foo depends on bar, the following will fail:
>>  # mount -t cgroup -ofoo xxx /dev/cgroup
>>
>> You should mount with both subsystems:
>>  # mount -t cgroup -ofoo,bar xxx /dev/cgroup
>>
> I'm just curious. May I ask "Is there such cgroup subsystem now ?"
> 

Currently no, but people who are developing or wants to develop new subsystems
may find this useful, for example Daisuke Nishimura-san's swap controller.
