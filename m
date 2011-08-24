From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Wed, 24 Aug 2011 13:33:39 +0400
Message-ID: <4E54C573.10302@parallels.com>
References: <20110824085329.GL29452@sun> <CAOJsxLGVLAV7JF=kJmHU7gzyTe3W94Fx5d6qjikrS=2Yw2=Muw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CAOJsxLGVLAV7JF=kJmHU7gzyTe3W94Fx5d6qjikrS=2Yw2=Muw@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

On 08/24/2011 01:21 PM, Pekka Enberg wrote:
> On Wed, Aug 24, 2011 at 11:53 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> From: Pavel Emelyanov <xemul@parallels.com>
>>
>> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
>> one for each mapping with file, the name of a symlink is vma->vm_start, the
>> target is the file. Opening a symlink results in a file that point exactly
>> to the same inode as them vma's one.
>>
>> This thing is aimed to help checkpointing processes.
> 
> OK, but you really should explain _how_ this will help with checkpointing.

This helps in three ways:

1. When dumping a task mappings we do know exact file that is mapped by particular
   region. We do this by opening /proc/pid/map_files/address symlink the way we do
   with file descriptors.
   
2. This also helps in determining which anonymous shared mappings are shared with
   each other by comparing the inodes of them.

3. When restoring a set of process in case two of them has a mapping shared, we map
   the memory by the 1st one and then open its /proc/pid/map_files/address file and
   map it by the 2nd task.

>                         Pekka
> .
> 

