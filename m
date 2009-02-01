From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC][PATCH] simple_set_mnt() should return void
Date: Sun, 1 Feb 2009 17:32:34 +0100
Message-ID: <20090201163234.GC3416@lst.de>
References: <20090129063001.GA22898@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754703AbZBAQdM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090129063001.GA22898@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, hch@lst.de, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On Wed, Jan 28, 2009 at 10:30:01PM -0800, Sukadev Bhattiprolu wrote:
> 
> From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> Date: Wed, 28 Jan 2009 17:11:13 -0800
> Subject: [RFC][PATCH] simple_set_mnt() should return void
> 
> simple_set_mnt() is defined to return int but always returns 0.
> Callers assume simple_set_mnt() never fails and don't properly
> cleanup if it were to _ever_ fail. For instance, get_sb_single()
> and get_sb_nodev() should:
> 
>         up_write(sb->s_unmount);
>         deactivate_super(sb);
> 
> if simple_set_mnt() fails.
> 
> Since simple_set_mnt() never fails, would be cleaner if it did
> not return anything.

Makes sense to me.  Feel free to resend once you did an allmodconfig
or similar build.
