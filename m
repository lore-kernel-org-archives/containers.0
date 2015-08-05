From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Wed, 05 Aug 2015 11:28:55 -0500
Message-ID: <878u9pwvg8.fsf@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<8738009i0h.fsf_-_@x220.int.ebiederm.org>
	<20150804115215.GA317@odin.com> <871tfj0x4j.fsf@x220.int.ebiederm.org>
	<20150804194447.GB6664@fieldses.org>
	<874mkey824.fsf@x220.int.ebiederm.org>
	<20150805155948.GD17797@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150805155948.GD17797-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Wed, 5 Aug 2015 11:59:48 -0400")
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

> On Tue, Aug 04, 2015 at 05:58:59PM -0500, Eric W. Biederman wrote:
>>
>> No problem.  The basic question is: can 2Billion renames be performed on
>> the same filesystem in less time than a single path lookup?  Allowing
>> the use of a 32bit counter.
>
> Certainly if you have control over an NFS or FUSE server then you can
> arrange for that to happen--just delay the lookup until you've processed
> enough renames.  I don't know if that's interesting....

Not particularly when the whole point is to start with a bind mount, do
something trick and then have access to the whole filesystem instead of
just the part of the filesystem exposed by the bind mount.

If you control the filesystem you already have access to the entire
filesystem, so you don't need to do something trick.

That something tricky is a well placed rename that borks the tree
structure and causes .. to never see the subdirectory that is the root
of the bind mount.

>> If you could look up thread and tell me what you think of the issue with
>> file handle to dentry conversion and bind mounts I would be appreciate.
>
> OK, I see your comments in "[PATCH review 0/6] Bind mount escape fixes",
> I'm not sure I understand yet, I'll take a closer look.

Thanks.

The file handle reconstitution code can certainly be affected by all of
this.  Given that it is an failure if reconnect_path can't reconnect the
path of a file handle.  I think it can reasonably considered an error in
all cases if that path is outside of an exported bind mount, but I don't
know that area particularly well.  The solution might just be don't
export file handles from bind mounts.

Eric
