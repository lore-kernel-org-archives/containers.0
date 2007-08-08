From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 14/25] sysfs: Don't use lookup_one_len_kern
Date: Thu, 09 Aug 2007 00:35:39 +0900
Message-ID: <46B9E2CB.1020208@gmail.com>
References: <m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com>	<m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>	<m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com>	<m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>	<20070808083815.GG13674@htj.dyndns.org> <m1ir7qdp3b.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934151AbXHHPgW@vger.kernel.org>
In-Reply-To: <m1ir7qdp3b.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
>> right?  I don't think we need to duplicate the code here.  Or is it
>> needed for later multi-sb thing?
> 
> Right.  We can do that as well. In practice in working code
> there is no real difference.
> 
> There is a little extra uniformity in rolling it ourselves, but
> not enough to worry about either way.
> 
> In the review/debug etc cycle it just wound up being a lot easier
> to roll the code myself.
> 
> By the time we get to lookup_one_len_kern it is almost impenetrable
> code in namei.c where sysfs_add_dentry tends is easier to comprehend,
> and to modify for debugging.

Yeap, agreed.  I agreed with this one too in the comment for the next
patch.  I guess I should have wrote here too.  Sorry about the trouble.

Thanks.

-- 
tejun
