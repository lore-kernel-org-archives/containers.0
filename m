From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 07/11] sysfs: Implement sysfs_delete_link and sysfs_rename_link
Date: Sun, 29 Jun 2008 20:02:22 -0700
Message-ID: <m18wwnvd4x.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.153832341@theryb.frec.bull.fr>
	<485F06B8.6090902@gmail.com> <m1od5ovt9s.fsf@frodo.ebiederm.org>
	<48670308.5020301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755824AbYF3DLp@vger.kernel.org>
In-Reply-To: <48670308.5020301@gmail.com> (Tejun Heo's message of "Sun, 29 Jun
	2008 12:35:36 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:
>
> I think the current one should do for now.  Changing to managed links
> requires pervasive changes to locking and stuff.  I'll clean them up
> when I refresh the patches I posted a while back.

Sounds good.

Eric
