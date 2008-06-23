From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 07/11] sysfs: Implement sysfs_delete_link and sysfs_rename_link
Date: Mon, 23 Jun 2008 11:13:12 +0900
Message-ID: <485F06B8.6090902@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170731.153832341@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755604AbYFWCNf@vger.kernel.org>
In-Reply-To: <20080618170731.153832341@theryb.frec.bull.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> sysfs: Implement sysfs_delete_link and sysfs_rename_link
> 
> When removing a symlink sysfs_remove_link does not provide
> enough information to figure out which tagged directory the symlink
> falls in.  So I need sysfs_delete_link which is passed the target
> of the symlink to delete.
> 
> Further half the time when we are removing a symlink the code is
> actually renaming the symlink but not doing so explicitly because
> we don't have a symlink rename method. So I have added sysfs_rename_link
> as well.
> 
> Both of these functions now have enough information to find a symlink
> in a tagged directory.  The only restriction is that they must be called
> before the target kobject is renamed or deleted.  If they are called
> later I loose track of which tag the target kobject was marked with
> and can no longer find the old symlink to remove it.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Ugly but given the current interface limitations...

Acked-by: Tejun Heo <tj@kernel.org>

-- 
tejun
