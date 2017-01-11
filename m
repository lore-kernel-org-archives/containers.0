From: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Subject: Re: Possible bug: detached mounts difficult to cleanup
Date: Tue, 10 Jan 2017 19:07:53 -0800
Message-ID: <20170111030753.GC2497@templeofstupid.com>
References: <20170111012454.GB2497@templeofstupid.com>
	<87r34a5p3t.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r34a5p3t.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 11, 2017 at 03:04:22PM +1300, Eric W. Biederman wrote:
> Any chance you have a trivial reproducer script?
> 
> From you description I don't quite see the problem.  I know where to
> look but if could give a script that reproduces the conditions you
> see that would make it easier for me to dig into, and would certainly
> would remove ambiguity.   Ideally such a script would be runnable
> under unshare -Urm for easy repeated testing.

My apologies.  I don't have something that fits into a shell script, but
I can walk you through the simplest test case that I used when I was
debugging this.

Create net a ns:

    $ sudo unshare -n bash
    # echo $$
    2771

In another terminal bind mount that ns onto a file:

    # mkdir /run/testns
    # touch /run/testns/ns1
    # mount --bind /proc/2771/ns/net /run/testns/ns1

Back in first terminal, create a new ns, pivot root, and umount detach:

    # exit
    $ unshare -U -m -n --propagation slave --map-root-user bash
    # mkdir binddir
    # mount --bind binddir binddir
    # cp busybox binddir
    # mkdir binddir/old_root
    # cd binddir
    # pivot_root . old_root
    # ./busybox umount -l old_root

Back in second terminal:

    # umount /run/testns/ns1
[ watch for ns cleanup -- not seen if mnt is locked ]
    # rm /run/testns/ns1
[ now we see it ]


For the observability stuff, I went back and forth between using 'perf
probe' to place a kprobe on nsfs_evict, and using a bcc script to
watch events on the same kprobe.  I can send along the script, if you're
a bcc user.

At least when I debugged this, I found that when the mount was
MNT_LOCKED, disconnect_mount() returned false so the actual unmount
didn't happen until the mountpoint was rm'd in the host container.

I'm not sure if this is actually a bug, or a case where the cleanup is
just conservative.  However, it looked like in the case where we call
pivot_root, the detached mounts get marked private but otherwise aren't
in use in the container's namespace any longer.

-K
