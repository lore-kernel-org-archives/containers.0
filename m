From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Sat, 10 Jan 2009 12:50:41 +0800
Message-ID: <49682921.4020100@cn.fujitsu.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>	 <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>	 <496476FD.8090209@cn.fujitsu.com> <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Jan 7, 2009 at 1:33 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>>> Yes, I like that. Will update the patch. I assume that I must check
>>> list_empty(&cgroup->children)?
>> Yes.
>>
>>> Should I use cgroup_lock()/cgroup_unlock()
>> Yes.
> 
> For checking the "children" list, you can just lock
> ipaddr_subsys.hierarchy_mutex.
> 

Unfortunately hierarchy_mutex can't be used here, since hierarchy_mutex
doesn't protect subsys's create() method, and the create() will access
parent cgroup's data.


