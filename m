From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 1/9] unprivileged mounts: add user mounts to the kernel
Date: Tue, 8 Jan 2008 21:34:21 +0000
Message-ID: <20080108213420.GD5050@ucw.cz>
References: <20080108113502.184459371@szeredi.hu> <20080108113619.213519920@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080108113619.213519920@szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue 2008-01-08 12:35:03, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> This patchset adds support for keeping mount ownership information in the
> kernel, and allow unprivileged mount(2) and umount(2) in certain cases.
> 
> The mount owner has the following privileges:
> 
>   - unmount the owned mount
>   - create a submount under the owned mount

- create unkillable processes
- block suspend/hibernation

?
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
