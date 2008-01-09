From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 09 Jan 2008 15:14:13 +0100
Message-ID: <E1JCbh7-0005u7-0L@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu> <20080108225820.GA9735@elf.ucw.cz> <E1JCWxm-0005Fn-36@pomaz-ex.szeredi.hu> <20080109113325.GC9735@elf.ucw.cz> <E1JCan7-0005mP-UE@pomaz-ex.szeredi.hu> <20080109133506.GI9735@elf.ucw.cz> <E1JCbIb-0005rA-5O@pomaz-ex.szeredi.hu> <20080109140051.GB12784@elf.ucw.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080109140051.GB12784@elf.ucw.cz> (message from Pavel Machek on
	Wed, 9 Jan 2008 15:00:51 +0100)
Sender: linux-fsdevel-owner@vger.kernel.org
To: pavel@ucw.cz
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> > > I'm not saying fuse is worthless. It is a nice toy for single-user
> > > systems. But I do not think we should be merging "allow ordinary users
> > > to mount their own fuse's" before issues above are fixed.
> > 
> > I think multi user systems are not all that interesting.  And I
> > suspect very few of them want reliably working suspend/hibernate
> > (which they wouldn't get due to other issues anyway), or have weird
> > shutdown scripts which stop when they are unable to umount
> > filesystems.
> 
> Weird shutdown scripts? I believe all shutdown scripts have this issue
> -- if you want to [cleanly] unmount your / filesystem, you need all
> the opens for write closed, right...? Which self-deadlocked fused
> holding files open will prevent.
> 
> > For paranoid sysadmins, I suggest not enabling fuse for unprivileged
> > users, which is pretty easy to do: just don't set /dev/fuse to be
> > world read-writable (which is the default BTW).
> > 
> > So your reasons just don't warrant a big effort involving VFS hacking,
> > etc.  Patches are of course welcome.
> 
> Well, I believe code with obscure, but almost impossible to fix
> problems should not be merged...

That code _has_ been merged, something like 3 years ago, and is doing
fine, thank you.

The unprivileged mounts code, which we should be discussing, doesn't
change anything about that, except to not require another suid-root
utility.  Many distributions enabling unprivileged mounting by default
_now_, so it's not as if there's some great danger in doing this
slightly differently.

> Anyway, I believe it would be fair to mention kill -9 no longer
> working and shutdown/hibernation/multiuser problems it implies in the
> changelogs and probably sysctl documentation or how is this enabled.

Sure.

Miklos
