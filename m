From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6][lxc][v3] Link LXC with USERCR
Date: Wed, 31 Mar 2010 18:31:38 +0200
Message-ID: <4BB378EA.1010703@fr.ibm.com>
References: <20100331070440.GA21570@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100331070440.GA21570-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> lxc-checkpoint, lxc-restart in the LXC source tree are currently stubs.
> Following set of patches, when applied to LXC and built with USERCR as
> described below, enable enable lxc-checkpoint and lxc-restart of some
> simple containers
>   

Hi Suka,

Thanks for the patchset. Before going further and comment the patchset 
and the TODOs, I would like to succeed to checkpoint something.

Despite your detailed informations, I was not able to checkpoint 
'sleep'. I am sure I am missing something or something is missing :)

[ ... ]

Here is the different steps I did:

 1 -  downloaded the git tree at git://www.linux-cr.org/pub/git/linux-cr
 2 - compiled the kernel making sure I have the following kernel config 
options

 > grep CHECKPOINT .config
CONFIG_CHECKPOINT_SUPPORT=y
CONFIG_SYSVIPC_CHECKPOINT=y
CONFIG_CHECKPOINT=y
CONFIG_CHECKPOINT_DEBUG=y

and of course the needed namespaces.

3 - The level of the code is the commit 
3522c57a9ec6f08a129a78322318abcb4467db28


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
> 	
> 	# Apply following two patches:
>
> 	https://lists.linux-foundation.org/pipermail/containers/2010-March/024037.html
> 	https://lists.linux-foundation.org/pipermail/containers/2010-March/024038.html
>
> 	$ cd /root/user-cr
>
> 	$ KERNELSRC=/root/linux-2.6/ make 
>
> 		Build USERCR by pointing to corresponding kernel-source.
> 		This should create restart.o and checkpoint.o needed by LXC.
>   

4 - followed these steps ^^^^

I had to compile user-cr with the "-fPIC" flags in order to link lxc and 
user-cr.

/usr/lib64/gcc/x86_64-suse-linux/4.3/../../../../x86_64-suse-linux/bin/ld: 
/home/dlezcano/work/src/user-cr/checkpoint.o: relocation R_X86_64_32 
against `a local symbol' can not be used when making a shared object; 
recompile with -fPIC
/home/dlezcano/work/src/user-cr/checkpoint.o: could not read symbols: 
Bad value


> 2. Build/install LXC
>
> 	$ cd /root/lxc.git
>
> 	Apply attached patches to LXC (I tested with these patches applied
> 	to commit 9ea8066aa67b808f71f46e346bd7a215e2a355f3)
>   

Ok, I applied the patchset with quilt. It looks like Michel used git 
which is stricter than quilt.
I fixed the typo in configure.ac

> 3. Checkpoint/restart a simple LXC container
>
> 	$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 1000
>
> 	$ lxc-checkpoint --name foo --image /root/lxc-foo.ckpt
>   

Ok, I reach this point. But the checkpoint fails always with EINVAL and 
the statefile is empty.

Digging a bit in the userspace + kernel code, I was wondering if the 
user flags match ?

Thanks in advance.
  -- Daniel

ps : I noticed the application is not thawed in the error code path, so 
I have to resume it manually everytime the checkpoint fails.
