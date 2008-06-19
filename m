From: "Benjamin Thery " <Benjamin.Thery@bull.net>
Subject: Re: [PATCH 01/11] sysfs: Support for preventing unmounts.
Date: Thu, 19 Jun 2008 22:19:41 +0200
Message-ID: <20080619221941.588r3j9ascw0oco4@intran0x.frec.bull.fr>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170730.256129077@theryb.frec.bull.fr>
	<1213811063.7922.39.camel@nimitz> <m18wx2o638.fsf@frodo.ebiederm.org>
	<1213893131.7922.67.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753192AbYFSUTW@vger.kernel.org>
In-Reply-To: <1213893131.7922.67.camel@nimitz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Tejun Heo <htejun@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Quoting Dave Hansen <dave@linux.vnet.ibm.com>:

> On Wed, 2008-06-18 at 13:12 -0700, Eric W. Biederman wrote:
>>
>> - The data in sysfs fundamentally changes behind the back of the
>>   VFS and we need to keep the VFS in sync.  Essentially this is the
>>   distributed filesystem problem.
>>
>> - In particular for sysfs_rename and sysfs_move_dir we need to support
>> finding
>>   the dcache entries and calling d_move.  So that the dcache does not
>>   get into an inconsistent state.  Timeouts and invalidates like NFS
>>   uses are to be  avoided if at all possible.
>
> Much clearer now, thanks!
>
> Can we get this description into the changelog, pretty please?

Yes sure.
I'll add it to the patch introduction.

Benjamin

>
> -- Dave
>
>
>



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.
