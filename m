From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/6][lxc][v3] Link LXC with USERCR
Date: Wed, 31 Mar 2010 22:03:03 -0700
Message-ID: <20100401050303.GA18986@us.ibm.com>
References: <20100331070440.GA21570@us.ibm.com> <4BB31801.4000304@fr.ibm.com>
	<4BB33C81.9070802@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BB33C81.9070802-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater [clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> 	#!/bin/sh
>>
>> 	me=`basename "$0" 2>/dev/null`
>> 	ndigit=${1:-1000}
>>
>> 	echo $me - $ndigit digits
>> 	echo "scale=$ndigit;a(1)*4" | bc -l
>>
>> can you run in a terminal :
>>
>> 	$ lxc-execute -n pi1 -- ./pi1.sh 3000&
>> 	$ lxc-checkpoint -n pi1 -d ./ckpt -k
>> 	$ lxc-restart -n pi1 -d ./ckpt
>
> please try that suka, it's much more interesting than sleep which can
> silently segfault after restart.

Agree.  BTW, after the sleep I tested C/R of a VNC server with a vi session
running inside.

I tried the above program, which is definitely more interesting, but am
having trouble with stdout after restart - restart seems to succeed, but
nothing shows up on stdout. If I redirect the output of "bc -l" to a file,
the C/R (with lxc) works fine.

I am investigating the stdout issue though.

Thanks,

Sukadev
