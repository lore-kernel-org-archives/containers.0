From: "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Should we consider multi syscall tables?
Date: Sun, 31 Aug 2008 11:24:16 +1000
Message-ID: <e7d8f83e0808301824u4cbab02ar2c151f3aa9295020@mail.gmail.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Just one of the recent bug fixes to the Linux Kernel API to keep Linux
user space api kind made me remember the freebsd multi syscall tables.

It was a case that someone developing a user space program had miss
read the api and sent size of data in bits instead of bytes.  Prior
Linux kernels disregarded this defect.  So one day kernel syscall was
fixed and application broke and now we have left overs in the kernel.

Multi syscall tables will allow these bugs to be fixed for all new
applications while allowing backwards support.  Defects become
deprecated functionality.

For containers it will allow emulation of other OS's by using a
syscall table that suits that OS.    This is more a open idea there
many be internal reasons why this is imposable that I cannot see.

Peter Dolding.
