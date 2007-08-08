From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 09/25] sysfs: Move sysfs_get_dentry below __sysfs_get_dentry
Date: Wed, 8 Aug 2007 16:45:39 +0900
Message-ID: <20070808074539.GC13674@htj.dyndns.org>
References: <m1643rkqb6.fsf@ebiederm.dsl.xmission.com> <m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com> <m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com> <m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com> <m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com> <m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com> <m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com> <m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com> <m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com> <m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758186AbXHHHqP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:17:33PM -0600, Eric W. Biederman wrote:
> 
> sysfs_get_dentry is higher in fs/sysfs/dir.c then is needed and it the
> dependencies get simpler if we move it down in the file to where I
> have placed __sysfs_get_dentry.  So this patch just moves
> sysfs_get_dentry so code movement doesn't get confused with later code
> changes. 
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
