From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 04/25] sysfs: Make sysfs_mount static
Date: Wed, 8 Aug 2007 15:51:03 +0900
Message-ID: <20070808065103.GX13674@htj.dyndns.org>
References: <11860582832964-git-send-email-htejun@gmail.com> <m1643rkqb6.fsf@ebiederm.dsl.xmission.com> <m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com> <m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com> <m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com> <m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762920AbXHHGvZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:11:16PM -0600, Eric W. Biederman wrote:
> 
> This patch modifies the users of sysfs_mount to use sysfs_root
> instead (which is what they are looking for).  It then
> makes sysfs_mount static to keep people from using it
> by accident.
> 
> The net result is slightly faster and cleaner code.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Tejun Heo <htejun@gmail.com>

--
tejun
