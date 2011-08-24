From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Wed, 24 Aug 2011 19:19:47 +0400
Message-ID: <4E551693.5030400@parallels.com>
References: <20110824085329.GL29452@sun> <4E551331.1010709@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4E551331.1010709@acm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Zan Lynx <zlynx@acm.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

On 08/24/2011 07:05 PM, Zan Lynx wrote:
> On 8/24/2011 2:53 AM, Cyrill Gorcunov wrote:
>> From: Pavel Emelyanov <xemul@parallels.com>
>>
>> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
>> one for each mapping with file, the name of a symlink is vma->vm_start, the
>> target is the file. Opening a symlink results in a file that point exactly
>> to the same inode as them vma's one.
>>
>> This thing is aimed to help checkpointing processes.
>>
>> For example the ls -l of some arbitrary /proc/<pid>/map_files/
>>
>>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
> [snip]
> 
> Just curious: How do these symlinks work when the process reading a
> /proc file is in a chroot or a different namespace?
> 
> For example, a chroot environment might have independent copies of
> /lib64/ld-2.5.so and a bind mount of /proc. Does the symlink then point
> to the wrong file?

No and this is the trick - when you readlink it - it give you trash, but
when you open one - you get exactly the same file as the map points to.
