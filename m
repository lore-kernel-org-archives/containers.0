From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Fri, 9 Jan 2009 13:38:45 -0800
Message-ID: <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	 <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>
	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>
	 <496476FD.8090209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <496476FD.8090209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, Jan 7, 2009 at 1:33 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>>
>> Yes, I like that. Will update the patch. I assume that I must check
>> list_empty(&cgroup->children)?
>
> Yes.
>
>> Should I use cgroup_lock()/cgroup_unlock()
>
> Yes.

For checking the "children" list, you can just lock
ipaddr_subsys.hierarchy_mutex.

Paul
