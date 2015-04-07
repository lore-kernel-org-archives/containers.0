From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 16/19] mnt: Track which mounts use a dentry as root.
Date: Tue, 07 Apr 2015 15:22:52 -0500
Message-ID: <87egnvelib.fsf__41627.7149496183$1428438438$gmane$org@x220.int.ebiederm.org>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<1428026183-14879-16-git-send-email-ebiederm@xmission.com>
	<20150403055449.GE889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150403055449.GE889-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Fri, 3 Apr 2015 06:54:50 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Thu, Apr 02, 2015 at 08:56:20PM -0500, Eric W. Biederman wrote:
>
> One general note - I'd probably put a pointer to that sucker into struct
> mount.  For one thing, root-preserving clone_mnt() is a fairly common
> case.  For another, searching for that thing in mnt_put_root() looks
> wrong.  Matter of taste, but...

So I just played with the possibilities and adding a field in struct
mount makes the code more complicated not less.  So I have developed a
distaste for the idea of having a struct mountroot pointer in struct mount.

It especially complicates clone_mnt where I always have to have the code
look at the dentry to find the associated a dentry.  Resuing a current
struct mountroot and/or preallocating one is just a complicated mess.
The current implementation has a much more localized (and thus
understandable and maintainable) implementation.


> Another thing is that IMO it's better to preallocate that thing in
> vfs_kern_mount() and free if it turns out to be unused.  Simpler cleanup
> path that way...

It is a touch cleaner in vfs_kern_mount (not as many things need to be
freed) and much uglier and in clone_mnt.

>> -	mnt->mnt.mnt_root = root;
>> +	err = mnt_set_root(mnt, root);
>> +	if (err) {
>> +		dput(mnt->mnt.mnt_root);
>
> 	Unless I'm misreading your code, mnt_set_root() does *not* set it
> on failure, so what's going on here?

Typo.  That should simply have been dput(root);

Eric
