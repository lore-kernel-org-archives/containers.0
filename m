From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 07/11] sysfs: Implement sysfs_delete_link and sysfs_rename_link
Date: Sun, 29 Jun 2008 12:35:36 +0900
Message-ID: <48670308.5020301@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>	<20080618170731.153832341@theryb.frec.bull.fr>	<485F06B8.6090902@gmail.com> <m1od5ovt9s.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757487AbYF2DgK@vger.kernel.org>
In-Reply-To: <m1od5ovt9s.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Tejun Heo <htejun@gmail.com> writes:
> 
>> Ugly but given the current interface limitations...
> 
> Yep.  I have been thinking it might be nice to look at what you did with magic symlink
> handling.  Otherwise we either need to convert everything from sysfs_remove_link to
> sysfs_delete_link if we don't want to play whack a mole.

I think the current one should do for now.  Changing to managed links
requires pervasive changes to locking and stuff.  I'll clean them up
when I refresh the patches I posted a while back.

Thanks.

-- 
tejun
