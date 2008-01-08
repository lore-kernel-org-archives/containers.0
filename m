From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Tue, 8 Jan 2008 21:46:26 +0000
Message-ID: <20080108214625.GE5050@ucw.cz>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080108113630.861045063@szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> Use FS_SAFE for "fuse" fs type, but not for "fuseblk".
> 
> FUSE was designed from the beginning to be safe for unprivileged users.  This
> has also been verified in practice over many years.  In addition unprivileged

Eh? So 'kill -9 no longer works' and 'suspend no longer works' is not
considered important enough to even mention?

'updatedb no longer works' is not a problem?

Are you ready to offer shell account for bugtraq people to see how
long it survives?
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
