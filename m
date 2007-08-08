From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 06/25] sysfs: Simplify readdir.
Date: Wed, 8 Aug 2007 16:12:41 +0900
Message-ID: <20070808071241.GZ13674@htj.dyndns.org>
References: <11860582832964-git-send-email-htejun@gmail.com> <m1643rkqb6.fsf@ebiederm.dsl.xmission.com> <m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com> <m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com> <m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com> <m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com> <m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com> <m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764130AbXHHHTQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:13:14PM -0600, Eric W. Biederman wrote:
> 
> At some point someone wrote sysfs_readdir to insert a cursor
> into the list of sysfs_dirents to ensure that sysfs_readdir would
> restart properly.  That works but it is complex code and tends
> to be expensive.
> 
> The same effect can be achieved by keeping the sysfs_dirents in
> inode order and using the inode number as the f_pos.  Then
> when we restart we just have to find the first dirent whose inode
> number is equal or greater then the last sysfs_dirent we attempted
> to return.
> 
> Removing the sysfs directory cursor also allows the remove of
> all of the mysterious checks for sysfs_type(sd) != 0.   Which
> were nonbovious checks to see if a cursor was in a directory list.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
