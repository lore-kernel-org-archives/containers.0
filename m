From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Tue, 13 Sep 2011 18:20:56 +0400
Message-ID: <4E6F66C8.5020406@parallels.com>
References: <20110824085329.GL29452@sun> <20110913141412.GB7604@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110913141412.GB7604@ucw.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

On 09/13/2011 06:14 PM, Pavel Machek wrote:
> Hi!
> 
>> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
>> one for each mapping with file, the name of a symlink is vma->vm_start, the
>> target is the file. Opening a symlink results in a file that point exactly
>> to the same inode as them vma's one.
> 
> Is it good idea security-wise? It looks like symlink but does not
> behave like one. (And yes, I know we already have similar problems in
> /proc..)

What exactly doesn't behave like symlink, can you elaborate, please?

> ptrace-may-trace is not good enough protection; I can do  this on my
> own thread to get around read-only protection on fd. (File can be
> protected from me by directory permissions.)

I think this issue worth separate discussion and if it turns out there is
a problem with that we can fix it together with /proc/pid/fd and other stuff.

Thanks,
Pavel
