From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 15/25] vfs: Remove lookup_one_len_kern
Date: Wed, 8 Aug 2007 17:39:53 +0900
Message-ID: <20070808083953.GH13674@htj.dyndns.org>
References: <m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com> <m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com> <m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com> <m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com> <m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com> <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com> <m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com> <m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com> <m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com> <m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762633AbXHHIkY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:25:05PM -0600, Eric W. Biederman wrote:
> 
> Now that sysfs no longer uses lookup_one_len_kern the function has
> no users so remove it from the kernel.  Making namei.c just a little
> easier to read.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Oh.. you're killing lookup_one_len_kern().  In that case, I think the
previous one is okay too.

Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
