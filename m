From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Fri, 03 Aug 2007 13:29:19 -0600
Message-ID: <m1tzrgl8mo.fsf@ebiederm.dsl.xmission.com>
References: <m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
	<46AF15F6.6010202@suse.de> <m11weorf3l.fsf@ebiederm.dsl.xmission.com>
	<46AF1E57.3030209@suse.de> <20070731141613.GC13674@htj.dyndns.org>
	<m1fy33pq1r.fsf@ebiederm.dsl.xmission.com>
	<46B05A1D.5000703@gmail.com>
	<m1vebznpyc.fsf@ebiederm.dsl.xmission.com>
	<46B0C0E6.5030008@gmail.com>
	<m1ir7znog9.fsf@ebiederm.dsl.xmission.com>
	<46B0C817.7060106@gmail.com>
	<20070802102819.183720a4@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070802102819.183720a4-XQvu0L+U/CiXI4yAdoq52KN5r0PSdgG1zG2AekJRRhI@public.gmane.org>
	(Cornelia Huck's message of "Thu, 2 Aug 2007 10:28:19 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cornelia Huck <cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cornelia Huck <cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org> writes:

> On Thu, 02 Aug 2007 02:51:19 +0900,
> Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> Eric W. Biederman wrote:
>> > My practical problem is that I need to hold a lock for the sysfs
>> > dirents and while that lock is held I need to call sysfs_get_dentry
>> > for the destination directory once for each superblock.
>> > 
>> > It might be that some kind of reader-writer lock strategy is what
>> > I need to untangle this mess.  Rather then making changing to i_mutex.
>> > All I know is at the moment it is taking a lot of code reading and
>> > brain storm to come of with something that is easy to maintain.
>> 
>> Just in case, sysfs used to have sysfs_rename_rwsem to protect
>> move/rename against tree walking, which became unnecessary after i_mutex
>> -> sysfs_mutex conversion.  Move/rename can use stupid big fat locks if
>> that helps.
>
> I second that. Reintroduction of sysfs_rename_rwsem or something
> similar may be the best way to avoid headaches.

I guess I haven't looked at that because we already have a big fact
lock we just have an ordering problem in taking that lock.  Introducing
another lock just because of that doesn't quite feel right.

I currently have two practical solutions on the table.

- Make the s_sibling list walk RCU safe so it does not require us to
  grab the sysfs_mutex.  This works but is a bit complicated.

- Just kill all of the dentries in sysfs_move_dir and sysfs_rename_dir.
  The semantics are that no one can be using the device at the time
  of a rename or a move (as I read the callers) so dropping the dentries
  and making it look like a delete/add pair to the users should be
  acceptable and a whole lot simpler.

Eric
