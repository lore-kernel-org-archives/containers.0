From: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Problem: Device or resource busy
Date: Tue, 8 Jun 2010 10:49:47 +0900
Message-ID: <AANLkTim4p6EY0RVcpEl_x1Dovck6-arAzexxv9Xh6JI3@mail.gmail.com>
References: <AANLkTinpoXDREZSFkjC5IB5NFWsVh_1UDUyANS5vQyDr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Dear serge,
You are right, I am using the checkpoint_self.c in Documentation/checkpoint
dir.
Now, I am using the self_checkpoint in user-cr, but it still has some
errors:
some content in image file:
"f_op lacks checkpoint^@^O'^@^@^H^@^@^@^D^@^@^@<^@^@^@^@pid 4375 ts
k self_checkpoint err -9]: files_struct"
In fact, when checkpoint externally, it also has the error message mentioned
above.
I traced there is an error in freezer_checkpointing(external checkpointing),
can you point out me where might be wrong?
Jefera


On Mon, Jun 7, 2010 at 10:27 AM, Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Hi all,
> I am using CKPT V19, when I tried to test the checkpoint, there was a
> error:
> 1) using checkpoint_self, error message is: "not container initckpt:
> Invalid argument", FAILED;
> 2) using external checkpoint, there are two situations, if I did it like
> this
> a)
> $ ./test &
>     [1] 3493
> $ echo 3493 > /cgroup/0/tasks"  --------------------> FAILED, error message
> is "echo: write error: Device or resource busy"
> b)
> $ ./loop &
> $./checkpoint 3493 >loop.ckpt    --------------------->FAILED, error
> message is
> "checkpoint: Device or resource busy
> (you may use 'ckptinfo -e' for more info)"
>
> I do not know what is wrong,
> Thank you very much..
> Jefera
>
