From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Prefix / Naming USERCR API
Date: Fri, 9 Apr 2010 20:48:40 -0700
Message-ID: <20100410034840.GA11028@us.ibm.com>
References: <20100406020221.GA647@us.ibm.com>
	<1270709399.2602.48.camel@pagloppaglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270709399.2602.48.camel@pagloppaglop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

| > So, what would be a good prefix ?
| > 
| > 	cr_
| > 		cr_checkpoint.h, libcr.a
| > 		cr_checkpoint() cr_restart() cr_freeze() cr_migrate()
| > 		struct cr_checkpoint_args, struct cr_restart_args
| > 	acr_ 
| > 		Only advantage over 'cr_' is lesser likelihood of collision
| > 
| > 		acr_checkpoint.h, libacr.a
| > 		acr_checkpoint() acr_restart() acr_freeze() acr_migrate()
| > 		struct acr_checkpoint_args, struct acr_restart_args
| > 
| > 	lxcr_	
| > 		lxcr_checkpoint.h, liblxcr.a 
| > 		lxcr_checkpoint() lxcr_restart() lxcr_freeze() lxcr_migrate()
| > 		struct lxcr_checkpoint_args, struct lxcr_restart_args
| 
| I do not think lxcr_ prefix is a good choice as lxc is about container
| and could use different libraries for the checkpoint/restart function.

I was thinking of lx as short for linux, but ok. we can drop lxcr_.

Any NACKS to 'acr_' ? If not, I will go with it - for now :-)

Sukadev
