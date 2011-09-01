From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v6
Date: Thu, 01 Sep 2011 16:13:54 +0400
Message-ID: <4E5F7702.2070808@parallels.com>
References: <20110831075814.003575573@openvz.org> <20110831080229.100652529@openvz.org> <20110831090612.GA3253@albatros> <20110831112642.GI25465@sun> <20110831140416.GA17626@shutemov.name> <20110831142622.GB30615@sun> <20110831151023.5b7e12da.akpm@linux-foundation.org> <4E5F3B25.9030701@parallels.com> <20110901115006.GB2752@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110901115006.GB2752@htj.dyndns.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

On 09/01/2011 03:50 PM, Tejun Heo wrote:
> Hello, Andrew, Pavel.
> 
> On Thu, Sep 01, 2011 at 11:58:29AM +0400, Pavel Emelyanov wrote:
>>> What additional kernel patches are required to bring that effort to a
>>> usable state and where are those patches?
>>
>> * The one you've already accepted with ->statfs for pipefs.
>> * PTRACE_SEIZE set from Tejun (RFC was sent some time earlier)
> 
> This one is already in mainline.  It's necessary to make the existing
> debuggers (strace and gdb) interact properly with job control.
> 
>> * CLONE_USEPID flag for the clone() syscall (Cyrill will re-send a bit later)
>> * The binfmt handler for images (I've sent it earlier, but there's a discussion
>>   happening over it. We can do restore without one, but it will improve the
>>   situation significantly)
> 
> I still can't see much point in binfmt handler.  The kernel pieces
> should be pretty small no matter how this one gets resolved.

Because with the handler restore process looks very natural and simple - each
task does the following steps

1. restore task resources (open files, set IDs, restore connections, wire back timers, etc.)
2. call execve() to jump into new memory+registers context which is
   a. unmap all the user memory
   b. map required mappings
   c. populate them with data
   d. restore registers
   e. restore IP

Note, that steps a through e are what execve() is designed for from day 1. Also note,
that when talking about the binary handler I do not insist in having my own one - it's
perfectly fine with me if we can make the ELF handler do the job (and I'm going to investigate
this ability soon).

With SEIZE it looks worse (maybe I'm seeing it wrong, then correct me please):

1. restore task resources
2. freeze
3. some foreigner attaches a parasite to the frozen task and the parasite
   should do steps a through e from the previous list to restore mem+regs context,
   but when doing steps a and b it should care about not killing himself from the
   target task context

This SEIZE-d restoring looks very complex and not efficient to me.

Am I wrong at some point?
   

> Thanks.
> 

