From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 00/15] IPC: code rewrite +
	new	functionalities
Date: Mon, 04 Feb 2008 16:44:34 +0100
Message-ID: <47A732E2.1000504__46971.922965213$1202140006$gmane$org@bull.net>
References: <20080129160229.612172683@bull.net> <20080202182351.GC4456@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080202182351.GC4456-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Pavel Machek wrote:
> Hi!
> 
>> * Patches 9 to 15 propose to add some functionalities, and thus are
>> submitted here for RFC, about both the interest and their implementation.
>> These functionalities are:
>>     - Two new control-commands:
>> 	. IPC_SETID: to change an IPC's id.
>> 	. IPC_SETALL: behaves as IPC_SET, except that it also sets all time
>> 	  and pid values)
>>     - add a /proc/<pid>/semundo file to read and write the undo values of
>> some semaphores for a given process.
>>
>> 	As the namespaces and the "containers" are being integrated in the
>> kernel, these functionalities may be a first step to implement  the
>> checkpoint/restart of an application: in fact the existing API does not allow
>> to specify or to change an ID when creating an IPC, when restarting an
>> application, and the times/pids values of each IPCs are also altered. May be
>> someone may find another interest about this ?
>>
>> So again, comments are welcome.
> 
> Checkpoint/restart is nice, but... sysV ipc is broken by design, do we
> really want to extend it?
> 							Pavel

For my personal culture, what do you mean by "broken by design"?

Even if it's broken, don't you think some people could be interested in 
checkpointing "legacy" applications that use SysV IPC?

Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
