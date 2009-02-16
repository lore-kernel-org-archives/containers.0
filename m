From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [cgroup or VFS ?] WARNING: at	fs/namespace.c:636	mntput_no_expire+0xac/0xf2()
Date: Mon, 16 Feb 2009 09:29:00 +0800
Message-ID: <4998C15C.2070203@cn.fujitsu.com>
References: <499013CC.2060808@cn.fujitsu.com> <4993BD5D.2020707@cn.fujitsu.com>	<20090212062442.GE28946@ZenIV.linux.org.uk>	<4993C2A0.3050507@cn.fujitsu.com> <4993C7C2.4060100@cn.fujitsu.com>	<20090212070729.GF28946@ZenIV.linux.org.uk>	<4995007D.7040101@cn.fujitsu.com>	<20090213054751.GI28946@ZenIV.linux.org.uk>	<49950F3D.3030704@cn.fujitsu.com>	<20090213064135.GJ28946@ZenIV.linux.org.uk>	<20090213071816.GK28946@ZenIV.linux.org.uk> <4995208D.8050700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756447AbZBPB3T@vger.kernel.org>
In-Reply-To: <4995208D.8050700@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Al Viro wrote:
>> On Fri, Feb 13, 2009 at 06:41:35AM +0000, Al Viro wrote:
>>
>> Aaaargh...
>>
>>         /*
>>          * We don't have to hold all of the locks at the
>>          * same time here because we know that we're the
>>          * last reference to mnt and that no new writers
>>          * can come in.
>>          */
>>         for_each_possible_cpu(cpu) {
>>                 struct mnt_writer *cpu_writer = &per_cpu(mnt_writers, cpu);
>>                 if (cpu_writer->mnt != mnt)
>>                         continue;
>>                 spin_lock(&cpu_writer->lock);
>>
>> is *almost* OK.  Modulo SMP cache coherency.  We know that nothing should
>> be setting ->mnt to ours anymore, that's fine.  But we do not know if
>> we'd seen *earlier* change done on CPU in question (not the one we
>> are running __mntput() on).
>>
>> I probably would still like to use milder solution in the long run, but for
>> now let's check if turning that into
>>
>>                 struct mnt_writer *cpu_writer = &per_cpu(mnt_writers, cpu);
>>                 spin_lock(&cpu_writer->lock);
>>                 if (cpu_writer->mnt != mnt) {
>> 			spin_unlock(&cpu_writer->lock);
>>                         continue;
>> 		}
>> prevents the problem, OK?
>>
> 
> Sure, I'll try. :)
> 

Not a single warning for the whole weekend, so I think above change works.
