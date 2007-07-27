From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow
 directory support.
Date: Fri, 27 Jul 2007 14:58:23 +0400
Message-ID: <46A9CFCF.5000008@sw.ru>
References: <1182446577.8138.29.camel@localhost>	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>	<20070621211637.GB10583@suse.de>	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>	<20070622001328.GA14113@suse.de>	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>	<20070625212339.GA13398@kroah.com>	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>	<46A3B449.3090409@gmail.com>	<20070722202508.GA18018@suse.de>	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
	<46A85485.40502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46A85485.40502-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo wrote:
> Hello,
> 
> Okay, some questions.
> 
> * What do you think about not allowing duplicate names across different
> tags?  ie. there's only one ethX anywhere but it's visible only in a
> specific namespace (and maybe in the default global one).  Or does
> everyone need its own eth0.  If this is acceptable, the problem becomes
> _much_ simpler.

at least on checkpoint/restart names should be restored as is
and conflicts are unavoidable.
this includes ifindex as well by the way.

> * I think we can do away with the magic tag and use a pointer to
> vfsmount instead.  So, a process which wants to be in certain namespace
> can bind-mount /sysfs to its own /sysfs and make needed sysfs nodes
> bound to the mount.  Does this sound okay?  Such process should probably
> be in its own chrooted environment to function properly.
> 
> * I haven't really followed the containers thread.  Do people generally
> agree on including it in mainline when we have all the fancy
> virtualization stuff?

Thanks,
Kirill
