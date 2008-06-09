From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] cryo: Fix option -f in checkpointing mode
Date: Mon, 09 Jun 2008 09:16:08 -0700
Message-ID: <1213028168.3508.20.camel@nimitz>
References: <20080609144709.408752383@theryb.frec.bull.fr>
	<20080609144844.524643174@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080609144844.524643174-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-06-09 at 16:47 +0200, Benjamin Thery wrote:
> Option -f couldn't be used in conjunction with option -p (for
> checkpointing).
> O_CREAT is missing in the flags passed to open().
> 
> Now, we can do:
> 
> $ cr -p MYPID -f test.cryo
> 
> (I know the coding style is not perfect (long lines, several
> instructions
> on the same line), but it fits with cryo's style :) ).

So, I suggest that we start using kernel coding style on this sucker.
We're all used to it, and the original developer isn't around to bitch
about it. :)

-- Dave
