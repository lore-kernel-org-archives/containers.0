From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Thu, 02 Aug 2007 02:51:19 +0900
Message-ID: <46B0C817.7060106@gmail.com>
References: <m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>	<46AF15F6.6010202@suse.de>
	<m11weorf3l.fsf@ebiederm.dsl.xmission.com>	<46AF1E57.3030209@suse.de>
	<20070731141613.GC13674@htj.dyndns.org>	<m1fy33pq1r.fsf@ebiederm.dsl.xmission.com>	<46B05A1D.5000703@gmail.com>	<m1vebznpyc.fsf@ebiederm.dsl.xmission.com>	<46B0C0E6.5030008@gmail.com>
	<m1ir7znog9.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ir7znog9.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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

Eric W. Biederman wrote:
> Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> 
>> Hmmm... I think we can live with a bit of complexity in
>> sysfs_get_dentry().  It's very well localized and not even long.  I have
>> been trying hard to untangle sysfs internals from vfs and have a bit of
>> resistance against going back.  But, then again, if we can achieve
>> something better and simpler, why not?
> 
> Right now my real challenge is untangling sysfs_move_dir.  In the
> case of multiple mounts of the sysfs tree.

OIC.  Yeah, I guess moving a sd with multiple dentries attached could be
pretty difficult.

> My practical problem is that I need to hold a lock for the sysfs
> dirents and while that lock is held I need to call sysfs_get_dentry
> for the destination directory once for each superblock.
> 
> It might be that some kind of reader-writer lock strategy is what
> I need to untangle this mess.  Rather then making changing to i_mutex.
> All I know is at the moment it is taking a lot of code reading and
> brain storm to come of with something that is easy to maintain.

Just in case, sysfs used to have sysfs_rename_rwsem to protect
move/rename against tree walking, which became unnecessary after i_mutex
-> sysfs_mutex conversion.  Move/rename can use stupid big fat locks if
that helps.

Good luck.

-- 
tejun
