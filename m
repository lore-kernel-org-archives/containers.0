From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6][lxc][v3] Link LXC with USERCR
Date: Thu, 01 Apr 2010 01:37:31 -0400
Message-ID: <4BB4311B.9010002@cs.columbia.edu>
References: <20100331070440.GA21570@us.ibm.com> <4BB35519.8080500@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BB35519.8080500-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org



Daniel Lezcano wrote:
> Sukadev Bhattiprolu wrote:
>> lxc-checkpoint, lxc-restart in the LXC source tree are currently stubs.
>> Following set of patches, when applied to LXC and built with USERCR as
>> described below, enable enable lxc-checkpoint and lxc-restart of some
>> simple containers
>>
> 
> [ ... ]
> 
>> 1. Build USERCR
>>
>> 	$ cd /root
>>
>> 	$ git-clone git://git.ncl.cs.columbia.edu/pub/git/user-cr.git user-cr
>>
>> 	$ cd user-cr
>>
>> 	$ git-checkout ckpt-v20-dev
>>
>> 	  	Tested with commit e275f77e4a82d228c1df14dbeb691342e32cdac2
>> 		as HEAD.
>> 	
>> 	# Apply following two patches:
>>
>> 	https://lists.linux-foundation.org/pipermail/containers/2010-March/024037.html
>> 	https://lists.linux-foundation.org/pipermail/containers/2010-March/024038.html
>>
>> 	$ cd /root/user-cr
>>
>> 	$ KERNELSRC=/root/linux-2.6/ make 
> 
> Assuming the kernel source tree below is right,
> 
>    http://www.linux-cr.org/git/?p=linux-cr.git;a=summary
> 
> Shall I use ckpt-v20 or ckpt-v20-dev with your patchset ?

It's in rcX state and hence not made the primary branch, but you
should probably try ckpt-v21-rc2 (kernel) and ckpt-v20-dev (for
user-cr) instead.

Oren.
