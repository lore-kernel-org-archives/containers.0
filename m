From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 05/11] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Mon, 23 Jun 2008 23:42:35 +0200
Message-ID: <486018CB.80005@fr.ibm.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170730.853353875@theryb.frec.bull.fr> <485DD93A.6020600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755226AbYFWVnT@vger.kernel.org>
In-Reply-To: <485DD93A.6020600@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Tejun Heo wrote:
> Hello, guys.  Sorry about the long silence.  Recent releases of
> popular distros overwhelmed me with ata bugs.  They now seem to be
> under control (and hopefully stay that way for some time to come).
> 
> On the previous iteration, I was hoping I could sort out sysfs
> interface problem before this patchset but given that this is a long
> overdue feature, I think we should get this thing working first.
> 
> The first four patches looked good to me, so feel free to add
> Acked-by: Tejun Heo <tj@kernel.org>
> 
> Benjamin Thery Wrote:
>> sysfs: sysfs_chmod_file handle multiple superblocks
>>
>> Teach sysfs_chmod_file how to handle multiple sysfs
>> superblocks.
> 
> I think it would be great if sysfs_chmod_file can do all-or-nothing
> instead of failing half way through but given the interface of
> notify_change(), it could be difficult to implement.  Any ideas?

Is it acceptable to queue the notifications in a list until we are in 
the loop and loop again to notify when exiting the first loop without 
error ?
