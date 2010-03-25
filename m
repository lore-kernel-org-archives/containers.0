From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH][lxc]: Add --with-usercr configure option
Date: Thu, 25 Mar 2010 15:30:51 +0100
Message-ID: <4BAB739B.9090601@fr.ibm.com>
References: <20100325010524.GA7385@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100325010524.GA7385-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Pls let me know if this will work. Will address your other comments
> and repost entire patchset.
> 
> ---
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Wed, 24 Mar 2010 17:26:44 -0700
> Subject: [PATCH 1/1] Add --with-usercr configure option
> 
> Add a configure option, --with-usercr=dir which would allow linking
> with external (i.e USERCR) implementation  of checkpoint/restart.
> 
> For now, USERCR "publishes" a app-checkpoint.h, checkpoint.o and
> restart.o files which implement the functions app_checkpoint() and
> app_restart().
> 
> Usage:
> 	$ ./autogen.sh
> 
> 	$ ./configure --help |grep usercr
> 	--with-usercr=dir     use the Checkpoint/Restart implementation in 'dir'

Ok, let's call it : --with-cr

> 	$ ls /home/guest/user-cr/
> 	app-checkpoint.h    checkpoint.o    restart.o
> 
> 	$ ./configure --with-usercr=/home/guest/user-cr
> 
> TODO:
> 	If names of interfaces in USERCR change, we may want to rename
> 	the config option too ?
> 
> 	Can we remove the src/lxc/{checkpoint.o,restart.o} files from
> 	liblxc.so and lxc-checkpoint/lxc-restart directly with them ?
> 	That way, the USERCR interfaces/object files don't end up in
> 	liblxc.so.
> 
> 	USERCR_CFLAGS are only needed for src/lxc/{checkpoint.c,restart.c}
> 	but not sure if there is an easy way to define autoconf CFLAGS
> 	just for those two files.

Hum, no. It would be preferable to integrate them in lxc for now (as 
experimental code) and later create a glue between lxc and usercr, so 
usercr interfaces would be callable as a plugin of lxc.

The --with-cr will remains but specifying a CR library. The lxc 
checkpoint and restart code will then dlopen this library and use the 
checkpoint / restart functions of this library.

If no library is specified, the lxc-checkpoint / lxc-restart will return 
ENOSYS.

That will ensure the CR specific code stays in a separate library and 
will keep things opened to take into account other CR solutions like blcr.

But until we reach this point, we should integrate everything hardcoded 
in the lxc library in order to let the plugin API drawing to appear in 
the integration big picture.

Thanks
   -- Daniel
