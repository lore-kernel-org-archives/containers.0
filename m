From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: What's the status of 87b47932 patch - mnt: Implicitly add
	MNT_NODEV on remount as we do on mount
Date: Sat, 29 Nov 2014 17:04:03 -0600
Message-ID: <87k32dlicc.fsf@x220.int.ebiederm.org>
References: <20141127101105.GA30605@linux-rxt1.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20141127101105.GA30605-empE8CJ7fzk2xCFIczX1Fw@public.gmane.org> (joeyli's message of
	"Thu, 27 Nov 2014 18:11:05 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: joeyli <jlee-IBi9RG/b67k@public.gmane.org>
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Jim Fehlig <jfehlig-IBi9RG/b67k@public.gmane.org>, Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>
List-Id: containers.vger.kernel.org

joeyli <jlee-IBi9RG/b67k@public.gmane.org> writes:

> Hi Eric, 
>
> Sorry for bother you. I saw your patch:
> 	mnt: Implicitly add MNT_NODEV on remount as we do on mount
>
> Already commited in linux-next:
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/fs/namespace.c?id=87b47932f40a11280584bce260cbdb3b5f9e8b7d
>
> But, I didn't see this patch show in v3.18-rc kernel in Linus's git tree.
> What's the status of 87b47932 patch? Does there have regression cases it
> could not be merged to v3.18 kernel?

The patch actually breaks remounting filesystems that did not have
MNT_NODEV set when theny were mounted.

The primary issue is that the bug hit at a very inopportune time in my
life (just before kernel summit) after which I had a vacation planned
and after that I had some serious job hunting and moving to do. 

Now I am busily trying to catch up on my queue and these long delayed
bug fixes are the next issue.

If folks can review/test the current version of the patch (to follow in
a moment) I would appreciate it.  Based on previous testing unless I
have a typo what I expect to see is:
lxc  - b0rked.  The old versions of lxc must be broken to fix the
       security issue.
libvirt-lxc - fixed.
Andy's thing - fixed.

Any comments on the next user namespace breaking security fix that is
being finalized would also be appreciated.

Eric
