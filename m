From: Cornelia Huck <cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Mon, 6 Aug 2007 17:06:36 +0200
Message-ID: <20070806170636.6030c8b9@gondolin.boeblingen.de.ibm.com>
References: <m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
	<46AF15F6.6010202@suse.de>
	<m11weorf3l.fsf@ebiederm.dsl.xmission.com>
	<46AF1E57.3030209@suse.de> <20070731141613.GC13674@htj.dyndns.org>
	<m1fy33pq1r.fsf@ebiederm.dsl.xmission.com>
	<46B05A1D.5000703@gmail.com>
	<m1vebznpyc.fsf@ebiederm.dsl.xmission.com>
	<46B0C0E6.5030008@gmail.com>
	<m1ir7znog9.fsf@ebiederm.dsl.xmission.com>
	<46B0C817.7060106@gmail.com>
	<20070802102819.183720a4@gondolin.boeblingen.de.ibm.com>
	<m1tzrgl8mo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1tzrgl8mo.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, Linux-YRGon0hq2jhQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 03 Aug 2007 13:29:19 -0600,
ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:

> I currently have two practical solutions on the table.
> 
> - Make the s_sibling list walk RCU safe so it does not require us to
>   grab the sysfs_mutex.  This works but is a bit complicated.

But it would be nice, I guess :)

> 
> - Just kill all of the dentries in sysfs_move_dir and sysfs_rename_dir.
>   The semantics are that no one can be using the device at the time
>   of a rename or a move (as I read the callers) so dropping the dentries
>   and making it look like a delete/add pair to the users should be
>   acceptable and a whole lot simpler.

Hm, I'm not sure I understand you here. What do you mean by "using the
device"? Do you mean dropping the sysfs_dirents? Or am I just confused?
