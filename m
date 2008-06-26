From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 07/11] sysfs: Implement sysfs_delete_link and sysfs_rename_link
Date: Thu, 26 Jun 2008 13:24:47 -0700
Message-ID: <m1od5ovt9s.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.153832341@theryb.frec.bull.fr>
	<485F06B8.6090902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760638AbYFZUcA@vger.kernel.org>
In-Reply-To: <485F06B8.6090902@gmail.com> (Tejun Heo's message of "Mon, 23 Jun
	2008 11:13:12 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

> Ugly but given the current interface limitations...

Yep.  I have been thinking it might be nice to look at what you did with magic symlink
handling.  Otherwise we either need to convert everything from sysfs_remove_link to
sysfs_delete_link if we don't want to play whack a mole.

Eric
