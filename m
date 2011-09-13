From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Tue, 13 Sep 2011 16:14:14 +0200
Message-ID: <20110913141412.GB7604@ucw.cz>
References: <20110824085329.GL29452@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110824085329.GL29452@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

Hi!

> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> one for each mapping with file, the name of a symlink is vma->vm_start, the
> target is the file. Opening a symlink results in a file that point exactly
> to the same inode as them vma's one.

Is it good idea security-wise? It looks like symlink but does not
behave like one. (And yes, I know we already have similar problems in
/proc..)

ptrace-may-trace is not good enough protection; I can do  this on my
own thread to get around read-only protection on fd. (File can be
protected from me by directory permissions.)


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
