From: Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: ptem01 LTP failure in ttydev-0909
Date: Wed, 24 Sep 2008 18:06:17 +0530
Message-ID: <1222259777.5395.7.camel@subratamodak.linux.ibm.com>
References: <20080911201159.GA17071@us.ibm.com>
	<20080916154848.49337bf0@lxorguk.ukuu.org.uk>
	<20080919041408.GA31412@us.ibm.com>
Reply-To: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20080919041408.GA31412-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Sukadev,

On Thu, 2008-09-18 at 21:14 -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> Alan Cox [alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org] wrote:
> | > The test changes the window size using the slave-fd and expects that
> | > it won't affect the window-size on master-fd. With this change, we
> | > return the slave's window size and test fails.
> | 
> | I've no idea why anyone would have thought the existing behaviour was
> | correct. The pty/tty pair code tries to share the size and other
> | information at all times and the old test was I think verifying a bug
> | existed.
> | 
> | Unless anyone can cite anything to show otherwise anyway ?
> 
> Subrata 
> 
> We are referring to the last window size check in test2() of
> testcases/kernel/pty/ptem01.c. This check will cause the test
> to fail when some of the planned ttydev changes are merged.
> 
> Would you happen to know if the check is really required or if
> it should be dropped ?

 I would want the test to remain there, but introduce some checkings
before running the test. As test2() is valid under present
circumstances, we should retain it as people will keep using LTP on
lower kernels.

Having said that, i would like to come with a solution where test2() of
testcases/kernel/pty/ptem01.c is not run after the planned ttydev
changes are merged. Something compile/run time checking to either not to
build that part of code and run it. Can we do something like that by
checking some glibc/kernel exported definitions ?

Regards--
Subrata

> 
> Suka


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
