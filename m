From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Prefix / Naming USERCR API
Date: Mon, 5 Apr 2010 19:02:22 -0700
Message-ID: <20100406020221.GA647@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Prefix / Function names for USERCR API

I guess the long term plan is to export the USERCR funtionality to management
or other applications as a library. We are trying to choose a good prefix for
the USERCR API. 

The current prefix for the API is, which was cooked up on the fly, is
"app_". This prefix is currently used in structures/functions like:

	struct app_checkpoint_args * 
	struct app_restart_args * 
	app_checkpoint()
	app_restart()

In the future we may have additional apis like:

	xxx_freeze()
	xxx_migrate()
	xxx_cr_advise() ?

Kernel api already uses some prefixes like (checkpoint, ckpt_ etc:

	<linux/checkpoint.h>
	<linux/checkpoint_hdr.h>

	struct ckpt_hdr_header
	struct ckpt_hdr

	checkpoint(2)
	restart(2)

	#define RESTART_TASKSELF 0x1
	#define CHECKPOINT_SUBTREE 0x1

Having a prefix would make it easy to identify the API and avoid collision
with other libraries that the application might link against. Eg: the
"pam_" prefixes PAM api.

Having a prefix like "cr_" or "acr_" could cause some redundancy in some
names, like cr_checkpoint(), but is probably ok, like pam_authenticate() ?

So, what would be a good prefix ?

	cr_
		cr_checkpoint.h, libcr.a
		cr_checkpoint() cr_restart() cr_freeze() cr_migrate()
		struct cr_checkpoint_args, struct cr_restart_args
	acr_ 
		Only advantage over 'cr_' is lesser likelihood of collision

		acr_checkpoint.h, libacr.a
		acr_checkpoint() acr_restart() acr_freeze() acr_migrate()
		struct acr_checkpoint_args, struct acr_restart_args

	lxcr_	
		lxcr_checkpoint.h, liblxcr.a 
		lxcr_checkpoint() lxcr_restart() lxcr_freeze() lxcr_migrate()
		struct lxcr_checkpoint_args, struct lxcr_restart_args

Other prefixes or naming suggestions ?

Thanks,

Sukadev
