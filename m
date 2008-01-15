From: "A. C. Censi" <accensi@gmail.com>
Subject: Re: [patch 9/9] unprivileged mounts: add "no submounts" flag
Date: Tue, 15 Jan 2008 08:53:42 -0200
Message-ID: <643ea2b10801150253i735d7342q73bf01f864d6167c@mail.gmail.com>
References: <20080108113502.184459371@szeredi.hu>
	 <20080108113634.382855604@szeredi.hu>
	 <20080114233910.GI6704@sergelap.austin.ibm.com>
	 <E1JEjEE-0000xZ-RU@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JEjEE-0000xZ-RU@pomaz-ex.szeredi.hu>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: serue@us.ibm.com, akpm@linux-foundation.org, hch@infradead.org, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

On Jan 15, 2008 8:41 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > Quoting Miklos Szeredi (miklos@szeredi.hu):
> > > From: Miklos Szeredi <mszeredi@suse.cz>
> > >
> > > Add a new mount flag "nomnt", which denies submounts for the owner.
> > > This would be useful, if we want to support traditional /etc/fstab
> > > based user mounts.
> > >
> > > In this case mount(8) would still have to be suid-root, to check the
> > > mountpoint against the user/users flag in /etc/fstab, but /etc/mtab
> > > would no longer be mandatory for storing the actual owner of the
> > > mount.
> >
> > Ah, I see, so the floppy drive could be mounted as a MNT_NOMNT but
> > MNT_USER mount with mnt_owner set.  Makes sense.  I'd ask for a better
> > name than 'nomnt', but I can't think of one myself.
>
> Me neither.
>

Why not "nosubmnt"?


-- 
A. C. Censi
accensi [em] gmail [ponto] com
accensi [em] montreal [ponto] com [ponto] br
