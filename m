From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Problem: Device or resource busy
Date: Mon, 7 Jun 2010 07:24:05 -0500
Message-ID: <20100607122405.GA6842@hallyn.com>
References: <AANLkTinpoXDREZSFkjC5IB5NFWsVh_1UDUyANS5vQyDr@mail.gmail.com>
	<20100607055347.GE21016@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100607055347.GE21016-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Mon, Jun 07, 2010 at 10:27:08AM +0900, Jerf gefera wrote:
> > Hi all,
> > I am using CKPT V19, when I tried to test the checkpoint, there was a error:
> 
> Hi,
> 	Note: We're up to v21 now.
> 
> > 1) using checkpoint_self, error message is: "not container initckpt: Invalid
> > argument", FAILED;
> 
> Hmm, I don't recognize this error message and it doesn't seem to be in v19 --
> I checked under checkpoint/,  Documentation/checkpoint/, and even in user-cr
> v19. Where'd you get it or where's the code?

It's two messages joined together by a bug in ckpt_err()  :)  The first is
"not container init" from checkpoint/checkpoint.c:init_checkpoint_ctx().
That indicates it's not a subtree checkpoint, but that shouldn't be
required for self-checkpoint.

-serge
