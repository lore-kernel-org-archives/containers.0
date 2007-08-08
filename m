From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 03/25] sysfs: Use kill_anon_super
Date: Wed, 8 Aug 2007 15:50:39 +0900
Message-ID: <20070808065039.GW13674@htj.dyndns.org>
References: <11860582832964-git-send-email-htejun@gmail.com> <m1643rkqb6.fsf@ebiederm.dsl.xmission.com> <m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com> <m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com> <m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765899AbXHHGu5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Tue, Aug 07, 2007 at 03:10:27PM -0600, Eric W. Biederman wrote:
> 
> Since sysfs no longer stores fs directory information in the dcache
> on a permanent basis kill_litter_super it is inappropriate and actively
> wrong.  It will decrement the count on all dentries left in the
> dcache before trying to free them.
> 
> At the moment this is not biting us only because we never unmount sysfs.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
