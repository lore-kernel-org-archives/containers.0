From: Andrew Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: why this behavior in 3.16 kernel ?
Date: Wed, 3 Aug 2016 18:14:02 -0700
Message-ID: <20160804011401.GA20044@gmail.com>
References: <CAJ5w2CmDcXzOKppojwN2F5H-mFu_OM-XUoTWnTuLKrdoPG9iQg@mail.gmail.com>
	<877fbxhhfi.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877fbxhhfi.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 03, 2016 at 12:48:49PM -0500, Eric W. Biederman wrote:
> cool linux <linux.cool.hot-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> 
> > Hi,
> >
> > I have executed below script on 3.16 kernel and it took to finish almost
> > 1.30sec to 2 minutes, where as in my older kernel(3.2.30) it took only 3
> > secs.
> >
> > ================================================
> > date
> >
> > for (( i=1; i <= 2000; i++ ))
> > do
> >  ip netns exec gmk ip link show > /dev/null
> > done
> >
> > date
> > ================================================
> >
> > Please guide me why this behavior in 3.16 kernel ?
> 
> Good question.  What happens on a modern kernel? 4.7 is the most recent
> release, 3.16 was released two years ago.  My hunch is that you just
> started using systemd and it has changed the defaults with all of the
> mounts.  But shrug.  I don't recall how all of those relevant kernel
> pieces operated two years ago.

Hi,

I did a few experiments and saw the same degradation. I used rhel7 and
fedoara 23, they both uses systemd.

I executed this test on the rhel7 kernel (3.10++).
[ ~]# time for (( i=1; i <= 2000; i++ )); do ip netns exec gmk ip link show > /dev/null; done

real	0m4.837s
user	0m0.983s
sys	0m3.885s

Then I executed it in Fedora 23 (4.6.4-201.fc23.x86_64) in the same
hardware. The result time is much worse.
[ ~]# time for i in `seq 2000`; do ip netns exec gmk ip link show; done > /dev/null

real	0m36.067s
user	0m1.374s
sys	0m3.677s

Then I tried to exclude a mount namespace:
[ ~]# time for i in `seq 2000`; do nsenter --net=/run/netns/gmk ip link show; done > /dev/null

real	0m4.476s
user	0m1.039s
sys	0m3.438s

It helps, so the problem is defenetly about mount namespaces.

Then I tried to create a clean mount namespace, but this doesn't affect
results:
[ ~]# cat /proc/self/mountinfo 
84 83 253:0 / / rw,relatime - ext4 /dev/mapper/fedora-root rw,seclabel,data=ordered
90 84 0:4 / /proc rw,nosuid,nodev,noexec,relatime - proc proc rw
93 84 0:17 / /sys rw,nosuid,nodev,noexec,relatime - sysfs sysfs rw,seclabel
111 84 0:20 / /run rw,nosuid,nodev - tmpfs tmpfs rw,seclabel,mode=755

[ ~]# time for i in `seq 2000`; do ip netns exec gmk ip
link show; done > /dev/null

real	0m40.129s
user	0m1.272s
sys	0m3.898s

Then I boot the kernel with maxcpus=1. Surprise! Surprise! It works
fast.

[ ~]# ip netns add gmk
[ ~]# time for i in `seq 2000`; do ip netns exec gmk ip
link show; done > /dev/null

real	0m2.445s
user	0m0.604s
sys	0m1.778s


> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
