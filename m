From: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Subject: Re: Possible bug: detached mounts difficult to cleanup
Date: Fri, 13 Jan 2017 15:28:20 -0800
Message-ID: <20170113232820.GA3094__28036.9237451398$1484350128$gmane$org@templeofstupid.com>
References: <20170111012454.GB2497@templeofstupid.com>
	<87r34a5p3t.fsf@xmission.com>
	<20170111030753.GC2497@templeofstupid.com>
	<CANaxB-zMzS-euqR1_LvZSoEsO-Y6q=_qGNTJZCKZTL5WfFF16g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANaxB-zMzS-euqR1_LvZSoEsO-Y6q=_qGNTJZCKZTL5WfFF16g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 12, 2017 at 04:37:13PM -0800, Andrei Vagin wrote:
> On Tue, Jan 10, 2017 at 7:07 PM, Krister Johansen
> <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org> wrote:
> > On Wed, Jan 11, 2017 at 03:04:22PM +1300, Eric W. Biederman wrote:
> >> Any chance you have a trivial reproducer script?
> >>
> >> From you description I don't quite see the problem.  I know where to
> >> look but if could give a script that reproduces the conditions you
> >> see that would make it easier for me to dig into, and would certainly
> >> would remove ambiguity.   Ideally such a script would be runnable
> >> under unshare -Urm for easy repeated testing.
> >
> > My apologies.  I don't have something that fits into a shell script, but
> > I can walk you through the simplest test case that I used when I was
> > debugging this.
> >
> > Create net a ns:
> >
> >     $ sudo unshare -n bash
> >     # echo $$
> >     2771
> >
> > In another terminal bind mount that ns onto a file:
> >
> >     # mkdir /run/testns
> >     # touch /run/testns/ns1
> >     # mount --bind /proc/2771/ns/net /run/testns/ns1
> >
> > Back in first terminal, create a new ns, pivot root, and umount detach:
> >
> >     # exit
> >     $ unshare -U -m -n --propagation slave --map-root-user bash
> >     # mkdir binddir
> >     # mount --bind binddir binddir
> >     # cp busybox binddir
> >     # mkdir binddir/old_root
> >     # cd binddir
> >     # pivot_root . old_root
> >     # ./busybox umount -l old_root
> 
> Hi,
> 
> But this process still has mappings from "old_root"
> [root@fc24 busybox]# cat /proc/$$/maps
> 5607360f1000-5607361e9000 r-xp 00000000 fd:02 1176793
>   /usr/bin/bash
> 5607363e8000-5607363ec000 r--p 000f7000 fd:02 1176793
>   /usr/bin/bash
> 5607363ec000-5607363f5000 rw-p 000fb000 fd:02 1176793
>   /usr/bin/bash
> ...
> 
> You have to call "exec ./busybox sh" to release all "old_root" mounts.
> And in this case I see that a net namespace is destroyed:
> 
> [root@fc24 busybox]# cat /proc/slabinfo | /bin/grep net_name
> net_namespace          5      8   6784    4    8 : tunables    0    0
>   0 : slabdata      2      2      0
> [root@fc24 busybox]# exec /bin/sh
> / # cat /proc/slabinfo | /bin/grep -- net
> net_namespace          4      8   6784    4    8 : tunables    0    0
>   0 : slabdata      2      2      0

Thanks.  This seems to be the part of the puzzle that I was missing.  I
went back and looked and found that the container pid 1 did have live
memory mappings to files that are mounted on the old_root.  Appreciate
the nudge in the right direction.

-K
