From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ltp controllers: block device i/o bandwidth
 controller testcase
Date: Mon, 07 Jul 2008 15:43:57 +0200
Message-ID: <48721D9D.30006@gmail.com>
References: <1213956335-29866-1-git-send-email-righi.andrea@gmail.com>	
	<bb33bcf20806200739v46b97cb2wcaa34182bc0356d3@mail.gmail.com>	
	<485CD97C.7020904@gmail.com>	
	<bb33bcf20806210816m41f005f7y95031337371d408d@mail.gmail.com>	
	<1214400066.10818.27.camel@subratamodak.linux.ibm.com>	
	<1215090141.26546.17.camel@subratamodak.linux.ibm.com>	
	<486CDBFB.7050706@gmail.com>	
	<1215150659.6333.3.camel@subratamodak.linux.ibm.com>	
	<4871EA52.9000601@gmail.com>
	<1215426277.4764.13.camel@subratamodak.linux.ibm.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1215426277.4764.13.camel-NRFfyExJdYpgXGGE5LP+UZlqa2bBAFbm0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "poornima.nayak" <poornima.nayak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, sudhirkumarmalik <sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Subrata Modak wrote:
> Thanks Andrea for contributing these tests to LTP. I will take some time
> before testing this and coming back to you. Give me some time. Meanwhile
> it would be great if Balbir/Dhaval/others can provide some review
> comments as well.
> 
> Regards--
> Subrata
> 
> On Mon, 2008-07-07 at 12:05 +0200, Andrea Righi wrote:
>> Add the block device I/O bandwidth controller (io-throttle) testcase.
>>
>> See testcase documentation for design and implementation details.
>> See also: http://lkml.org/lkml/2008/7/4/143
>>
>> Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
...
>> diff --exclude CVS -urpN ltp/testcases/kernel/controllers.orig/Makefile ltp/testcases/kernel/controllers/Makefile
>> --- ltp/testcases/kernel/controllers.orig/Makefile	2008-04-30 09:19:29.000000000 +0200
>> +++ ltp/testcases/kernel/controllers/Makefile	2008-07-07 11:43:07.000000000 +0200
>> @@ -1,6 +1,7 @@
>>  SUBDIRS = libcontrollers cpuctl memctl

yep! it seems I missed the target to build the whole thing.

Fix missing build targer for block device I/O bandwidth controller.
Patch to be applied on top of the previous one.

Both patches are also available here:
http://download.systemimager.org/~arighi/ltp/

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
--- ltp/testcases/kernel/controllers/Makefile.orig	2008-07-07 15:21:42.000000000 +0200
+++ ltp/testcases/kernel/controllers/Makefile	2008-07-07 12:25:50.000000000 +0200
@@ -1,4 +1,4 @@
-SUBDIRS = libcontrollers cpuctl memctl
+SUBDIRS = libcontrollers cpuctl memctl io-throttle
 CHECK_CPUCTL = $(shell grep -w cpu /proc/cgroups|cut -f1)
 CHECK_MEMCTL = $(shell grep -w memory /proc/cgroups|cut -f1)
 CHECK_BLOCKIOCTL= $(shell grep -w blockio /proc/cgroups|cut -f1)

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
