From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Wed, 01 Aug 2007 19:02:05 +0900
Message-ID: <46B05A1D.5000703@gmail.com>
References: <m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>	<46AF15F6.6010202@suse.de>
	<m11weorf3l.fsf@ebiederm.dsl.xmission.com>	<46AF1E57.3030209@suse.de>
	<20070731141613.GC13674@htj.dyndns.org>
	<m1fy33pq1r.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1fy33pq1r.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Eric.

Eric W. Biederman wrote:
> I will look a little more and see.  But right now it looks like the
> real problem with locking is that we use sysfs_mutex to lock the
> sysfs_dirent s_children list.
> 
> Instead it really looks like we should use i_mutex from the appropriate
> inode.  Or is there a real performance problem with forcing the directory
> inodes in core when we modify the directories?

I don't think there is any performance problem.  Problems with using
i_mutex were...

* It was messy.  I don't remember all the details now but IIRC symlink
walk code was pretty complex.

* And more importantly, inodes are reclaimable and might or might not be
there.

-- 
tejun
