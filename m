From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 05/11] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Sun, 22 Jun 2008 13:46:50 +0900
Message-ID: <485DD93A.6020600@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170730.853353875@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753238AbYFVErS@vger.kernel.org>
In-Reply-To: <20080618170730.853353875@theryb.frec.bull.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello, guys.  Sorry about the long silence.  Recent releases of
popular distros overwhelmed me with ata bugs.  They now seem to be
under control (and hopefully stay that way for some time to come).

On the previous iteration, I was hoping I could sort out sysfs
interface problem before this patchset but given that this is a long
overdue feature, I think we should get this thing working first.

The first four patches looked good to me, so feel free to add
Acked-by: Tejun Heo <tj@kernel.org>

Benjamin Thery Wrote:
> sysfs: sysfs_chmod_file handle multiple superblocks
> 
> Teach sysfs_chmod_file how to handle multiple sysfs
> superblocks.

I think it would be great if sysfs_chmod_file can do all-or-nothing
instead of failing half way through but given the interface of
notify_change(), it could be difficult to implement.  Any ideas?

Thanks.

-- 
tejun
