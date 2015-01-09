From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Fri, 09 Jan 2015 16:25:23 -0600
Message-ID: <87bnm7vbfw.fsf@x220.int.ebiederm.org>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<87h9w2gzht.fsf@x220.int.ebiederm.org>
	<20150107205239.GB22149@ZenIV.linux.org.uk>
	<87iogi8dka.fsf@x220.int.ebiederm.org>
	<20150108002227.GC22149@ZenIV.linux.org.uk>
	<20150108223212.GF22149@ZenIV.linux.org.uk>
	<20150109203126.GI22149@ZenIV.linux.org.uk>
	<87k30vwskd.fsf@x220.int.ebiederm.org>
	<20150109221715.GN22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150109221715.GN22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Fri, 9 Jan 2015 22:17:15 +0000")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Fri, Jan 09, 2015 at 03:30:10PM -0600, Eric W. Biederman wrote:
>
>> Where does the rcu_read_lock() happen?
>> I assume this is kill from fs_pin.kill?
>
> This is what I'd rather have *calling* fs_pin.kill (the ... part in there
> being the callback, with wakeup done as part of pin_remove(), which would
> be called by ->kill()).  The thing is, I don't want mnt_pin_kill() et.al.
> to grab refcount on fs_pin (or for the refcount to be necessary there).
>
> IOW, any refcounting belong on the same level as ->kill() implementation
> itself; for ex-mountpoint-related ones we'd need none whatsoever (->kill()
> would do
> 	dput(ex-mountpoint dentry);
> 	pin_remove(pin);
> 	mntput_no_expire(containing struct mount);
> and that would be it), for kernel/acct.c ones we do need some refcounting,
> but only for the local reasons - note that it's playing directly with
> refcount anyway, which is a pretty clear indication that we'd be better off
> with fs/fs_pin.c _not_ messing with that refcount in the first place.
> Getting rid of pin_put() also wouldn't hurt.

Got it.  I agree the infrastructure related to fs_pin is pretty awakward
right now.

I am digging in and seeing if I can figure out what the awkardness you
are seeing that needs the suggested changes, and then I will give you my feedback.

Eric
