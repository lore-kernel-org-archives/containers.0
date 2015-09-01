From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Tue, 01 Sep 2015 13:00:20 -0500
Message-ID: <877foavx3f.fsf__3949.13470740921$1441130862$gmane$org@x220.int.ebiederm.org>
References: <8738009i0h.fsf_-_@x220.int.ebiederm.org>
	<20150804115215.GA317@odin.com> <871tfj0x4j.fsf@x220.int.ebiederm.org>
	<20150804194447.GB6664@fieldses.org>
	<874mkey824.fsf@x220.int.ebiederm.org>
	<20150805155948.GD17797@fieldses.org>
	<878u9pwvg8.fsf@x220.int.ebiederm.org>
	<20150828194302.GE10468@fieldses.org>
	<20150828194540.GF10468@fieldses.org>
	<87k2sb88ev.fsf@x220.int.ebiederm.org>
	<20150901144632.GA32692@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150901144632.GA32692-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Tue, 1 Sep 2015 10:46:32 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:

> On Mon, Aug 31, 2015 at 04:17:28PM -0500, Eric W. Biederman wrote:
>> "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:
>> 
>> > On Fri, Aug 28, 2015 at 03:43:02PM -0400, J. Bruce Fields wrote:
>> >> On Wed, Aug 05, 2015 at 11:28:55AM -0500, Eric W. Biederman wrote:
>> >> > The file handle reconstitution code can certainly be affected by all of
>> >> > this.  Given that it is an failure if reconnect_path can't reconnect the
>> >> > path of a file handle.  I think it can reasonably considered an error in
>> >> > all cases if that path is outside of an exported bind mount, but I don't
>> >> > know that area particularly well.  The solution might just be don't
>> >> > export file handles from bind mounts.
>> >> 
>> >> I don't think there's any new cause for concern here.
>> >> 
>> >> I'd quibble with the language "don't export filehandles", *if* by that
>> >> you mean "don't tell allow anyone to know filehandles".  They're
>> >> guessable, so keeping them secret doesn't guarantee much security.
>> >> 
>> >> The dangerous operation is open_by_handle, and people need to understand
>> >> that if you allow someone to call that then you're effectively giving
>> >> access to the whole filesystem.  That's always been true.  (We don't
>> >> really have an efficient way to determine if a non-directory is in a
>> >> given subtree anyway.)
>> >>
>> >>
>> >> Such filehandle-guessing attacks on NFS have long been well-understood.
>> >> NOSUBTREECHECK can prevent them but causes other problems, so isn't the
>> >> default.
>> 
>> Interesting.  I guess it makes sense that filehandles can be guessed.  I
>> wonder if a crypto variant that is resistant to plain text attacks would
>> be a practical defense.
>
> People have considered it.  I don't think it would be hard: just
> generate some permanent server secret and use it to encrypt all
> filehandles (and decrypt them again when looking them up).
>
> Some of the reasons I don't think it's been done:
>
> 	- Well, it's work, and nobody's really felt that strongly about
> 	  it.
>
> 	- It's usually not that hard to create another filesystem when
> 	  you need a real security boundary.
>
> 	- Filehandles are forever.  But it's hard to keep secrets
> 	  forever, especially when they have to be transmitted over the
> 	  network a lot.  (In more detail: client applications can hold
> 	  long-lived references to filesystem objects through open file
> 	  descriptors or current working directories.  They expect those
> 	  to keep working even over server reboots.  We don't even know
> 	  about those references.  So any filehandle we give out could
> 	  be looked up at any time in the future.  The only case where
> 	  we consider it acceptable to return ESTALE is when the
> 	  object's actually gone.)
>
>> We do have d_ancestor/is_subdir that is a compartively efficient way to
>> see if a dentry is in a given subtree.  As it does not need to perform
>> the permission checks I believe it would be some cheaper than the
>> current nfs subtree check code.  I don't know if that would avoid the
>> known problem with the subtree check code.  Nor do I know if it would be
>> cheap enough to use for every nfsd operation when a file handle is
>> received.
>
> That would solve the problem for directories, but not for files.  For
> non-directories we'd need special support from the filesystem (since at
> the time we look up the filehandle the parent(s) may not be in the
> dcache yet).  Steps to check subtree membership would be roughly (number
> of hardlinks) * (average depth).  I think it's probably not worth it.

If viewed that way you are probably right.

I was simply thinking about using the existing subtree check without the
inode_permission test.  Which works at the cost of a readdir to
reconnect an inode to a directory.  I had not noticed the readdir
before.  So I admit it does not sound like something that is a
particularly speedy way to go.

> Anyway, forgive the digressions....

No problem.  Thank you for the discussion.  This has if nothing else
allowed me to understand this from a real world perspective, and in
particular allows me to understand which permission checks would be
necessary to safely allow file handles in a user namespace (if we ever
decide it is safe to allow that).

In short if you did not mount the filesystem you better not be nfs
exporting the filesystem, or parts of the filesystem, or be allowed to
use file handle access to the filesystem.

Eric
