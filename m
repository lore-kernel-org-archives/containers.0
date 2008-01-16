From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch] util-linux-ng: unprivileged mounts support
Date: Wed, 16 Jan 2008 21:33:30 +0100
Message-ID: <E1JFEx0-0004tn-TZ@pomaz-ex.szeredi.hu>
References: <E1JF7Xh-0003q3-Qv@pomaz-ex.szeredi.hu> <200801160817.12812.vapier@gentoo.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <200801160817.12812.vapier@gentoo.org> (message from Mike
	Frysinger on Wed, 16 Jan 2008 08:17:10 -0500)
Sender: linux-fsdevel-owner@vger.kernel.org
To: vapier@gentoo.org
Cc: miklos@szeredi.hu, util-linux-ng@vger.kernel.org, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

> > This is an experimental patch for supporing unprivileged mounts and
> > umounts.  The following features are added:
> 
> same feedback as last time ... the cap stuff needs to be made optional and 
> proper header checks added to configure ...

Later, sure.  For now, I'm concentrating on the actual functionality.

> > 1) If mount/umount are suid, first try without privileges.
> >
> > This is done by forking, dropping privileges in child, and redirecting
> > stderr to /dev/null.  If this succeeds, then parent exits with zero
> > exit code.  Otherwise parent continues normally (with privileges).
> > This isn't perfect, because the wrong error message will be printed if
> > mount/umount failed not because of insufficient privileges, but some
> > other error (e.g. mountpoint busy).
> 
> this normalization of error information does kind of suck ... but i
> think the way it's written, the end user will still get the real
> answer the second time around when the mount is attempted with root
> privs and not stderr sent to /dev/null ?

No, for example the user will get: "only root can umount foo" instead
of "foo is busy", which is very misleading, if the user _can_ umount
foo.

Miklos
