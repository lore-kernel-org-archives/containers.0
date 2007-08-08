From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 22/25] sysfs: sysfs_uptdate_file handle multiple superblocks
Date: Wed, 8 Aug 2007 18:39:09 +0900
Message-ID: <20070808093909.GN13674@htj.dyndns.org>
References: <m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com> <m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com> <m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com> <m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com> <m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com> <m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com> <m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com> <m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com> <m1myx3ghdt.fsf_-_@ebiederm.dsl.xmission.com> <m1ir7rghbg.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764549AbXHHJj3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1ir7rghbg.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:34:11PM -0600, Eric W. Biederman wrote:
> 
> Teach sysfs_update_file how to handle multiple sysfs
> superblocks.  Again we are just iterating over the superblocks
> to so all of the filesystem modification notifications work
> as expected.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Same as the previous one.

-- 
tejun
