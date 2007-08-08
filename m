From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 18/25] sysfs: Rewrite sysfs_move_dir in terms of sysfs dirents
Date: Wed, 8 Aug 2007 17:53:04 +0900
Message-ID: <20070808085304.GJ13674@htj.dyndns.org>
References: <m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com> <m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com> <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com> <m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com> <m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com> <m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com> <m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com> <m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com> <m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com> <m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762613AbXHHIxY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:28:10PM -0600, Eric W. Biederman wrote:
> 
> This patch rewrites sysfs_move_dir to perform it's checks
> as much as possible on the underlying sysfs_dirents instead
> of the contents of the dcache, making sysfs_move_dir
> more like the rest of the sysfs directory modification
> code.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Signed-off-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
