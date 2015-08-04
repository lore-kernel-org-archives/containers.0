From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Tue, 04 Aug 2015 17:58:59 -0500
Message-ID: <874mkey824.fsf__26851.9042795107$1438729561$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<8738009i0h.fsf_-_@x220.int.ebiederm.org>
	<20150804115215.GA317@odin.com> <871tfj0x4j.fsf@x220.int.ebiederm.org>
	<20150804194447.GB6664@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150804194447.GB6664-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Tue, 4 Aug 2015 15:44:47 -0400")
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

> On Tue, Aug 04, 2015 at 12:41:32PM -0500, Eric W. Biederman wrote:
>> A pathname lookup taking 16 seconds seems absurd.  But perhaps in the
>> worst case.
>> 
>> The maximum length of a path that can be passed into path_lookup is
>> 4096.  For a lookup to be problematic there must be at least as many
>> instances of .. as there are of any other path component.  So each pair
>> of a minium length path element and a .. element must take at least 5
>> bytes. Which in 4096 bytes leaves room for 819 path elements.  If every
>> one of those 819 path components triggered a disk seek at 100 seeks per
>> second I could see a path name lookup potentially taking 8 seconds.
>
> A lookup on NFS while a server's rebooting or the network's flaky could
> take arbitrary long.  Other network filesystems and fuse can have
> similar problems.  Depending on threat model an attacker might have
> quite precise control over that timing.  Disk filesystems could have all
> the same problems since there's no guarantee the underlying block device
> is really local.  Even ignoring that, hardware can be slow or flaky.
> And couldn't an allocation in theory block for an arbitrary long time?
>
> Apologies for just dropping into the middle here!  I haven't read the
> rest and don't have the context to know whether any of that's relevant.

No problem.  The basic question is: can 2Billion renames be performed on
the same filesystem in less time than a single path lookup?  Allowing
the use of a 32bit counter.

Most of the issues that slow up lookup also slow up rename so I have
not been focusing on them.

If you could look up thread and tell me what you think of the issue with
file handle to dentry conversion and bind mounts I would be appreciate.

I have been testing a little more on my system and it appears that it
takes an 60minutes give or take to perform 2 Billino renames on ramfs.
A faster cpu (5Ghz?) could perhaps get that down to 30 minutes.

With no slow downs and no weirdness I have been able to get a single
pathname lookup to take just over 2 minutes, and I expect I could get
that to take another minute more.

Those numbers are within a factor of 10 of each other, and I expect
someone clever could finagle something to overcome the rest.  So sigh.

There just is not enough margin in there to be certain of things.  Now
with the small change to make that counter 64bit and that 30 minutes to
wrap the counter becomes 240,000+ years.  I think I can safely not worry
about the issue.  I just need to come up with a good 32bit implemenation.

Eric
