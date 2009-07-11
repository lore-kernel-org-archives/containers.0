From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cr_tests: Fix hang when robust futex lists are not
	restored during restart
Date: Sat, 11 Jul 2009 13:56:32 -0700
Message-ID: <20090711205632.GA13003@us.ibm.com>
References: <20090709192207.GJ32310@count0.beaverton.ibm.com>
	<20090709205853.GA23637@us.ibm.com>
	<20090710002144.GA13085@us.ibm.com>
	<20090710233457.GA5213@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090710233457.GA5213-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley [matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| On Thu, Jul 09, 2009 at 05:21:44PM -0700, Sukadev Bhattiprolu wrote:
| > Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > | Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
| > | > The robust futex test can hang if the kernel fails to properly set the robust
| > | > list pointer. This currently happens during restart. The test should not
| > | > hang and instead should report failure.
| > | > 
| > | > Use a timeout to ensure that hangs are caught and reported as failure.
| > | 
| > | Doesn't seem to work though :)  The test still hangs on restart.
| > 
| > I got a hang on restart, with following backtrace (ckpt-v17-rc1 plus couple
| > of bug fixes)
| 
| Sorry, which fixes?

I was referring to informal versions of these two commits

	linux-cr: 3c60cd06509ae7b12db3176dabc5a8baff45341a
	user-cr: 768ee7c3a407b31f8b7202ce5395163dfe79893e

that I added on top of ckpt-v17-rc1.

| 
| Perhaps this is the same problem that Serge was seeing..

Ok.
