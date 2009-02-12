From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [cgroup or VFS ?] WARNING: at	fs/namespace.c:636	mntput_no_expire+0xac/0xf2()
Date: Thu, 12 Feb 2009 14:10:37 +0800
Message-ID: <4993BD5D.2020707@cn.fujitsu.com>
References: <49617D35.4040805@cn.fujitsu.com>	<20090209004046.3ce1dde0.akpm@linux-foundation.org>	<20090209093414.GU28946@ZenIV.linux.org.uk> <499013CC.2060808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757484AbZBLGLV@vger.kernel.org>
In-Reply-To: <499013CC.2060808@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: containers@lists.osdl.org, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Al Viro wrote:
>> On Mon, Feb 09, 2009 at 12:40:46AM -0800, Andrew Morton wrote:
>>>> Thread 1:
>>>>   for ((; ;))
>>>>   {
>>>>       mount -t cgroup -o cpuset xxx /mnt > /dev/null 2>&1
>>>>       mkdir /mnt/0 > /dev/null 2>&1
>>>>       rmdir /mnt/0 > /dev/null 2>&1
>>>>       umount /mnt > /dev/null 2>&1
>>>>   }
>>>>
>>>> Thread 2:
>>>>   {
>>>>       mount -t cpuset xxx /mnt > /dev/null 2>&1
>>>>       umount /mnt > /dev/null 2>&1
>>>>   }
>> How cute...  Same mountpoint in both, so these mount(2) will sometimes
>> fail (cgroup picks the same sb on the same options, AFAICS) and fail
>> silently due to these redirects...
>>
>> That's a lovely way to stress-test a large part of ro-bind stuff *and*
>> umount()-related code.  Could you do C equivalent of the above (just
>> the same syscalls in loop, nothing fancier) and do time-stamped strace?
>>
> 
> Sure, I'll write a C version and try to reproduce the warning.
> 

Unfortunately, the C equivalent can't reproduce the warning, I've run the
test for the whole night. :( While using the script, often I can trigger
the warning in several mins.
