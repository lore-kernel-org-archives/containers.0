From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [v2][PATCH 1/5] Unroll essentials of do_remount_sb() into
	devpts
Date: Wed, 4 Feb 2009 18:27:57 -0600
Message-ID: <20090205002757.GA18758@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com> <20090204043640.GA26202@us.ibm.com> <20090204234905.GB17354@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761299AbZBEA2S@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090204234905.GB17354@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, Containers <containers@lists.osdl.org>, hch@lst.de, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Sukadev Bhattiprolu (sukadev@linux.vnet.ibm.com):
> > 
> > From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> > Date: Tue, 27 Jan 2009 22:58:18 -0800
> > Subject: [v2][PATCH 1/5] Unroll essentials of do_remount_sb() into devpts
> > 
> > On remount, devpts fs only needs to parse the mount options. Users cannot
> > directly create/dirty files in /dev/pts so the MS_RDONLY flag and
> > shrinking the dcache does not really apply to devpts.
> > 
> > So effectively on remount, devpts only parses the mount options and updates
> > these options in its super block. As such, we could replace do_remount_sb()
> > call with a direct parse_mount_options().
> > 
> > Doing so enables subsequent patches to avoid parsing the mount options twice
> > and simplify the code.
> 
> You've dropped the update_ptmx_mode() which you used to do
> inside devpts_remount().  Is that also on purpose?

Since it appears that mknod_ptmx() will be called anyway and
will do the same thing,

> > Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

Acked-by: Serge Hallyn <serue@us.ibm.com>
