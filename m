From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [cgroup or VFS ?] WARNING: at	fs/namespace.c:636	mntput_no_expire+0xac/0xf2()
Date: Fri, 13 Feb 2009 14:31:12 +0800
Message-ID: <499513B0.6060804@cn.fujitsu.com>
References: <49617D35.4040805@cn.fujitsu.com>	<20090209004046.3ce1dde0.akpm@linux-foundation.org>	<20090209093414.GU28946@ZenIV.linux.org.uk>	<499013CC.2060808@cn.fujitsu.com> <4993BD5D.2020707@cn.fujitsu.com>	<20090212062442.GE28946@ZenIV.linux.org.uk>	<4993C2A0.3050507@cn.fujitsu.com> <4993C7C2.4060100@cn.fujitsu.com>	<20090212070729.GF28946@ZenIV.linux.org.uk>	<4995007D.7040101@cn.fujitsu.com>	<20090213054751.GI28946@ZenIV.linux.org.uk> <49950F3D.3030704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760510AbZBMGbt@vger.kernel.org>
In-Reply-To: <49950F3D.3030704@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Al Viro wrote:
>> On Fri, Feb 13, 2009 at 01:09:17PM +0800, Li Zefan wrote:
>>
>>> I ran following testcase, and triggered the warning in 1 hour:
>>>
>>> thread 1:
>>> for ((; ;))
>>> {
>>>         mount --bind /cgroup /mnt > /dev/null 2>&1
>>>         umount /mnt > /dev/null 2>&1
>>> }
>>>
>>> tread 2:
>>> for ((; ;))
>>> {
>>>         mount -t cgroup -o cpu xxx /cgroup > /dev/null 2>&1
>>>         mkdir /cgroup/0 > /dev/null 2>&1
>>>         rmdir /cgroup/0 > /dev/null 2>&1
>>>         umount -l /cgroup > /dev/null 2>&1
>>> }
>> Wow.  You know, at that point these redirects could probably be removed.
> 
> Ah, yes.
> 
>> If anything in there ends up producing an output, we very much want to
>> see that.  Actually, I'd even make that
>> 	mount --bind /cgroup/mnt || (echo mount1: ; date)
>> etc., so we'd see when do they fail and which one fails (if any)...
>>  
>> Which umount has failed in the above, BTW?
>>
>>
> 
> the first one sometimes failed, and the second one hasn't failed:
> 

Just triggered the warning at about:
	Fri Feb 13 14:26:03 CST 2009

But both 2 threads were not failing at that time:

mount: wrong fs type, bad option, bad superblock on /cgroup,
       missing codepage or helper program, or other error
       In some cases useful info is found in syslog - try
       dmesg | tail  or so

mount1
Fri Feb 13 14:25:21 CST 2009
umount: /mnt: not mounted
mount: wrong fs type, bad option, bad superblock on /cgroup,
...

mount1
Fri Feb 13 14:26:32 CST 2009
umount: /mnt: not mounted
mount: wrong fs type, bad option, bad superblock on /cgroup,
...
