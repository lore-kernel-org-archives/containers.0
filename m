From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 9/9] mnt: Honor MNT_LOCKED when detaching mounts
Date: Fri, 02 Jan 2015 20:27:06 -0600
Message-ID: <87a920sio5.fsf@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<1420235574-15177-9-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1420235574-15177-9-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric
	W. Biederman's message of "Fri, 2 Jan 2015 15:52:54 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> writes:

> Modify umount(MNT_DETACH) to keep mounts in the hash table that are
> locked to their parent mounts, when the parent is lazily unmounted.
> In doing this invert the reference count so that the parent holds a
> reference to the children instead of the children holding a reference
> to the parent.
>
> Then in mntput_no_expire detach the children and in cleanup_mnt mntput
> the children and dput the dentry they were mounted on.
>
> In __detach_mounts if there are any mounts that have been unmounted
> but still are on the list of mounts of a mountpoint, detach those
> mounts and schedule them to be mntput and their reference to the dentry
> to be put when it becomes safe to sleep.

Arr.  This isn't quite enough.  It does not properly handle mount
propagation MNT_DETACH and MNT_LOCKED.

I am not even certain MNT_DETACH needs to be involved.  Back to banging
my head against this one.  Sigh.

Eric
