From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
Date: Fri, 12 Feb 2010 18:01:28 +0100
Message-ID: <4B758968.30800@fr.ibm.com>
References: <20100211042531.GA8835@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100211042531.GA8835-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On 02/11/2010 05:25 AM, Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Wed, 10 Feb 2010 20:09:17 -0800
> Subject: [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
>
> The contianer name is not printed in the lxc-ps output unless the --lxc
> option is specified.  But the CONTAINER column is printed (and left
> blank) even if the --lxc option is not specified.
>
> 	$ /usr/local/bin/lxc-ps -n foo
> 	CONTAINER    PID TTY          TIME CMD
> 		   19525 pts/2    00:00:01 bash
> 		   20311 pts/2    00:00:00 lxc-ps
> 		   20312 pts/2    00:00:00 ps
>
> Like normal ps, it would be less confusing (IMHO) if the CONTAINER
> column is skipped unless the --lxc option is specified.
>
> 	$ ./lxc-ps -n foo
> 	  PID TTY          TIME CMD
> 	19525 pts/2    00:00:01 bash
> 	20339 pts/2    00:00:00 lxc-ps
> 	20340 pts/2    00:00:00 ps
>
> 	$ ./lxc-ps --lxc -n foo
> 	CONTAINER    PID TTY          TIME CMD
> 	foo        19646 pts/1    00:00:00 lxc-init
> 	foo        19647 pts/1    00:00:00 bash

it would be real nice to have but without the --lxc.

can we kill the short option '-n', which conflicts with the ps below, and make
sure that only '--name'  triggers the extra CONTAINER column ?

C.
