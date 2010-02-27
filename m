From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/4][user-cr] Rename libeclone.a to libcheckpoint.a
Date: Fri, 26 Feb 2010 17:44:07 -0800
Message-ID: <20100227014407.GA2652@us.ibm.com>
References: <20100224083452.GB18758@us.ibm.com>
	<20100224083726.GF18758@us.ibm.com>
	<4B8842C8.9080707@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B8842C8.9080707-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
>
>
> Sukadev Bhattiprolu wrote:
>> From c4063a8976fd8eca9b8d62a12b95c3125c8471c7 Mon Sep 17 00:00:00 2001
>> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> Date: Tue, 23 Feb 2010 16:25:36 -0800
>> Subject: [PATCH 4/4][user-cr] Rename libeclone.a to libcheckpoint.a
>>
>> Export app_restart() and usercr.h to user in a new library libcheckpoint.a.
>> Until eclone() makes it into glibc, include eclone() also in this new library
>> and remove the libeclone.a.
>
> I thought libeclone.a is also used by the test suite ?

Yes and I have a todo in the patchset to fix cr-tests if/when we do end up
changing the name.

libeclone.a looks like a short-term name (if/when eclone() is merged in libc,
the library is no longer required).

libcheckpoint.a (or equivalent) has more long term need. If we are having a
libcheckpoint, no point keeping libeclone around too ?

Sukadev
