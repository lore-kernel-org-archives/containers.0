From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 11/11] sysfs: user namespaces: fix bug with clone(CLONE_NEWUSER)
 with fairsched
Date: Mon, 23 Jun 2008 11:18:58 +0900
Message-ID: <485F0812.4090903@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170731.746054454@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756454AbYFWCTU@vger.kernel.org>
In-Reply-To: <20080618170731.746054454@theryb.frec.bull.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> Mark the /sys/kernel/uids directory to be tagged so that processes in
> different user namespaces can remount /sys and see their own uid
> listings.
> 
> Without this patch, having CONFIG_FAIR_SCHED=y makes user namespaces
> unusable, because when you 
>   clone(CLONE_NEWUSER)
> it will auto-create the root userid and try to create
> /sys/kernel/uids/0.  Since that already exists from the parent user
> namespace, the create fails, and the clone misleadingly ends up
> returning -ENOMEM.
> 
> This patch fixes the issue by allowing each user namespace to remount
> /sys, and having /sys filter the /sys/kernel/uid/ entries by user
> namespace.
> 
> Signed-off-by: Serge Hallyn <serue@us.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Ditto as patch #10.

Thanks.

-- 
tejun
