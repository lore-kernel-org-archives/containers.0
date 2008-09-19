From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Re: ptem01 LTP failure in ttydev-0909
Date: Thu, 18 Sep 2008 21:14:08 -0700
Message-ID: <20080919041408.GA31412@us.ibm.com>
References: <20080911201159.GA17071@us.ibm.com>
	<20080916154848.49337bf0@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080916154848.49337bf0-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org


Alan Cox [alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org] wrote:
| > The test changes the window size using the slave-fd and expects that
| > it won't affect the window-size on master-fd. With this change, we
| > return the slave's window size and test fails.
| 
| I've no idea why anyone would have thought the existing behaviour was
| correct. The pty/tty pair code tries to share the size and other
| information at all times and the old test was I think verifying a bug
| existed.
| 
| Unless anyone can cite anything to show otherwise anyway ?

Subrata 

We are referring to the last window size check in test2() of
testcases/kernel/pty/ptem01.c. This check will cause the test
to fail when some of the planned ttydev changes are merged.

Would you happen to know if the check is really required or if
it should be dropped ?

Suka
