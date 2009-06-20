From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: c/r of pdeath
Date: Sat, 20 Jun 2009 03:02:22 -0400
Message-ID: <4A3C897E.2000106@cs.columbia.edu>
References: <20090619182114.GA27320@us.ibm.com>
	<4A3C1084.3080305@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A3C1084.3080305-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Oren Laadan wrote:
> 
> Serge E. Hallyn wrote:
>> Hi Oren,
>>
>> commit 9a45e26c0aabda6a94e2ac620befd8ee12a7363d adds
>> reset of pdeath_signal.  It does so unconditionally.  I
>> don't think that's safe.  Perhaps if pdeath_signal is
>> anything other than 0, it should only be restored if
>> the task is capable(CAP_KILL)?
> 
> Hmmm... maybe I'm missing something here, but --
> 
> pdeath_signal indicates that the process wishes to receive
> a signal, not to send one. It may change through prctl()
> without requiring any capabilities from the caller. Finally
> it is reset at fork/clone.
> 
> So at worse it will kill the specific task that holds it ?
> 
> --
> 
> As a side note - for a brief moment I worried that it may
> break restart with zombies, if the to-be-zombie process has
> a child that already restarted (including pdeath_signal) and
> then exits, then the child will receive a signal unwillingly.
> 
> I then realized that it's safe as long as we restore parents
> before their children. In turn this depends on the checkpoint
> order, which indeed operates this way.

Bahh... silly me -
it's handled by commit efd1403a4606e0d6bd84299dab0b74792531c712
"c/r: introduce PF_RESTARTING, and skip notification on exit"

Oren.
