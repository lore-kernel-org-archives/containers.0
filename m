From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Problem: Device or resource busy
Date: Fri, 11 Jun 2010 17:52:38 -0500
Message-ID: <20100611225237.GB1038@hallyn.com>
References: <AANLkTinpoXDREZSFkjC5IB5NFWsVh_1UDUyANS5vQyDr@mail.gmail.com>
	<AANLkTim4p6EY0RVcpEl_x1Dovck6-arAzexxv9Xh6JI3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim4p6EY0RVcpEl_x1Dovck6-arAzexxv9Xh6JI3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Quoting Jerf gefera (jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Dear serge,
> You are right, I am using the checkpoint_self.c in Documentation/checkpoint
> dir.
> Now, I am using the self_checkpoint in user-cr, but it still has some
> errors:
> some content in image file:
> "f_op lacks checkpoint^@^O'^@^@^H^@^@^@^D^@^@^@<^@^@^@^@pid 4375 ts
> k self_checkpoint err -9]: files_struct"
> In fact, when checkpoint externally, it also has the error message mentioned
> above.
> I traced there is an error in freezer_checkpointing(external checkpointing),
> can you point out me where might be wrong?
> Jefera

As Matt asked in another thread, are you still using v19?

v21 should iirc tell you the name of the file causing the trouble.  If
v21 is not an option, then pls modify your external checkpoint script
to keep the task frozen, then look at the contents of /proc/pid/fd
and /proc/pid/fdinfo for the checkpointed pid.  Something like
	pid=$1
	touch outout
	/bin/ls /proc/$pid/fd >> outout
	/bin/ls /proc/$pid/fdinfo >> outout
	for f in `/bin/ls /proc/$pid/fdinfo`; do
		echo "/proc/$pid/fdinfo/$f:" >> outout
		/bin/ls /proc/$pid/fdinfo/$f >> outout
	done
	for f in `/bin/ls /proc/$pid/fd`; do
		echo "/proc/$pid/fd/$f:" >> outout
		stat /proc/$pid/fd/$f >> outout
	done

Really, I'm assuming that the problem is either an inherited open fd to
your pty, or an inherited nscd socket.  But let's see.

-serge
