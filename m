From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Mon, 31 Aug 2015 16:17:28 -0500
Message-ID: <87k2sb88ev.fsf@x220.int.ebiederm.org>
References: <874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<8738009i0h.fsf_-_@x220.int.ebiederm.org>
	<20150804115215.GA317@odin.com> <871tfj0x4j.fsf@x220.int.ebiederm.org>
	<20150804194447.GB6664@fieldses.org>
	<874mkey824.fsf@x220.int.ebiederm.org>
	<20150805155948.GD17797@fieldses.org>
	<878u9pwvg8.fsf@x220.int.ebiederm.org>
	<20150828194302.GE10468@fieldses.org>
	<20150828194540.GF10468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150828194540.GF10468-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Fri, 28 Aug 2015 15:45:40 -0400")
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

> On Fri, Aug 28, 2015 at 03:43:02PM -0400, J. Bruce Fields wrote:
>> On Wed, Aug 05, 2015 at 11:28:55AM -0500, Eric W. Biederman wrote:
>> > The file handle reconstitution code can certainly be affected by all of
>> > this.  Given that it is an failure if reconnect_path can't reconnect the
>> > path of a file handle.  I think it can reasonably considered an error in
>> > all cases if that path is outside of an exported bind mount, but I don't
>> > know that area particularly well.  The solution might just be don't
>> > export file handles from bind mounts.
>> 
>> I don't think there's any new cause for concern here.
>> 
>> I'd quibble with the language "don't export filehandles", *if* by that
>> you mean "don't tell allow anyone to know filehandles".  They're
>> guessable, so keeping them secret doesn't guarantee much security.
>> 
>> The dangerous operation is open_by_handle, and people need to understand
>> that if you allow someone to call that then you're effectively giving
>> access to the whole filesystem.  That's always been true.  (We don't
>> really have an efficient way to determine if a non-directory is in a
>> given subtree anyway.)
>>
>>
>> Such filehandle-guessing attacks on NFS have long been well-understood.
>> NOSUBTREECHECK can prevent them but causes other problems, so isn't the
>> default.

Interesting.  I guess it makes sense that filehandles can be guessed.  I
wonder if a crypto variant that is resistant to plain text attacks would
be a practical defense.

We do have d_ancestor/is_subdir that is a compartively efficient way to
see if a dentry is in a given subtree.  As it does not need to perform
the permission checks I believe it would be some cheaper than the
current nfs subtree check code.  I don't know if that would avoid the
known problem with the subtree check code.  Nor do I know if it would be
cheap enough to use for every nfsd operation when a file handle is
received.

>> So the basic rule I think is "don't allow lookup-by-filehandle (or NFS
>> export) on part of a filesystem unless you'd be willing to allow it on
>> the whole thing".
>
> (So in case it wasn't clear: ACK to just ignoring this, I don't think
> your (otherwise interesting) observations point to anything that needs
> fixing in the lookup-by-filehandle case.)

Thanks for looking into this.  It helps to know that someone who knows
the history of what happens with filehandles has looked at this.

Eric
