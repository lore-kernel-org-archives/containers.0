From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v6
Date: Thu, 01 Sep 2011 11:58:29 +0400
Message-ID: <4E5F3B25.9030701@parallels.com>
References: <20110831075814.003575573@openvz.org>	<20110831080229.100652529@openvz.org>	<20110831090612.GA3253@albatros>	<20110831112642.GI25465@sun>	<20110831140416.GA17626@shutemov.name>	<20110831142622.GB30615@sun> <20110831151023.5b7e12da.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110831151023.5b7e12da.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

> I'm reluctant to merge something like this unless/until it has real
> use-cases.
> 
> What is the status of your c/r effort?

Working prototype that can dump and restore tree of processes with their
registers, memory of all kinds (anon/file, private/shared), open regular
files and pipes (with contents).

And we have an RFC set from Tejun that can suspend and resume a TCP connection.

> What additional kernel patches are required to bring that effort to a
> usable state and where are those patches?

* The one you've already accepted with ->statfs for pipefs.
* PTRACE_SEIZE set from Tejun (RFC was sent some time earlier)
* CLONE_USEPID flag for the clone() syscall (Cyrill will re-send a bit later)
* The binfmt handler for images (I've sent it earlier, but there's a discussion
  happening over it. We can do restore without one, but it will improve the
  situation significantly)

Once this is merged the prototype I described above starts working on the
out-of-the-box kernel.

> IOW, before starting to merge things I'd like to get an understanding
> of what *all* the patches look like and of what level of c/r
> functionality they provide.
> 
> This particular patch introduces a distressing amount of duplication of
> /proc/pid/maps.  The changelog should provide a really good
> justification for doing this: why is /proc/pid/maps (and smaps!)
> unsuitable and why cannot maps/smaps be fixed to be suitable?

This is not duplication, since with /proc/pid/s?maps you have no idea of what
file is being mapped by a vma. I mean - you know some "path" to it, but it's
not reliable at all.

Besides, without this set there's absolutely no way to find out which two 
mappings are shared and is extremely hard to restore shared mapping.

Thanks,
Pavel
