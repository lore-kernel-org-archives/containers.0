From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6][v3][lxc] Link LXC with USERCR
Date: Thu, 01 Apr 2010 19:36:32 -0400
Message-ID: <4BB52E00.9010805@cs.columbia.edu>
References: <20100401015503.GA25228@us.ibm.com> <4BB49E8D.1010205@fr.ibm.com>
	<20100401163735.GA23231@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100401163735.GA23231-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Cedric Le Goater [clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> Hello Suka,
>>
>> On 04/01/2010 03:55 AM, Sukadev Bhattiprolu wrote:
>>
>>> Resending patches after fixing whitespace damage and the typo in
>>> configure.ac. Add a section to patch-0 (below) to describe the
>>> kernel build (commit-id, config tokens etc).
>> we plan to mergepatch 2,3,4 in lxc mainline real soon, maybe not as such,
>> but they won't be in the way anymore. For the moment, please keep 1,5,6 but
>> make it one patch. no need to resend them in a scattered mode.
> 
> Ok. Can you apply 1,5,6 to a separate branch, say usercr-v1, so its easier
> for others to pull ? When I have some major changes I can resend the patches
> merged up to latest LXC and maybe we can then have usercr-v2 and so on.
> 
>>> 1. Build C/R-enabled Linux kernel
>>>
>>> 	$ cd /root
>>>
>>> 	$ git-clone  git://www.linux-cr.org/pub/git/linux-cr.git linux-cr
>>>
>>> 	$ cd linux-cr
>>>
>>> 	$ git-checkout ckpt-v20-dev
>>>
>>> 		I tested with commit 3522c57a9ec6f08a129a78322318abcb4467db28
>>> 		as HEAD.
>> we need to work on a better delivery scheme. I don't think a commit id is not
>> the most efficient way to dialog when integrating components. We'd rather use
>> a tarball or a patch on an identified kernel.
> 
> Hmm, I thought we could just make a branch on the commit-id and apply
> any additional patches there and build.
> 
> I will base it on a closed-release next time like ckpt-v20-rc1 rather
> than an open one like ckpt-v20-dev.

The stable and -rc versions are tagged with cr-vXX[-rcY].

For example, current version is cr-v21-rc2 (both linux-cr and user-cr)

Oren.
