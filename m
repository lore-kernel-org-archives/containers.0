From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Mon, 03 Mar 2008 16:23:51 +0900
Message-ID: <47CBA787.8020100@cn.fujitsu.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com> <47C7EEAC.7010907@amln.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756717AbYCCH2x@vger.kernel.org>
In-Reply-To: <47C7EEAC.7010907@amln.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Xpl++ <xpl@amln.net>
Cc: Paul Menage <menage@google.com>, Linux Containers <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pavel Emelianov <xemul@openvz.org>, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Xpl++ wrote:
> Paul Menage ??????:
>> ...
>>
>> A compromise might be to keep "tasks" unprefixed, and say that future
>> names get the "cgroup." prefix; in this case I'd be inclined to add
>> the prefix to notify_on_release and release_agent on the grounds that
>> there's much less chance of breaking anyone with those files since (I
>> suspect) they're much less used.
>>   
> This makes most sense to me. It won't break any existing software 
> (most likely) while it seems reasonable to leave 'tasks' unprefixed as 
> this is something that any software using any subsystem of cgroup 
> would be using anyway and it is not that much associated with a 
> particulat subsystem.
>

And it makes most sense to me too, though I still doubt name collision 
will be a problem.
