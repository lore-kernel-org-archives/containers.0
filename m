From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/3] cgroup: block device i/o bandwidth controller (v3)
Date: Sat, 21 Jun 2008 12:35:40 +0200
Message-ID: <485CD97C.7020904@gmail.com>
References: <1213956335-29866-1-git-send-email-righi.andrea@gmail.com>
	<bb33bcf20806200739v46b97cb2wcaa34182bc0356d3@mail.gmail.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <bb33bcf20806200739v46b97cb2wcaa34182bc0356d3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Subrata Modak <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, roberto-5KDOxZqKugI@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Subrata Modak wrote:
> Dear Andrea,
> 
> We have been tracking Controllers developement for quite some time, and 
> in order to make them work better, we have followed test-driven 
> development for both CPU and Memory Controllers. We already have much of 
> the CPU controllers and few Memory controllers testcases in LTP 
> (http://ltp.cvs.sourceforge.net/ltp/ltp/testcases/kernel/controllers/).
> 
> Test cases for Memory controllers, which are in 2.6.26-mm* tree(s), are 
> also being readied. In the backdrop of this development, i would like to 
> know if you can contribute to LTP test cases under GPLv2 for the i/o 
> bandwidth controller, that you are proposing and any such future work in 
> your pipeline. We would also be happy if you can look in to the existing 
> controllers test cases, and give us more feedback on the same. Expecting 
> to hear from you.

Sure, I will do. I think some small benchmarks I wrote to test the i/o
bandwidth controller could be easily included. Just checking out the ltp
code from cvs right now.

Regards,
-Andrea
