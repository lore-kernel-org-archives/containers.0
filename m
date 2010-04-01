From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6][v3][lxc] Link LXC with USERCR
Date: Thu, 01 Apr 2010 15:24:29 +0200
Message-ID: <4BB49E8D.1010205@fr.ibm.com>
References: <20100401015503.GA25228@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100401015503.GA25228-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Suka,

On 04/01/2010 03:55 AM, Sukadev Bhattiprolu wrote:

> Resending patches after fixing whitespace damage and the typo in
> configure.ac. Add a section to patch-0 (below) to describe the
> kernel build (commit-id, config tokens etc).

we plan to mergepatch 2,3,4 in lxc mainline real soon, maybe not as such,
but they won't be in the way anymore. For the moment, please keep 1,5,6 but
make it one patch. no need to resend them in a scattered mode.

> 1. Build C/R-enabled Linux kernel
>
> 	$ cd /root
>
> 	$ git-clone  git://www.linux-cr.org/pub/git/linux-cr.git linux-cr
>
> 	$ cd linux-cr
>
> 	$ git-checkout ckpt-v20-dev
>
> 		I tested with commit 3522c57a9ec6f08a129a78322318abcb4467db28
> 		as HEAD.

we need to work on a better delivery scheme. I don't think a commit id is not
the most efficient way to dialog when integrating components. We'd rather use
a tarball or a patch on an identified kernel.

> 	# After every reboot, ensure '-o newinstance' mount option to /dev/pts
> 	  works (see Documentation/filesystems/devpts.txt for details). In
> 	  short, run following commands on each reboot:
>
> 		$ rm /dev/ptmx
>
> 		$ ln -s pts/ptmx /dev/ptmx
>
> 		$ chmod 666 /dev/pts/ptmx

can not it be integrated in lxc as a patch ?

> 1. Build USERCR
>
> 	$ cd /root
>
> 	$ git-clone git://git.ncl.cs.columbia.edu/pub/git/user-cr.git user-cr
>
> 	$ cd user-cr
>
> 	$ git-checkout ckpt-v20-dev
>
> 	  	Tested with commit e275f77e4a82d228c1df14dbeb691342e32cdac2
> 		as HEAD.

IMO, tarball and version would be better.

> 	# Apply following two patches:
>
> 	https://lists.linux-foundation.org/pipermail/containers/2010-March/024037.html
> 	https://lists.linux-foundation.org/pipermail/containers/2010-March/024038.html

do you plan to merge them ? if not why ?

> 	$ KERNELSRC=/root/linux-cr make
>
> 		Build USERCR by pointing to corresponding kernel-source.
> 		This should create restart.o and checkpoint.o needed by LXC.
>
> 		I did not need to, but you may need to compile checkpoint.o
> 		and restart.o with -fPIC compiler option.

this needs to be worked out also to be more developer friendly.

if compilation is a pain, we will put some effort into it once but be reluctant to
do it twice. That's what happened to me this time. I didn't compile and let daniel
spent nearly one day to make your environment work ...

Thanks,

C.
