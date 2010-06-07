From: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Problem: Device or resource busy
Date: Mon, 7 Jun 2010 10:27:08 +0900
Message-ID: <AANLkTinpoXDREZSFkjC5IB5NFWsVh_1UDUyANS5vQyDr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Hi all,
I am using CKPT V19, when I tried to test the checkpoint, there was a error:
1) using checkpoint_self, error message is: "not container initckpt: Invalid
argument", FAILED;
2) using external checkpoint, there are two situations, if I did it like
this
a)
$ ./test &
    [1] 3493
$ echo 3493 > /cgroup/0/tasks"  --------------------> FAILED, error message
is "echo: write error: Device or resource busy"
b)
$ ./loop &
$./checkpoint 3493 >loop.ckpt    --------------------->FAILED, error message
is
"checkpoint: Device or resource busy
(you may use 'ckptinfo -e' for more info)"

I do not know what is wrong,
Thank you very much..
Jefera
