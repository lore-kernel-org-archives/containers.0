From: Karel Zak <kzak@redhat.com>
Subject: Re: [patch 6/9] unprivileged mounts: allow unprivileged mounts
Date: Wed, 9 Jan 2008 12:11:20 +0100
Message-ID: <20080109111120.GI3926@petra.dvoda.cz>
References: <20080108113502.184459371@szeredi.hu> <20080108113629.192719163@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080108113629.192719163@szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, Jan 08, 2008 at 12:35:08PM +0100, Miklos Szeredi wrote:
> Define a new fs flag FS_SAFE, which denotes, that unprivileged mounting of
> this filesystem may not constitute a security problem.
> 
> Since most filesystems haven't been designed with unprivileged mounting in
> mind, a thorough audit is needed before setting this flag.
> 
> For "safe" filesystems also allow unprivileged forced unmounting.

 What about to list "safe" filesystems anywhere in /proc/fs/ ? I think
 it's very important information for admins.

 Note, your patch for mount(8) is always trying to use unprivileged
 mount(2) for non-root users. It's overkill when unprivileged mounts are
 supported for bind mounts and fuse only. It would be nice to check
 if FS is "safe" before switch to unprivileged mode.

 The "safe" definition is also very subjective and it depends on your
 level of paranoia. There should be a way (e.g. /proc) how control and
 modify the list of "safe" filesystems. For example I have no problem
 to mark cifs as "safe" for my home server.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
