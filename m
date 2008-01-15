From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Tue, 15 Jan 2008 11:29:57 +0100
Message-ID: <E1JEj3N-0000vj-QA@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080114232419.GH6704@sergelap.austin.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080114232419.GH6704@sergelap.austin.ibm.com>
	(serue@us.ibm.com)
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> Sounds like a sysctl to enable FS_SAFE for fuse will make this patch
> acceptable to everyone?

I think the most generic approach, is to be able to set "safeness" for
any fs type, not just fuse (Karel's suggestion).

E.g:

  echo 1 > /proc/sys/fs/types/cifs/safe

This would also provide a way to query the FS_SAFE flag.

Miklos
