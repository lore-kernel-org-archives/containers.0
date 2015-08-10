From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review 4/6] mnt: Track when a directory escapes a bind
	mount
Date: Mon, 10 Aug 2015 05:36:37 +0100
Message-ID: <20150810043637.GC14139@ZenIV.linux.org.uk>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87egjk9i61.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Mon, Aug 03, 2015 at 04:27:34PM -0500, Eric W. Biederman wrote:

> - The escape count on struct mount must be incremented both before the
>   rename and after.  If the count is not incremented before the rename
>   it is possible to hit a scenario where the rename happens the code
>   walks up the directory tree to somewhere outside of the bind mount
>   before the count is touched.  Similary without a count after the
>   rename it is possible for the code to look at the escape count
>   validate a path is connected before the rename and assume cache the
>   escape count, leading to not retesting the path is ok.

Umm...  I wonder if you are overcomplicating the things here.  Sure,
I understand wanting to reduce the checks on "..", but...  It costs you
considerable complexity (especially when it comes to 64bit counts),
it's really brittle (you need to be very careful about the places where
you zero the cached values in fs/namei.c and missing one will lead to
really unpleasant effects there) _and_ it's all for the benefit of 
a very rare case.  With check you are optimizing away not being all that
costly anyway.
 
> - The largest change is in d_unalias, where the two cases are split
>   apart so they can be handled separately.  In the easy case of a
>   rename within the same directory all that is needed is __d_move
>   (escaping a mount is impossible in that case).  In the more involved
>   case mutexes need to be acquired, and now the spin locks need to be
>   dropped so that proper lock aquisition order around __d_move can be
>   arranged.

I _really_ hate that part.  Could you explain WTF is wrong with simply
taking mount_lock in that case of __d_splice_alias() just outside of
rename_lock?

> +	unlock = lock_namespace_rename(dentry, target, false);
> +
>  	write_seqlock(&rename_lock);
>  	__d_move(dentry, target, false);
>  	write_sequnlock(&rename_lock);
> +
> +	if (unlock)
> +		unlock_namespace_rename(unlock, dentry, target, false);
> +

Your unlock_namespace_rename() should've been a static inline.
With the check of unlock != NULL done in there.  Two such inlines,
actually, and to hell with the boolean argument.  Same split for the
lock counterpart, of course.
