From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/9] user-cr: s390 eclone wrapper
Date: Wed, 25 Nov 2009 13:40:46 -0500
Message-ID: <4B0D7A2E.6080108@cs.columbia.edu>
References: <1258505746-31182-1-git-send-email-ntl@pobox.com>	<1258505746-31182-4-git-send-email-ntl@pobox.com>	<20091118032333.GA18641@us.ibm.com>	<1258520988.4031.1254.camel@localhost.localdomain>
	<20091118152450.GB23694@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091118152450.GB23694-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org




Serge E. Hallyn wrote:
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> On Tue, 2009-11-17 at 21:23 -0600, Serge E. Hallyn wrote:
>>> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>>>> Based on original work from Serge Hallyn.
>>> Needed the following patch on top of that.  Otherwise the
>>> whole set looks good to me, thanks!
>> Great, thanks for the fixups.
>>
>>
>>> (Oh, one other note, the default #ifdef for NR_eclone actually
>>> is different depending on whether we're on a c/r kernel or not,
>>> unfortunately :(.  I'm leaving it as the non-c/r kernel value
>>> for now.)
>> Right.. I was thinking that the syscall numbers for eclone should
>> precede those for checkpoint and restart in the c/r patch set.  Thoughts
>> on that?
> 
> Yes, I was thinking the same thing.

Good idea - will do in v19-rc2.

Oren.
