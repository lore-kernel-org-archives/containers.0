From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Wed, 07 Jan 2015 13:30:22 -0600
Message-ID: <87h9w2gzht.fsf__8138.62149739197$1420659242$gmane$org@x220.int.ebiederm.org>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150107184334.GZ22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Wed, 7 Jan 2015 18:43:34 +0000")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Mon, Jan 05, 2015 at 02:46:27PM -0600, Eric W. Biederman wrote:
>> Modify umount(MNT_DETACH) to keep mounts in the hash table that are
>> locked to their parent mounts, when the parent is lazily unmounted.
>> In doing this invert the reference count so that the parent holds a
>> reference to the children instead of the children holding a reference
>> to the parent.
>> 
>> Then in mntput_no_expire detach the children and in cleanup_mnt mntput
>> the children and dput the dentry they were mounted on.
>> 
>> In __detach_mounts if there are any mounts that have been unmounted
>> but still are on the list of mounts of a mountpoint, detach those
>> mounts and schedule them to be mntput and their reference to the dentry
>> to be put when it becomes safe to sleep.
>
> Explicit description of your new refcounting rules, please.  What's more,
> how do those non-pinning children interact with e.g. copy_tree()?

The parents hold a reference on the children, and the parent keeps track
of it's children through the mnt_mounts list.  The parents reference to
a child is held until the final mntput of the parent.

As for how those mounts interact with copy_tree, they aren't designed
to.  I had overlooked that collect_mounts is weird and if the proper
race exists can be called on an unmounted tree.  So I expect the
interaction with copy_tree is buggy.  I will look at that and see what I
can do to fix that (it shouldn't be hard).  I expect I can just return
an error if the mount has been unmounted.

Eric
