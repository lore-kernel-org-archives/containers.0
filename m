From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 03/12][user-cr] Add app_restart_args->debug
Date: Mon, 8 Mar 2010 12:42:10 -0800
Message-ID: <20100308204210.GA10472@us.ibm.com>
References: <20100305223439.GA15300@us.ibm.com>
	<20100305223723.GC15939@us.ibm.com>
	<20100308193929.GA20030@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100308193929.GA20030-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > @@ -583,7 +584,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
| >  			args->copy_status = 1;
| >  			break;
| >  		case 'd':
| > -			global_debug = 1;
| > +			global_debug = args->debug = 1;
| 
| You don't actually need to also set global_debug here, right?

Well, there is a subtlelty in a follow-on patch. Maybe I should move
this set of global_debug there.

global_debug is (eventually) static in both restart.c and restart-main.c
The ckpt_debug() macro defined in common.h uses the global_debug.  While
there are no callers of ckpt_debug() in restart-main.c now, setting it
here may enable us just call ckpt_debug() if necessary.

Sukadev
