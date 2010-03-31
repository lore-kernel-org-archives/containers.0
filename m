From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6][lxc][v3] Link LXC with USERCR
Date: Wed, 31 Mar 2010 14:13:53 +0200
Message-ID: <4BB33C81.9070802@fr.ibm.com>
References: <20100331070440.GA21570@us.ibm.com> <4BB31801.4000304@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BB31801.4000304-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

  
> Here's a very simple program :
>
> 	# pi1.sh
> 	#
> 	# IBM Confidential
> 	#
> 	# OCO Source Materials
> 	#
> 	# P91223
> 	#
> 	# (C) Copyright IBM Corp. 2003, 2008
> 	#
> 	# The source code for this program is not published or otherwise
> 	# divested of its trade secrets, irrespective of what has been
> 	# deposited with the U.S. Copyright Office.

that's from the example section of bc(1) manpage. nothing confidential
there :)

> 	#!/bin/sh
>
> 	me=`basename "$0" 2>/dev/null`
> 	ndigit=${1:-1000}
>
> 	echo $me - $ndigit digits
> 	echo "scale=$ndigit;a(1)*4" | bc -l
>
> can you run in a terminal :
>
> 	$ lxc-execute -n pi1 -- ./pi1.sh 3000&
> 	$ lxc-checkpoint -n pi1 -d ./ckpt -k
> 	$ lxc-restart -n pi1 -d ./ckpt

please try that suka, it's much more interesting than sleep which can
silently segfault after restart.

thanks,

C.
