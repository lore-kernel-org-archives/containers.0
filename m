From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCHSET] Sysfs cleanups from Eric W. Biederman
Date: Wed, 22 Aug 2007 08:04:07 -0600
Message-ID: <m1ejhvpsx4.fsf@ebiederm.dsl.xmission.com>
References: <11876133893720-git-send-email-htejun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <11876133893720-git-send-email-htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Tejun Heo's
	message of "Mon, 20 Aug 2007 21:36:29 +0900")
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
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hello, all.
>
> This is subset of Eric W. Biederman's "Sysfs cleanups & tagged
> directory support" patchset[1] with the following modifications.

As a base: 
Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

>
> * fix-i_mutex-locking-in-sysfs_get_dentry patch is added at the top
>   and #14-Don_t-use-lookup_one_len_kern and
>   #15-vfs-Remove-lookup_one_len_kern are dropped.  This is because #14
>   contained had a bug where it might created dentry/inode for an
>   already deleted sysfs_dirent.  I think it's benefitial to keep
>   single lookup path.

I think I disagree with the bug spotting.

At least in net we the sysfs_rename_mutex which keeps parent
directories from disappearing.  Further we have a reference
to the leaf sysfs_dirent and are actively manipulating it, so
the sysfs_dirent should not disappear on us.

> * Rewrote simplify-sysfs_get_dentry patch and
>   #08-Implement-__sysfs_get_dentry,
>   #09-Move-sysfs_get_dentry-below-__sysfs_get_dentry and
>   #10-Rewrite-sysfs_get_dentry-in-terms-of-__sysfs_get_dentry are
>   omitted as __sysfs_get_dentry() isn't used by anyone.

Right.  __sysfs_get_dentry is an optimization that has makes
the best case for sysfs_get_dentry O(1) instead of O(depth).
However this doesn't matter because sysfs_get_dentry is not
on any fast path and the maximum depth of sysfs directories
is fairly shallow and programmer controlled.

The only user other user of __sysfs_get_dentry is in the tagged
directory support, and even that user doesn't strictly need it.
Although it is a bit silly to populate the dcache just so you
can invalidate it a moment later...

Just doing the dget(sysfs_sb->s_root) is a bit clearer in
sysfs_get_dentry then knowing implicitly that is what
__sysfs_get_dentry does in the worst cased.

> * #16, 19-25 are omitted as it isn't clear yet how the tagged entry
>   support will end up.
>
> * readdir simplification fixed.
>
> * sysfs_mutex double locking fixed.
>
> The patchset is on top of the current -gregkh.

Eric
