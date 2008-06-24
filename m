From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 05/11] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Tue, 24 Jun 2008 13:45:27 +0900
Message-ID: <48607BE7.2060203@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170730.853353875@theryb.frec.bull.fr> <485DD93A.6020600@gmail.com> <486018CB.80005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753795AbYFXEpw@vger.kernel.org>
In-Reply-To: <486018CB.80005@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello,

Daniel Lezcano wrote:
>> I think it would be great if sysfs_chmod_file can do all-or-nothing
>> instead of failing half way through but given the interface of
>> notify_change(), it could be difficult to implement.  Any ideas?
> 
> Is it acceptable to queue the notifications in a list until we are in
> the loop and loop again to notify when exiting the first loop without
> error ?

Can you please take a look at the following patch?

http://article.gmane.org/gmane.linux.file-systems/24484

Which replaces notify_change() call to two calls to sysfs_setattr() and
fsnotify_change().  The latter never fails and the former should always
succeed if inode_change_ok() succeeds (inode_setattr() never fails
unless the size is changing), so I think the correct thing to do is...

* Separate out sysfs_do_setattr() which doesn't do inode_change_ok() and
just sets the attributes.  Making it a void function which triggers
WARN_ON() when inode_setattr() fails would be a good idea.

* Implement sysfs_chmod_file() in similar way rename/move are
implemented - allocate all resources and check conditions and then iff
everything looks okay commit the operation by calling sysfs_do_setattr().

How does that sound?

Thanks.

-- 
tejun
