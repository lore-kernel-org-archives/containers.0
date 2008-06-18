From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 09/11] sysfs: add sysfs_ns_exit routine
Date: Wed, 18 Jun 2008 13:19:37 -0700
Message-ID: <m14p7qo5ra.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.450724863@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756355AbYFRUVg@vger.kernel.org>
In-Reply-To: <20080618170731.450724863@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Wed, 18 Jun 2008 19:08:59 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Benjamin Thery <benjamin.thery@bull.net> writes:

> Add sysfs routine sysfs_ns_exit() to allow a namespace to go away while
> sysfs is still mounted. 
>
> The exiting namespace calls this routine and pass it a callback to be 
> called for every sysfs superblocks present. The callback contains the 
> necessary code to clean the superblock tag data associated with this 
> namespace.

My apologies for not looking at this earlier.  This is a nice cleanup.
Thank you.

Eric
