From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Problem: Device or resource busy
Date: Sun, 6 Jun 2010 22:53:47 -0700
Message-ID: <20100607055347.GE21016@count0.beaverton.ibm.com>
References: <AANLkTinpoXDREZSFkjC5IB5NFWsVh_1UDUyANS5vQyDr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinpoXDREZSFkjC5IB5NFWsVh_1UDUyANS5vQyDr-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Mon, Jun 07, 2010 at 10:27:08AM +0900, Jerf gefera wrote:
> Hi all,
> I am using CKPT V19, when I tried to test the checkpoint, there was a error:

Hi,
	Note: We're up to v21 now.

> 1) using checkpoint_self, error message is: "not container initckpt: Invalid
> argument", FAILED;

Hmm, I don't recognize this error message and it doesn't seem to be in v19 --
I checked under checkpoint/,  Documentation/checkpoint/, and even in user-cr
v19. Where'd you get it or where's the code?

> 2) using external checkpoint, there are two situations, if I did it like
> this
> a)
> $ ./test &
>     [1] 3493
> $ echo 3493 > /cgroup/0/tasks"  --------------------> FAILED, error message
> is "echo: write error: Device or resource busy"

Chances are you are hitting the following limitation: you can't move a
task from or to a frozen cgroup. What does /cgroup/0/tasks/freezer.state
show? The following will show the freezer state if the tasks current cgroup
(bash shell fragment):

FILE="/cgroup$(grep freezer /proc/3493/cgroup | head -n 1 | cut -d : -f 3)/freezer.state"
if [ '!' -e "${FILE}" ]; then
	echo THAWED   # Can't freeze without a freezer.state file
else
	cat "${FILE}"
fi

Also, just in case it's useful, what mount options were used for this
cgroup mount?

> b)
> $ ./loop &
> $./checkpoint 3493 >loop.ckpt    --------------------->FAILED, error message
> is
> "checkpoint: Device or resource busy
> (you may use 'ckptinfo -e' for more info)"

What does ckptinfo -e show? Do you have CHECKPOINT_DEBUG configured? What's
dmesg output look like? These pieces of information will usually show what
returned EBUSY. You can also supply the -l [logfile] arguments to checkpoint
to log the error information. No matter what, I recommend recompiling with
CHECKPOINT_DEBUG enabled. Then add ckpt_debug=0xffff to your kernel boot
line in grub/<your bootloader>.

Cheers,
	-Matt Helsley
