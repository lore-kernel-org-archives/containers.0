From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Freezer cgroup Failed
Date: Thu, 10 Jun 2010 07:17:46 -0700
Message-ID: <20100610141746.GM21016@count0.beaverton.ibm.com>
References: <AANLkTin9Eyes8zKTzK5EUWmjFRWjSw5ab86LvT5WCQpM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTin9Eyes8zKTzK5EUWmjFRWjSw5ab86LvT5WCQpM-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jun 10, 2010 at 01:45:05PM +0900, Jerf gefera wrote:
> Dear there,
> The self_checkpoint and self_restart are working now, but why external
> checkpoint cannot work.I did it like the following two ways:
> 1)     $./onetask &
>     $./checkpoint 4347 >img
>     checkpoint: Device or resource busy
>     (you may use 'ckptinfo -e' for more info)
> 
> And the content in the image file is "[Error at do_checkpoint:583][err
> -16]Freezer cgroup failed"

(You need to freeze it as you're trying to do below...)

> 2)     $./onetask &
>       $.echo 4354 > /cgroup/0/tasks
>     $echo FROZEN > /cgroup/0/freezer.state
>     $./checkpoint 4354 > ckpt.image
>     checkpoint: Device or resource busy
>     (you may use 'ckptinfo -e' for more info)
> And the content in the image file is "[Error at do_checkpoint:583][err
> -16]Freezer cgoup failed"
> The content in freezer.state is "FROZEN". I do not know what is wrong, can
> anyone can give me a hand.

You verified that the task shows up in /cgroup/0/tasks? (I ask because you
can't move a task into an already-frozen cgroup)

Are you still using v19?

Cheers,
	-Matt Helsley
