From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [cgroup or VFS ?] WARNING: at fs/namespace.c:636	mntput_no_expire+0xac/0xf2()
Date: Mon, 16 Feb 2009 10:47:02 +0800
Message-ID: <4998D3A6.9010406@cn.fujitsu.com>
References: <4993C2A0.3050507@cn.fujitsu.com> <4993C7C2.4060100@cn.fujitsu.com> <20090212070729.GF28946@ZenIV.linux.org.uk> <4995007D.7040101@cn.fujitsu.com> <20090213054751.GI28946@ZenIV.linux.org.uk> <49950F3D.3030704@cn.fujitsu.com> <20090213064135.GJ28946@ZenIV.linux.org.uk> <20090213071816.GK28946@ZenIV.linux.org.uk> <4995208D.8050700@cn.fujitsu.com> <4998C15C.2070203@cn.fujitsu.com> <20090216023812.GT28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756539AbZBPCrD@vger.kernel.org>
In-Reply-To: <20090216023812.GT28946@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, gregkh@ZenIV.linux.org.uk, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: containers.vger.kernel.org

> OK...  So here's what we really want:
> 	* we know that nobody will set cpu_writer->mnt to mnt from now on
> 	* all changes to that sucker are done under cpu_writer->lock
> 	* we want the laziest equivalent of
> 		spin_lock(&cpu_writer->lock);
> 		if (likely(cpu_writer->mnt != mnt)) {
> 			spin_unlock(&cpu_writer->lock);
> 			continue;
> 		}
> 		/* do stuff */
> that would make sure we won't miss earlier setting of ->mnt done by another
> CPU.
> 

If this is done, I'll be available to test it.

> Anyway, for now (HEAD and all -stable starting with 2.6.26) we want this:
> 

And here is my:

Tested-by: Li Zefan <lizf@cn.fujitsu.com>

> --- fs/namespace.c	2009-01-25 21:45:31.000000000 -0500
> +++ fs/namespace.c	2009-02-15 21:31:14.000000000 -0500
> @@ -614,9 +614,11 @@
>  	 */
>  	for_each_possible_cpu(cpu) {
>  		struct mnt_writer *cpu_writer = &per_cpu(mnt_writers, cpu);
> -		if (cpu_writer->mnt != mnt)
> -			continue;
>  		spin_lock(&cpu_writer->lock);
> +		if (cpu_writer->mnt != mnt) {
> +			spin_unlock(&cpu_writer->lock);
> +			continue;
> +		}
>  		atomic_add(cpu_writer->count, &mnt->__mnt_writers);
>  		cpu_writer->count = 0;
>  		/*
