From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 09 Jan 2008 10:11:06 +0100
Message-ID: <E1JCWxm-0005Fn-36@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu> <20080108225820.GA9735@elf.ucw.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080108225820.GA9735@elf.ucw.cz> (message from Pavel Machek on
	Tue, 8 Jan 2008 23:58:20 +0100)
Sender: linux-fsdevel-owner@vger.kernel.org
To: pavel@ucw.cz
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> > > 'updatedb no longer works' is not a problem?
> > 
> > I haven't seen any problems with updatedb, and haven't had any bug
> > reports about it either.
> 
> Ok, I don't know much about FUSE. In current version, if user creates
> infinite maze and mounts it under ~, updatedb just does not enter it?

It doesn't.  See Documentation/filesystems/fuse.txt

> > AFAIR there were two security vulnerabilities in fuse's history, one
> > of them an information leak in the kernel module, and the other one an
> > mtab corruption issue in the fusermount utility.  I don't think this
> > is such a bad track record.
> 
> Not bad indeed. But I'd consider 'kill -9 not working' to be DoS
> vulnerability...

The worst that can happen is that a sysadmin doesn't read the docs
(likely) before enabling fuse on a multiuser system, and is surprised
by a user doing funny things.  And _then_ has to go read the docs, or
google for some info.  This is basically how things normally work, and
I don't consider it a DoS.

> and I'm woried about problems fuse + user mounts expose in other
> parts of system.

I'm worried too, and I'm not saying that enabling unprivileged fuse
mounts is completely risk free.  Nothing is, and nobody is forced to
do it.

Miklos
