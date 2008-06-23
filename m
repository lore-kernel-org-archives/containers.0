From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 09/11] sysfs: add sysfs_ns_exit routine
Date: Mon, 23 Jun 2008 11:16:12 +0900
Message-ID: <485F076C.8040402@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170731.450724863@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755430AbYFWCQf@vger.kernel.org>
In-Reply-To: <20080618170731.450724863@theryb.frec.bull.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> Add sysfs routine sysfs_ns_exit() to allow a namespace to go away while
> sysfs is still mounted. 
> 
> The exiting namespace calls this routine and pass it a callback to be 
> called for every sysfs superblocks present. The callback contains the 
> necessary code to clean the superblock tag data associated with this 
> namespace.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Similar object to earlier dynamic tag thing.  Can't we just have
something like sysfs_murder_sb(sb) where @sb represents a ns?

-- 
tejun
