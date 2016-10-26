From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH v2] mount: In propagate_umount handle overlapping
	mount propagation trees
Date: Tue, 25 Oct 2016 20:42:24 -0500
Message-ID: <87vawfzy0v.fsf__27745.5050302253$1477446299$gmane$org@xmission.com>
References: <87wphb4pjn.fsf@x220.int.ebiederm.org>
	<8737jy3htt.fsf_-_@x220.int.ebiederm.org>
	<20161018024000.GA4901@outlook.office365.com>
	<87r37e9mnj.fsf@xmission.com> <877f95ngpr.fsf_-_@xmission.com>
	<20161020213052.GA25226@outlook.office365.com>
	<87pomtec6c.fsf@xmission.com> <877f90b27o.fsf_-_@xmission.com>
	<20161025205846.GA25080@outlook.office365.com>
	<87mvhs14s7.fsf@xmission.com>
	<20161025234125.GA20335@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161025234125.GA20335-1ViLX0X+lBJGNQ1M2rI3KwRV3xvJKrda@public.gmane.org> (Andrei Vagin's
	message of "Tue, 25 Oct 2016 16:41:26 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:

> On Tue, Oct 25, 2016 at 04:45:44PM -0500, Eric W. Biederman wrote:
>> That is certainly interesting.  The problem is that the reason we were
>> going slow is that there were in fact mounts that had not been traversed
>> in the share group.
>
> You are right.
>
>> 
>> And in fact the entire idea of visiting a vfsmount mountpoint pair
>> exactly once is wrong in the face of shadow mounts.  For a vfsmount
>> mountpoint pair that has shadow mounts the number of shadow mounts needs
>> to be descreased by one each time the propgation tree is traversed
>> during unmount. Which means that as far as I can see we have to kill
>> shadow mounts to correctly optimize this code.  Once shadow mounts are
>> gone I don't know of a case where need your optimization.
>
> Without shadow mounts, it will be hard to save predictable behaviour
> for cases like this:
>
> $ unshare --propagation private -m sh test.sh
> + mount -t tmpfs --make-shared zzzz A
> + mkdir A/a
> + mount -t tmpfs zzzz A/a
> + mount --bind A B
> + mount -t tmpfs zzzz B/a
> + grep zzzz
> + cat /proc/self/mountinfo
> 155 123 0:44 / /root/tmp/A rw,relatime shared:70 - tmpfs zzzz rw
> 156 155 0:45 / /root/tmp/A/a rw,relatime shared:71 - tmpfs zzzz rw
> 157 123 0:44 / /root/tmp/B rw,relatime shared:70 - tmpfs zzzz rw
> 158 157 0:46 / /root/tmp/B/a rw,relatime shared:72 - tmpfs zzzz rw
> 159 155 0:46 / /root/tmp/A/a rw,relatime shared:72 - tmpfs zzzz rw
> + umount B/a
> + grep zzzz
> + cat /proc/self/mountinfo
> 155 123 0:44 / /root/tmp/A rw,relatime shared:70 - tmpfs zzzz rw
> 156 155 0:45 / /root/tmp/A/a rw,relatime shared:71 - tmpfs zzzz rw
> 157 123 0:44 / /root/tmp/B rw,relatime shared:70 - tmpfs zzzz rw
>
> X + a - a = X
>
> Maybe we need to add another ID for propagated mounts and when we
> do umount, we will detach only mounts with the same propagation id.
>
> I support the idea to kill shadow mounts. I guess it will help us to
> simplify algorithm of dumping and restoring a mount tree in CRIU.
>
> Currently it is a big pain for us.

Killing shadow mounts is not exactly a done deal as there are some user
visible effects.  The practical question becomes do we break anything
anyone cares about in userspace.  Answering those practical questions
sucks.

I definitely think we should try to kill shadow mounts because they are
such a big pain to deal with, and only provide very limited value.

So far the only thing I have seem shadow mounts being good for is
preserving unmount behavior in cases where what someone has
constructed an artificially evil mount tree. I haven't figured out how
to see how any of those mount trees are actually useful in real life.

Eric
